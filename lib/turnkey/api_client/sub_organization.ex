defmodule Turnkey.APIClient.SubOrganization do
  @moduledoc """
    Turnkey Sub Organizations allow for a permissioning model where our users
    have control over their keys and our api key has read access only.

    https://docs.turnkey.com/api#tag/Organizations
  """

  alias Turnkey.APITypes.{
    CreateActivity,
    CreateSubOrganizationIntentV4,
    CreateSubOrganizationResultV4,
    RootUser,
    Authenticator,
    Wallet
  }

  defmodule TrimmedResult do
    @moduledoc """
    A struct for shaping the turnkey result + request towards our needs,
    since the activity is too hefty but the Result doesn't have everything we need.
    """

    defstruct [:raw_activity, :sub_organization_id, :signer_address, :credential_id]
  end

  @api_client Application.compile_env(:turnkey, :http_client, Turnkey.APIClient)

  @create_route "/public/v1/submit/create_sub_organization"
  @activity_type_create_suborganization "ACTIVITY_TYPE_CREATE_SUB_ORGANIZATION_V4"

  @doc """
  All users are given a suborganization controlled by their passkey ( authenticator_params ).
  It is created with a single Ethereum private key.
  Our api key retains read access.

  This is an asyncronous activity, so the activity is polled until completion.
  """
  @spec create_sub_organization_from_authenticator(String.t(), Authenticator.t()) ::
          {:ok, TrimmedResult.t()}
          | {:error, {:instructer_parse_error, String.t()}}
          | {:error, String.t()}
  def create_sub_organization_from_authenticator(email, %Authenticator{} = authenticator) do
    organization_id =
      Application.get_env(:turnkey, :organization_id)

    # Meat on Bone: If we extend this client to other activities, it may be proper
    # to have the activity module control the wrapper and the intent modules
    # pass in "parameters" and the type be inferred from the given parameter struct (or just passed in)
    # For the moment, it is nice to see the whole body in one place.
    payload = %CreateActivity{
      type: @activity_type_create_suborganization,
      timestampMs: DateTime.utc_now() |> DateTime.to_unix(:millisecond) |> Integer.to_string(),
      organizationId: organization_id,
      parameters: %CreateSubOrganizationIntentV4{
        subOrganizationName: email,
        disableEmailRecovery: false,
        rootUsers: [
          %RootUser{
            # TODO: get name from account?
            userName: email,
            userEmail: email,
            apiKeys: [],
            authenticators: [authenticator]
          }
        ],
        rootQuorumThreshold: 1,
        wallet: %Wallet{
          walletName: "Default EVM Wallet",
          accounts: [
            %Wallet.Account{
              curve: "CURVE_SECP256K1",
              pathFormat: "PATH_FORMAT_BIP32",
              # if we want more keys, we can increment the path
              path: "m/44'/60'/0'/0/0",
              addressFormat: "ADDRESS_FORMAT_ETHEREUM"
            }
          ]
        }
      }
    }

    with {:ok, %{"result" => %{"createSubOrganizationResultV4" => result}} = full_activity} <-
           @api_client.post(@create_route, payload, poll: true),
         {:ok, %CreateSubOrganizationResultV4{} = r} <-
           Turnkey.Instructer.instructify(
             result,
             {CreateSubOrganizationResultV4, wallet: CreateSubOrganizationResultV4.Wallet}
           ) do
      {:ok,
       %TrimmedResult{
         raw_activity: full_activity,
         sub_organization_id: r.subOrganizationId,
         signer_address: Enum.at(r.wallet.addresses, 0),
         credential_id: authenticator.attestation.credentialId
       }}
    end
  end
end
