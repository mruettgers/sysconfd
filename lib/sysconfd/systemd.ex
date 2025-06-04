defmodule Sysconfd.Systemd do
  @moduledoc """
  Handles systemd integration including notifications and watchdog functionality.
  """

  require Logger

  def start_watchdog do
    if systemd_enabled?() do
      interval = Application.get_env(:sysconfd, :systemd)[:watchdog_interval] * 1000
      Process.send_after(self(), :watchdog_ping, interval)
      Logger.info("Systemd watchdog started with interval #{interval}ms")
    end
  end

  def notify_ready do
    if systemd_enabled?() do
      :systemd.notify(:ready)
      Logger.info("Notified systemd that service is ready")
    end
  end

  def handle_watchdog_ping do
    if systemd_enabled?() do
      :systemd.notify(:watchdog)
      interval = Application.get_env(:sysconfd, :systemd)[:watchdog_interval] * 1000
      Process.send_after(self(), :watchdog_ping, interval)
    end
  end

  defp systemd_enabled? do
    case Application.get_env(:sysconfd, :systemd) do
      nil -> false
      config -> config[:enabled]
    end
  end
end
