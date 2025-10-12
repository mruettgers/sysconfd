defmodule Sysconfd.DataSources.System do
  @moduledoc """
  Provides system values that are available under the 'sys' key in templates.
  """

  alias Sysconfd.DataSource

  def get_system_values do
    base_path = Application.get_env(:sysconfd, :system_data_base_path, "/")

    %{
      "board_name" => get_value(base_path, "/sys/class/dmi/id/board_name"),
      "board_vendor" => get_value(base_path, "/sys/class/dmi/id/board_vendor")
    }
  end

  defp get_value(base_path, path) do
    full_path = Path.join(base_path, path)
    DataSource.get_value_from_file(full_path)
  end
end
