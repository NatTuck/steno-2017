defmodule Steno.DemoRun do
  def got_output(msg) do
    IO.inspect(msg)
  end
end

alias Steno.Sandbox


{:ok, sb} = Sandbox.start(102, &Steno.DemoRun.got_output/1)
Sandbox.wait_idle(sb)

Sandbox.stop(sb)
:timer.sleep(1000)

