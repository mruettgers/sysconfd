import Config

config :sysconfd,
  services_dir: "dev/services",
  system_data_base_path: "dev",
  systemd: [
    enabled: System.get_env("SYSCONFD_SYSTEMD_ENABLED", "false") == "true",
    watchdog_interval: String.to_integer(System.get_env("SYSCONFD_WATCHDOG_INTERVAL", "15"))
  ]
