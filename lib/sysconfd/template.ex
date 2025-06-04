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
                  # Convert data map to keyword list for EEx
                  binding = data
                    |> Map.to_list()
                    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
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
      binding = [
        sys: data["sys"],
        env: data["env"],
        data: Map.drop(data, ["sys", "env"])
      ]

      {result, _} = Code.eval_string(condition, binding)
      result
    rescue
      e ->
        Logger.error("Failed to evaluate condition '#{condition}': #{inspect(e)}")
        false
    end
  end
  defp evaluate_condition(_condition, _data), do: true
end
