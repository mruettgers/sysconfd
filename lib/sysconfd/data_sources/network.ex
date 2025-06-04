defmodule Sysconfd.DataSources.Network do
  @moduledoc """
  Provides network interface information that is available under the 'net' key in templates.
  """

  def get_network_values do
    %{
      "interfaces" => get_interface_info()
    }
  end

  defp get_interface_info do
    case :inet.getifaddrs() do
      {:ok, interfaces} ->
        interfaces
        |> Enum.filter(fn {name, _} -> name != ~c"lo" end)  # Exclude loopback interface
        |> Enum.map(fn {name, opts} ->
          mac = opts
          |> Keyword.get(:hwaddr, [])
          |> Enum.map(&:io_lib.format("~2.16.0b", [&1]))
          |> Enum.join(":")
          |> case do
            "" -> "unknown"
            mac -> mac
          end

          {to_string(name), %{
            "mac" => mac
          }}
        end)
        |> Map.new()

      {:error, _} ->
        %{}
    end
  end
end
