defmodule TurnkeyMock do
  require Logger

  defmodule Persistance do
    @persistance Keyword.get(
                   Application.compile_env(:turnkey, :server, []),
                   :persistance,
                   :memory
                 )

    # Store a value to persistance mechanism
    def store!(key, value), do: store!(@persistance, key, value)

    defp store!(:memory, key, value),
      do: Agent.update(get_or_start_agent(), &Map.put(&1, key, value))

    defp store!(:disk, key, value), do: store!({:disk, default_file_path()}, key, value)

    defp store!({:disk, path}, key, value),
      do: File.write!(Path.join([ensure_path!(path), key]), value)

    # Load a value from persistence mechanism
    def load!(key), do: load!(@persistance, key)

    defp load!(:memory, key), do: Agent.get(get_or_start_agent(), &Map.get(&1, key))
    defp load!(:disk, key), do: load!({:disk, default_file_path()}, key)
    defp load!({:disk, path}, key), do: File.read!(Path.join([ensure_path!(path), key]))

    # Default file path for file storage
    defp default_file_path, do: Path.join([File.cwd!(), ".turnkey"])

    # mkdir -p
    defp ensure_path!(path) do
      File.mkdir_p!(path)
      path
    end

    # Get or start agent for in-memory storage
    defp get_or_start_agent() do
      case Process.whereis(__MODULE__) do
        nil ->
          Agent.start_link(fn -> %{} end, name: __MODULE__)

        pid ->
          pid
      end
    end
  end

  defmodule CORS do
    use Corsica.Router,
      origins: "*",
      log: [rejected: :error, invalid: :warn, accepted: :debug],
      allow_credentials: true,
      allow_headers: :all

    resource("/*")
  end

  # Note: Turnkey's own API doesn't properly set its content
  #       headers, so here we parse text/plain as JSON.
  defmodule PlaintextJsonParser do
    def init(opts), do: Plug.Parsers.JSON.init(opts)

    def parse(conn, "text", "plain", params, opts) do
      Plug.Parsers.JSON.parse(conn, "application", "json", params, opts)
    end

    def parse(conn, _type, _subtype, _params, _opts), do: {:next, conn}
  end

  defmodule Router do
    use Plug.Router
    use Plug.ErrorHandler
    use Plug.Debugger

    import TurnkeyMock.Persistance

    plug(Plug.Parsers,
      parsers: [:json, TurnkeyMock.PlaintextJsonParser],
      json_decoder: Jason
    )

    plug(:match)
    plug(:dispatch)

    # Handles creating a new sub-organization
    post "/public/v1/submit/create_sub_organization" do
      sub_organization_id = UUID.uuid4()
      {address, priv_key} = Signet.Keys.generate_keypair()

      store!(sub_organization_id, Signet.Hex.encode_hex(priv_key))

      json(
        conn,
        Turnkey.Fixtures.sample_sub_organization_create(%{
          sub_organization_id: sub_organization_id,
          ethereum_address: Signet.Hex.encode_hex(address)
        })
      )
    end

    post "/public/v1/submit/sign_raw_payload" do
      %{
        "organizationId" => organization_id,
        "parameters" =>
          parameters = %{
            "signWith" => sign_with,
            "payload" => payload,
            "encoding" => "PAYLOAD_ENCODING_HEXADECIMAL",
            "hashFunction" => hash_function_input
          }
      } = conn.body_params

      _hash_function =
        case hash_function_input do
          "HASH_FUNCTION_KECCAK256" ->
            :sha3

            # TODO: Support no_op
            # "HASH_FUNCTION_NO_OP" ->
            #  :no_op
        end

      {:ok, priv_key} = Signet.Hex.decode_hex(load!(organization_id))
      {:ok, signer} = Signet.Hex.decode_hex(sign_with)
      {:ok, ^signer} = Signet.Signer.Curvy.get_address(priv_key)
      {:ok, payload_raw} = Signet.Hex.decode_hex(payload)
      {:ok, sig} = Signet.Signer.Curvy.sign(payload_raw, priv_key)
      {:ok, recid} = Signet.Recover.find_recid(payload_raw, sig, signer)

      json(conn, %{
        activity: %{
          id: UUID.uuid4(),
          organizationId: organization_id,
          status: "ACTIVITY_STATUS_COMPLETED",
          type: "ACTIVITY_TYPE_SIGN_RAW_PAYLOAD_V2",
          intent: %{
            signRawPayloadIntentV2: parameters
          },
          result: %{
            signRawPayloadResult: %{
              r: Base.encode16(Signet.Util.encode_bytes(sig.r, 32)),
              s: Base.encode16(Signet.Util.encode_bytes(sig.s, 32)),
              v: Base.encode16(Signet.Util.encode_bytes(recid, 1))
            }
          }
        }
      })
    end

    post "/public/v1/query/list_activities" do
      # for checking for user recovery actions
      # and re-sycning the passkey to our system
      activities = %{
        "activities" => [
          %{
            "intent" => %{
              "recoverUserIntent" => %{
                "authenticator" => %{
                  "attestation" => %{
                    "attestationObject" =>
                      "o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YVikSZYN5YgOjGh0NBcPZHZgW4_krrmihjLHmVzzuoMdl2NBAAAAAK3OAAI1vMYKZIsLJfHwVQMAIFm1eyKTRG2GQxShWNNcuHC_qvTo5gxveNuKDEj2x1ubpQECAyYgASFYIG5XW3e1LNwaWq8p1wRTiK33bf4ILwKO5Amve7zRdccoIlgg05oD4K15FOpQC19C-U3jCcb823_dqSJN-bchule-AIU",
                    "clientDataJson" =>
                      "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoiRUFQSWRHRGl4OUNmTk5RMGpGR0FaWU1tUGZpTHpPRk9VN21mRm5vT3FZUSIsIm9yaWdpbiI6Imh0dHA6Ly9sb2NhbGhvc3Q6NDQ2NiIsImNyb3NzT3JpZ2luIjpmYWxzZX0",
                    "credentialId" => "WbV7IpNEbYZDFKFY01y4cL-q9OjmDG9424oMSPbHW5s",
                    "transports" => ["AUTHENTICATOR_TRANSPORT_INTERNAL"]
                  },
                  "authenticatorName" => "coburn+1@legend.xyz",
                  "challenge" => "EAPIdGDix9CfNNQ0jFGAZYMmPfiLzOFOU7mfFnoOqYQ"
                },
                "userId" => "43c9aec7-2975-4438-9a3a-7acc38975631"
              }
            },
            "organizationId" => "ce27595d-b7df-41e2-84ed-435642984f9d",
            "result" => %{
              "recoverUserResult" => %{
                "authenticatorId" => ["1d7328e5-ef62-4f11-8ea5-7a8029a0ccf3"]
              }
            },
            "status" => "ACTIVITY_STATUS_COMPLETED",
            "type" => "ACTIVITY_TYPE_RECOVER_USER"
          }
        ]
      }

      json(conn, activities)
    end

    post "/public/v1/submit/init_user_email_recovery" do
      json(
        conn,
        %{
          "activity" => %{
            "intent" => %{
              "initUserEmailRecoveryIntent" => %{
                "email" => "coburn+1@legend.xyz",
                "expirationSeconds" => "3600",
                "targetPublicKey" =>
                  "v491b14c90bb54632eb6c26a17a78cc4263fa090e81797453023b18745dd0905e88a6c7d7d53ef554ca661c30cacf28c9e6af8b46a38c9fecbcca72518b2374e20"
              }
            },
            "organizationId" => "ce27595d-b7df-41e2-84ed-435642984f9d",
            "result" => %{
              "initUserEmailRecoveryResult" => %{
                "userId" => "43c9aec7-2975-4438-9a3a-7acc38975631"
              }
            },
            "status" => "ACTIVITY_STATUS_COMPLETED",
            "type" => "ACTIVITY_TYPE_INIT_USER_EMAIL_RECOVERY"
          }
        }
      )
    end

    defp handle_errors(conn, e = %{kind: _kind, reason: _reason, stack: _stack}) do
      send_resp(conn, conn.status, "Turnkey Mock Server Error: #{inspect(e, limit: :infinity)}")
    end

    defp json(conn, resp) do
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> send_resp(200, Jason.encode!(resp))
    end
  end

  defmodule Server do
    use Plug.Builder

    plug(TurnkeyMock.CORS)
    plug(TurnkeyMock.Router)
  end

  def start_link(opts \\ []) do
    port = Keyword.get(opts, :port, 10110)
    Logger.warning("Turnkey Mock started on port #{port}")
    {:ok, pid} = Plug.Cowboy.http(Server, [], port: port)

    if port == 0 do
      real_port =
        pid
        |> Supervisor.which_children()
        |> List.keyfind(:ranch_conns_sup, 0)
        |> elem(1)
        |> :sys.get_state()
        |> elem(0)
        |> elem(2)
        |> :ranch_server.get_addr()
        |> elem(1)

      Application.put_env(:turnkey, :api_url, "http://localhost:#{real_port}")
    end

    {:ok, pid}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
