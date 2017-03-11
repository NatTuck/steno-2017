defmodule Steno.SandboxTest do
  use ExUnit.Case

  alias Steno.Sandbox

  setup _tags do
    Process.register(self(), :sandbox_test)
    :ok
  end

  test "hello", _ do
    grade("test/fib", "test/fib-grading")
  end

  defp grade(sub_path, gra_path) do
    priv = Application.app_dir(:steno, "priv")

    sub = make_tar("#{priv}/#{sub_path}")
    gra = make_tar("#{priv}/#{gra_path}")

    {:ok, sb} = Sandbox.start(101, &print_stuff/1)
    Sandbox.wait_idle(sb)

    :ok = Sandbox.push(sb, sub, "/root/sub.tar.gz")
    :ok = Sandbox.push(sb, gra, "/root/gra.tar.gz")

    defaults = make_tar("#{priv}/scripts/sandbox/defaults")
    :ok = Sandbox.push(sb, defaults, "/root/defaults.tar.gz")

    driver = "#{priv}/scripts/sandbox/driver.pl"
    :ok = Sandbox.push(sb, driver, "/root/driver.pl")
    :ok = Sandbox.exec(sb, "check", "find /root")

    :ok = Sandbox.exec(sb, "setup", "perl /root/driver.pl setup")
    :ok = Sandbox.exec(sb, "unpack", "perl /root/driver.pl unpack")
    :ok = Sandbox.exec(sb, "build", "perl /root/driver.pl build")
    :ok = Sandbox.exec(sb, "grade", "perl /root/driver.pl grade")
    Sandbox.wait_idle(sb)

    #IO.inspect(Sandbox.dump(sb))

    rm_tmp_dir()

    :ok = Sandbox.stop(sb)
    :timer.sleep(2000)
  end

  defp print_stuff(stuff) do
    IO.inspect(stuff)
  end

  defp shell(cmd) do
    {_, 0} = System.cmd("bash", ["-c", cmd])
    :ok
  end

  defp tmp_dir() do
    pid = System.get_pid()
    tmp = "/tmp/steno_test.#{pid}"

    shell("mkdir -p #{tmp}")

    tmp
  end

  defp rm_tmp_dir() do
    tmp = tmp_dir()
    if tmp =~ ~r[^/tmp/steno_test] do
      shell("rm -rf #{tmp}")
    end
  end

  defp make_tar(path) do
    tmp = tmp_dir() 
    dir = Path.dirname(path)
    nam = Path.basename(path)

    shell("(cd #{dir} && tar czf #{tmp}/#{nam}.tar.gz #{nam})")
    "#{tmp}/#{nam}.tar.gz"
  end
end
