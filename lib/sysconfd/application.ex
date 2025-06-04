defmodule Sysconfd.Application do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("Starting Sysconfd")
    Sysconfd.Processor.run_all()

    children = [
      {Task, &watchdog_loop/0},
      Sysconfd.API.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Sysconfd.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    Sysconfd.Systemd.notify_ready()
    {:ok, pid}
  end

  defp watchdog_loop do
    Sysconfd.Systemd.start_watchdog()
    receive do
      :watchdog_ping ->
        Sysconfd.Systemd.handle_watchdog_ping()
        watchdog_loop()
    end
  end
end
