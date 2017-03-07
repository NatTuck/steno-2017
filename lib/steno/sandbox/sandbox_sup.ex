defmodule Steno.Sandbox.Sup do
  use GenServer

  alias Steno.Sandbox

  ##
  ## interface
  ##

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: :sandbox_sup)
  end

  def start_sandbox(sandbox_id, on_data) do
    GenServer.call(:sandbox_sup, {:start, sandbox_id, on_data})
  end

  ##
  ## callbacks
  ##

  def init(_) do
    :erlang.process_flag(:trap_exit, true)
    {:ok, []}
  end

  def handle_call({:start, sandbox_id, on_data}, _from, kids) do
    {:ok, pid} = Sandbox.start_link(sandbox_id, on_data)
    {:reply, {:ok, pid}, [ {sandbox_id, pid} | kids ]}
  end

  def handle_info({:EXIT, pid, reason}, kids) do
    IO.puts "Child process went down"
    IO.inspect {pid, reason}
    Enum.each kids, fn {sb_id, pp} ->
      if pp == pid do
        Sandbox.cleanup(sb_id)
      end
    end
    {:noreply, Enum.filter(kids, fn {_, pp} -> pp != pid end)}
  end

  def terminate(_reason, kids) do
    Enum.each kids, fn {sb_id, _pp} ->
      Sandbox.cleanup(sb_id)
    end
  end
end

