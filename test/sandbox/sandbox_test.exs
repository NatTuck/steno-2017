defmodule Steno.SandboxTest do
  use ExUnit.Case

  setup _tags do
    Process.register(self(), :sandbox_test)
    {:ok, _} = Steno.Sandbox.Sup.start_link()
    :ok
  end

  test "hello", _ do
    {:ok, sb} = Steno.Sandbox.Sup.start_sandbox(101, &print_stuff/1)
    wait_done()

    :ok = Steno.Sandbox.exec(sb, "hostname")
    :timer.sleep(5000)

    :ok = Steno.Sandbox.stop(sb)
    :timer.sleep(5000)
  end

  defp wait_done do
    receive do
      :done -> :ok
      other -> IO.inspect({:huh, other})
    end
  end

  defp print_stuff(stuff) do
    IO.inspect(stuff)
    case stuff do
      {:done, _} -> Process.send(:sandbox_test, :done, [])
      _ -> :ok
    end
  end
end
