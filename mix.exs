defmodule Turnkey.MixProject do
  use Mix.Project

  def project do
    [
      app: :turnkey,
      version: "0.0.1-alpha2",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "TurnkeyEx",
      description: "TurnkeyEx is an unofficial client to the Turnkey API.",
      source_url: "https://github.com/legend-hq/turnkey-ex",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      package: package()
    ]
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*", "test/support"],
      maintainers: ["Coburn Berry", "Geoffrey Hayes"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/legend-hq/turnkey-ex"}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_), do: ["lib", "test/support"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.31.1", only: :dev, runtime: false},
      {:jason, "~> 1.2"},
      {:req, "~> 0.4.0"},
      {:plug_cowboy, "~> 2.6", except: [:prod]},
      {:cors_plug, "~> 3.0", except: [:prod]},
      {:corsica, "~> 2.1", except: [:prod]},
      {:elixir_uuid, "~> 1.2", except: [:prod]},
      {:signet, "~> 1.1.0"},
      {:httpoison, "~> 2.2"},
      {:goth, "~> 1.4", except: [:prod]}
    ]
  end
end
