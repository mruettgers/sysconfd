defmodule Sysconfd.Template do
  require Logger

  def process_template(template_config, data, dir, delete_missing) do
    try do
      # Resolve template path relative to the config file location
      template_path = Path.join([dir, template_config["template"]])
      target_path = template_config["target"]

      case evaluate_condition(template_config["condition"], data) do
        true ->
          case File.read(template_path) do
            {:ok, template_content} ->
              # Ensure target directory exists
              target_dir = Path.dirname(target_path)
              case File.mkdir_p(target_dir) do
                :ok ->
                  # Create binding with sys, env, net directly accessible, and data containing custom data_sources
                  binding = create_binding(data)
                  try do
                    rendered = EEx.eval_string(template_content, binding)
                    File.write!(target_path, rendered)
                  rescue
                    e ->
                      Logger.error("Failed to parse template #{template_path}: #{inspect(e)}")

                  end
                {:error, reason} ->
                  Logger.error("Failed to create target directory #{target_dir}: #{inspect(reason)}")
              end
            {:error, reason} ->
              Logger.error("Failed to read template #{template_path}: #{inspect(reason)}")
          end
        false ->
          if delete_missing do
            try do
              File.rm(target_path)
            rescue
              e ->
                Logger.error("Failed to delete target file #{target_path}: #{inspect(e)}")
            end
          end
      end
    rescue
      e ->
        Logger.error("Unexpected error processing template #{inspect(template_config)}: #{inspect(e)}")
    end
  end

  defp evaluate_condition(nil, _data), do: true
  defp evaluate_condition(condition, data) when is_binary(condition) do
    try do
      # Create binding with sys, env, net directly accessible, and data containing custom data_sources
      # Same format as template binding for consistency
      binding = create_binding(data)

      {result, _} = Code.eval_string(condition, binding)
      result
    rescue
      e ->
        Logger.error("Failed to evaluate condition '#{condition}': #{inspect(e)}")
        false
    end
  end
  defp evaluate_condition(_condition, _data), do: true

  # Creates a binding with sys, env, net directly accessible for convenience,
  # and data containing only the custom data_sources (from config.json)
  defp create_binding(data) do
    [
      sys: Map.get(data, "sys"),
      env: Map.get(data, "env"),
      net: Map.get(data, "net"),
      data: Map.get(data, "custom", %{})
    ]
  end
end
