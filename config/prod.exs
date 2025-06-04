import Config

config :logger,
  level: :info

config :sysconfd,
  services_dir: "/usr/lib/sysconfd/services/",
  systemd: [
    enabled: true,
    watchdog_interval: 15
  ]
