defmodule Sysconfd.DataSource do
  require Logger

  def load_data_sources(sources, base_dir) do
    sources
    |> Enum.reduce(%{}, fn source, acc ->
      path = source["path"]
      full_path = if Path.type(path) == :relative do
        Path.join(base_dir, path)
      else
        path
      end
      Logger.info("Loading data source #{full_path} of type #{source["type"]}")
      data = load_source(full_path, source["type"])
      Map.put(acc, source["key"], data)
    end)
  end

  defp read_file(path) do
    case File.read(path) do
      {:ok, content} -> {:ok, content}
      {:error, reason} ->
        Logger.error("Failed to read file #{path}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def get_value_from_file(path) do
    case read_file(path) do
      {:ok, value} -> String.trim(value)
      {:error, _} -> nil
    end
  end

  def get_device_tree_value(path) do
    case read_file(path) do
      {:ok, value} ->
        value
        |> String.trim_trailing("\x00")
        |> String.trim()
      {:error, _} -> nil
    end
  end

  def load_source(path, "json") do
    case read_file(path) do
      {:ok, content} ->
        try do
          {:ok, Jason.decode!(content)}
        rescue
          e ->
            Logger.error("Failed to parse JSON from #{path}: #{inspect(e)}")
            {:error, e}
        end
      {:error, _} -> {:error, :file_read_error}
    end
    |> case do
      {:ok, data} -> data
      {:error, _} -> %{}
    end
  end

  def load_source(path, "env") do
    try do
      {:ok, Dotenv.load(path)}
    rescue
      e ->
        Logger.error("Failed to parse env file #{path}: #{inspect(e)}")
        {:error, e}
    end
    |> case do
      {:ok, data} -> data
      {:error, _} -> %{}
    end
  end

  def load_source(path, "text") do
    case read_file(path) do
      {:ok, content} -> content
      {:error, _} -> ""
    end
  end

  def load_source(_path, type) do
    Logger.error("Unsupported data source type: #{type}")
    %{}
  end

end
