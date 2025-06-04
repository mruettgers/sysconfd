defmodule Sysconfd.DataSources.Environment do
  @moduledoc """
  Provides environment variables that are available under the 'env' key in templates.
  """

  def get_environment_values do
    System.get_env()
    |> Enum.map(fn {k, v} -> {k, v} end)
    |> Map.new()
  end
end
