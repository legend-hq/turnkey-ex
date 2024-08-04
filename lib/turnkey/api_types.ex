defmodule Turnkey.APITypes do
  @moduledoc """
  Just some simple structs to give a little more flavor and confidence to the api interactions
  """

  defmodule CreateActivity do
    @moduledoc """
    The root of a creation payload
    """
    @derive Jason.Encoder
    @enforce_keys [
      :type,
      :timestampMs,
      :organizationId,
      :parameters
    ]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            type: String.t(),
            timestampMs: String.t(),
            organizationId: String.t(),
            parameters: CreateSubOrganizationIntentV4.t()
          }
  end

  defmodule CreateSubOrganizationIntentV4 do
    @type t :: %__MODULE__{
            subOrganizationName: String.t(),
            rootUsers: list(RootUser.t()),
            rootQuorumThreshold: integer(),
            wallet: Wallet.t(),
            disableEmailRecovery: boolean()
          }

    @derive Jason.Encoder
    @enforce_keys [
      :subOrganizationName,
      :rootUsers,
      :rootQuorumThreshold,
      :wallet,
      :disableEmailRecovery
    ]
    defstruct @enforce_keys
  end

  defmodule RootUser do
    @type t :: %__MODULE__{
            userName: String.t(),
            userEmail: String.t(),
            apiKeys: list(ApiKey.t()),
            authenticators: list(Authenticator.t())
          }

    @derive Jason.Encoder
    @enforce_keys [
      :userName,
      :userEmail,
      :apiKeys,
      :authenticators
    ]
    defstruct @enforce_keys
  end

  defmodule ApiKey do
    @type t :: %__MODULE__{
            apiKeyName: String.t(),
            publicKey: String.t()
          }

    @derive Jason.Encoder
    @enforce_keys [
      :apiKeyName,
      :publicKey
    ]
    defstruct @enforce_keys
  end

  defmodule Authenticator do
    @type t :: %__MODULE__{
            authenticatorName: String.t(),
            challenge: String.t(),
            attestation: Attestation.t()
          }

    @derive Jason.Encoder
    @enforce_keys [
      :authenticatorName,
      :challenge,
      :attestation
    ]
    defstruct @enforce_keys

    defmodule Attestation do
      @type t :: %__MODULE__{
              credentialId: String.t(),
              clientDataJson: String.t(),
              attestationObject: String.t(),
              transports: list(String.t())
            }

      @derive Jason.Encoder
      @enforce_keys [
        :credentialId,
        :clientDataJson,
        :attestationObject,
        :transports
      ]
      defstruct @enforce_keys
    end
  end

  defmodule Wallet do
    @type t :: %__MODULE__{
            walletName: String.t(),
            accounts: list(Account.t())
          }

    @derive Jason.Encoder
    @enforce_keys [
      :walletName,
      :accounts
    ]
    defstruct @enforce_keys

    defmodule Account do
      @type t :: %__MODULE__{
              curve: String.t(),
              pathFormat: String.t(),
              path: String.t(),
              addressFormat: String.t()
            }

      @derive Jason.Encoder
      @enforce_keys [
        :curve,
        :pathFormat,
        :path,
        :addressFormat
      ]
      defstruct @enforce_keys
    end
  end

  defmodule CreateSubOrganizationResultV4 do
    @moduledoc """
    The wrapper for a turnkey activity requests result
    e.g. %{ 
    "subOrganizationId" => "5d0ef3dc-e8f9-4d51-bc90-76bf24599c9a",
    "wallet" => %{
      "addresses" => ["0xC63C30d1227fD5568a99807D285e3ffFFa246c8d"],
      "walletId" => "c384284a-849c-5158-934c-4f497bcff731"
    }
    """
    @enforce_keys [:subOrganizationId, :wallet]
    defstruct @enforce_keys

    defmodule Wallet do
      @enforce_keys [:addresses, :walletId]
      defstruct @enforce_keys
    end
  end

  defmodule InitUserEmailRecoveryIntent do
    @moduledoc """
    The wrapper for initializing user email recovery intent
    e.g. %{
    "email" => "example@example.com",
    "targetPublicKey" => "abc123def456...",
    "expirationSeconds" => "3600"
    }
    """
    @enforce_keys [:email, :targetPublicKey, :expirationSeconds]
    @derive Jason.Encoder
    defstruct @enforce_keys
  end

  defmodule InitUserEmailRecoveryResult do
    @moduledoc """
    The wrapper for the result of an init user email recovery action
    e.g. %{
    "userId" => "a1b2c3d4-e5f6-7890-g1h2-i3j4k5l6m7n8"
    }
    """
    @enforce_keys [:userId]
    defstruct @enforce_keys
  end

  defmodule RecoverUserIntent do
    @moduledoc """
    The Intent or recovering a user.
    Sent by the user when recovering. We have it for parsing the intent when reading bach the activity.
    e.g. %{
    "authenticator": {
      "authenticatorName": "string",
      "challenge": "string",
      "attestation": {}
      },
    "userId": "string"
    }
    """
    @type t :: %__MODULE__{
            userId: String.t(),
            authenticator: Authenticator.t()
          }
    @enforce_keys [:userId, :authenticator]
    defstruct @enforce_keys
  end

  defmodule ListActivitiesRequest do
    @moduledoc """
    Represents a request for user activity.
    """
    @type t :: %__MODULE__{
            organizationId: String.t(),
            filterByStatus: list(String.t()),
            paginationOptions: %__MODULE__.PaginationOptions{},
            filterByType: list(String.t())
          }

    @derive Jason.Encoder
    @enforce_keys [:organizationId, :filterByStatus, :paginationOptions, :filterByType]
    defstruct @enforce_keys

    defmodule PaginationOptions do
      @type t :: %__MODULE__{
              limit: String.t(),
              before: String.t(),
              after: String.t()
            }

      @derive Jason.Encoder
      @enforce_keys [:limit, :before, :after]
      defstruct @enforce_keys
    end
  end
end
