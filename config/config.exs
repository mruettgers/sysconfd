import Config

config :logger,
  level: :debug

config :sysconfd,
  auto_run: true,
  services_dir: "/usr/lib/sysconfd/services",
  system_data_base_path: "/",
  systemd: [
    enabled: false,
    watchdog_interval: 15
  ],
  global_data_sources: [
#    %{
#      "key" => "device",
#      "path" => "/data/config/device.json",
#      "type" => "json"
#    }
  ]

import_config "#{config_env()}.exs"
