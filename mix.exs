defmodule Sysconfd.MixProject do
  use Mix.Project

  def project do
    [
      app: :sysconfd,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools, :eex],
      mod: {Sysconfd.Application, []}
    ]
  end


  defp releases do
    [
      sysconfd: [
        applications: [sysconfd: :permanent],
        steps: [
          :assemble
        ],
        include_executables_for: [:unix],
        include_erts: System.get_env("MIX_TARGET_INCLUDE_ERTS") || true
      ]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:ex_json_schema, "~> 0.10"},
      {:systemd, "~> 0.6"},
      {:dotenv, "~> 3.1"}
    ]
  end
end
