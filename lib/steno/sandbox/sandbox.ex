defmodule Steno.Sandbox do
  use GenServer
  ##
  ## interface
  ##
  def start(sandbox_id, on_data) do
    Steno.Sandbox.Sup.start_sandbox(sandbox_id, on_data)
  end

  def start_link(sandbox_id, on_data) do
    GenServer.start_link(__MODULE__, 
      %{
        sb_id:  sandbox_id,
        serial: 0,
        output: [],
        queue:  :queue.from_list([]),
        active: nil,
        ondata: on_data,
        phase:  "preboot",
      },
      name: {:via, :gproc, {:n, :l, {:sandbox, sandbox_id}}}
    )
  end

  def find(sandbox_id) do
    case :gproc.where({:n, :l, {:sandbox, sandbox_id}}) do
      :undefined -> nil
      pid -> pid
    end
  end

  def exec(pid, phase, cmd) do
    GenServer.call(pid, {:exec, phase, cmd})
  end

  def push(pid, src, dst) do
    GenServer.call(pid, {:push, src, dst})
  end

  def dump(pid) do
    GenServer.call(pid, :dump)
  end

  def idle?(pid) do
    GenServer.call(pid, :idle?)
  end

  def wait_idle(pid) do
    if idle?(pid) do
      :ok
    else
      :timer.sleep(100)
      wait_idle(pid)
    end
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def cleanup(sandbox_id) do
    script = script_path("stop")
    sbname = sandbox_name(sandbox_id)
    cmd    = ~s(bash "#{script}" "#{sbname}")
    Porcelain.shell(cmd)
  end

  ##
  ## implementation
  ##
  def init(state) do
    state = state
    |> queue_add({"launch", "boot", [sandbox_name(state.sb_id)]})
    |> spawn_next
    {:ok, state}
  end

  def handle_call({:exec, phase, cmd}, _from, state) do
    sbname = sandbox_name(state.sb_id)
    state = state
    |> queue_add({"exec", phase, [sbname, cmd]})
    |> spawn_next
    {:reply, :ok, state}
  end

  def handle_call({:push, src, dst}, _from, state) do
    sbname = sandbox_name(state.sb_id)
    state = state
    |> queue_add({"push", "push", [sbname, src, dst]})
    |> spawn_next
    {:reply, :ok, state}
  end

  def handle_call(:dump, _from, state) do
    {:reply, state.output, state}
  end

  def handle_call(:idle?, _from, state) do
    {:reply, (!state.active && :queue.is_empty(state.queue)), state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  defp queue_add(state, item) do
    %{ state | queue: :queue.snoc(state.queue, item) }
  end

  defp spawn_cmd({script, phase, args}) do
    args1 = Enum.join(Enum.map(args, &(~s["#{&1}"])), " ")

    proc = Porcelain.spawn_shell(
      ~s[bash "#{script_path(script)}" #{args1}],
      out: {:send, self()},
      err: {:send, self()})

    {:ok, proc, phase}
  end

  defp spawn_next(state) do
    if state.active || :queue.is_empty(state.queue) do
      state
    else
      next = :queue.get(state.queue)
      {:ok, proc, phase} = spawn_cmd(next)

      state
      |> Map.put(:queue,  :queue.drop(state.queue))
      |> Map.put(:active, proc)
      |> Map.put(:phase,  phase)
    end
  end

  defp script_path(name) do
    base = Application.app_dir(:steno, "priv")
    "#{base}/scripts/sandbox/#{name}.sh"
  end

  defp sandbox_name(sandbox_id) do
    "steno-sb-#{sandbox_id}"
  end

  ##
  ## callbacks
  ##
  def handle_info({_src, :data, stream, data}, state) do
    serial = state.serial + 1
    item   = {serial, state.phase, stream, data}
    state  = state
    |> Map.put(:output, [ item | state.output ])
    |> Map.put(:serial, serial)
    state.ondata.({:data, item})
    {:noreply, state}
  end

  def handle_info({_src, :result, result}, state) do
    state = state
    |> Map.put(:active, nil)
    |> spawn_next
    state.ondata.({:done, result})
    {:noreply, state}
  end
end

