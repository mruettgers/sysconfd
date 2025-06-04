defmodule Sysconfd.Systemd do
  @moduledoc """
  Handles systemd integration including notifications.
  """

  require Logger

  def notify_ready do
    if systemd_enabled?() do
      :systemd.notify(:ready)
      Logger.info("Notified systemd that service is ready")
    end
  end

  defp systemd_enabled? do
    case Application.get_env(:sysconfd, :systemd) do
      nil -> false
      config -> config[:enabled]
    end
  end
end
