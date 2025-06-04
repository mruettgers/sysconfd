defmodule Sysconfd.Processor do
  require Logger

  def run_all do
    if Application.get_env(:sysconfd, :auto_run, true) do
      try do
        services_dir = Path.absname(Application.get_env(:sysconfd, :services_dir))

        Logger.info("Looking for service configurations in #{services_dir}")

        service_configs = Path.wildcard(services_dir <> "/*/config.json")

        Enum.each(
          service_configs,
          fn config_path ->
            try do
              process_config(config_path)
            rescue
              e ->
                Logger.error("Failed to process config #{config_path}: #{inspect(e)}")
            end
          end
        )

        Logger.info("All service configurations processed.")
      rescue
        e ->
          Logger.error("Failed to process service configurations: #{inspect(e)}")
      end
    else
      Logger.info("Sysconfd auto-run is disabled.")
    end

    :systemd.notify(:ready)
  end

  defp process_config(config_path) do
    base_dir = Path.dirname(config_path)

    case File.read(config_path) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, config} ->
            case Sysconfd.Schema.validate_config(config) do
              {:ok, validated_config} ->
                process_service_config(validated_config, base_dir)

              {:error, _} ->
                Logger.error("Skipping invalid configuration in #{config_path}")
            end

          {:error, reason} ->
            Logger.error("Failed to parse config #{config_path}: #{inspect(reason)}")
        end

      {:error, reason} ->
        Logger.error("Failed to read config #{config_path}: #{inspect(reason)}")
    end
  end

  defp process_service_config(config, base_dir) do
    data = %{}
    |> Map.merge(load_global_data_sources())
    |> Map.merge(Sysconfd.DataSource.load_data_sources(config["data_sources"] || [], base_dir))
    |> Map.put("sys", Sysconfd.DataSources.System.get_system_values())
    |> Map.put("env", Sysconfd.DataSources.Environment.get_environment_values())
    |> Map.put("net", Sysconfd.DataSources.Network.get_network_values())

    Logger.debug("Data sources loaded: #{inspect(data)}")

    # Process templates
    (config["templates"] || [])
    |> Enum.each(fn template_config ->
      Sysconfd.Template.process_template(
        template_config,
        data,
        base_dir,
        config["delete_missing"] || true
      )
    end)
  end

  defp load_global_data_sources do
    global_sources = Application.get_env(:sysconfd, :global_data_sources, [])

    Enum.reduce(global_sources, %{}, fn source, acc ->
      path = source["path"]
      Logger.info("Loading global data source #{path} of type #{source["type"]}")
      data = Sysconfd.DataSource.load_source(path, source["type"])
      Map.put(acc, source["key"], data)
    end)
  end
end
