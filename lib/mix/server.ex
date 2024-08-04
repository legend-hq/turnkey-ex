defmodule Mix.Tasks.Turnkey.Server do
  @shortdoc "Runs an insecure Turnkey server"

  @moduledoc ~S"""
  Starts an insecure Turnkey server. This can be used to enable
  testing of the Turnkey API.

  # Usage

  `mix turnkey.server --port 8888`
  """

  use Mix.Task
  use Signet.Hex

  @doc false
  def run(args) do
    Application.ensure_all_started([:hackney, :signet])

    case OptionParser.parse(args, strict: [port: :integer]) do
      {opts, _patterns = [], []} ->
        Turnkey.APIServer.Server.start_link(opts)
        :timer.sleep(:infinity)
    end
  end
end
