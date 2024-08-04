defmodule Turnkey.APIClient.Signer do
  @moduledoc """
  Turnkey client for signing data

  https://docs.turnkey.com/api#tag/Signers/operation/SignRawPayload
  """

  @sign_route "/public/v1/submit/sign_raw_payload"

  @doc """
  Signs the given payload using the given key.

  TODO: How do we provide a Webauthn sig?
  """
  @spec sign(String.t(), <<_::160>>, binary(), Keyword.t()) ::
          {:ok, %{v: integer(), r: <<_::256>>, s: <<_::256>>}} | {:error, term()}
  def sign(organization_id, signer = <<_::160>>, payload, opts \\ []) when is_binary(payload) do
    hash_function =
      case Keyword.get(opts, :hash_function, :sha3) do
        :sha3 ->
          "HASH_FUNCTION_KECCAK256"

        :no_op ->
          "HASH_FUNCTION_NO_OP"
      end

    with {:ok, activity} <-
           Turnkey.APIClient.post(@sign_route, %{
             "organizationId" => organization_id,
             "parameters" => %{
               "signWith" => "0x" <> Base.encode16(signer),
               "payload" => "0x" <> Base.encode16(payload),
               "encoding" => "PAYLOAD_ENCODING_HEXADECIMAL",
               "hashFunction" => hash_function
             }
           }) do
      %{
        "activity" => %{
          "result" => %{
            "signRawPayloadResult" => %{
              "r" => r,
              "s" => s,
              "v" => v
            }
          }
        }
      } = activity

      {:ok,
       %{
         v: :binary.decode_unsigned(Base.decode16!(v)),
         r: Base.decode16!(r),
         s: Base.decode16!(s)
       }}
    end
  end
end
