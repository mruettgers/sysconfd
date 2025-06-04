import Config

if config_env() == :prod do
  config :sysconfd,
    services_dir: System.get_env("SYSCONFD_SERVICES_DIR", "/usr/lib/sysconfd/services"),
    systemd: [
      enabled: System.get_env("SYSCONFD_SYSTEMD_ENABLED", "false") == "true",
      watchdog_interval: String.to_integer(System.get_env("SYSCONFD_WATCHDOG_INTERVAL", "15"))
    ]
  config :logger,
    level: String.to_existing_atom(System.get_env("SYSCONFD_LOG_LEVEL", "info"))
end
