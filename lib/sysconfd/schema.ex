defmodule Sysconfd.Schema do
  require Logger



  def validate_config(config) do
    case get_schema() do
      {:ok, schema} ->
        case ExJsonSchema.Validator.validate(schema, config) do
          :ok -> {:ok, config}
          {:error, errors} ->
            Logger.error("Configuration validation failed: #{inspect(errors)}")
            {:error, errors}
        end
      {:error, reason} ->
        Logger.error("Failed to load schema: #{inspect(reason)}")
        {:error, :schema_load_failed}
    end
  end

  defp get_schema do
    try do
      case :persistent_term.get(:sysconfd_schema, nil) do
        nil -> load_schema()
        schema -> {:ok, schema}
      end
    rescue
      e ->
        Logger.error("Failed to get schema from persistent_term: #{inspect(e)}")
        load_schema()
    end
  end

  defp load_schema do
  schema_path = Application.app_dir(:sysconfd, "priv/schema/config_schema.json")
  case File.read(schema_path) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, schema} ->
            try do
              :persistent_term.put(:sysconfd_schema, schema)
              {:ok, schema}
            rescue
              e ->
                Logger.error("Failed to store schema in persistent_term: #{inspect(e)}")
                {:ok, schema}
            end
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end
end
