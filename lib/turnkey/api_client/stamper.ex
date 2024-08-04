defmodule Turnkey.APIClient.Stamper do
  @moduledoc """
  Generates an api key stamp header for turnkey api requests, which is built by signing the entire
  body of a post request with the api key.
  """
  @turnkey_api_signature_scheme "SIGNATURE_SCHEME_TK_API_P256"

  def stamp(message) do
    encoded = Jason.encode!(message)

    {public_key_hex, private_key_binary} =
      Application.get_env(:turnkey, :credentials)

    stamp_with(encoded, {public_key_hex, private_key_binary})
  end

  @doc """
  Generates a Base64URL-encoded Turnkey Stamp with the given message and key tuple.

  ## Examples
  iex> import Turnkey.APIClient.Stamper, only: [stamp_with: 2]
  iex> tk_public_key = "0371dd5ab2de3ba282ec0d5ee32a5425acd9280a1d70c5bb0e04d5c26d8ce04c41"
  iex> tk_private_key = "f2c9fa33bb68809f0c716542aa4fe2b5ee536f0472fbfce482f4a7b931d42fe0" |> Base.decode16!(case: :lower)
  iex> message = ~s<{"organizationId": "105d7217-3600-42b5-a818-226efdb25019"}>
  iex> stamp = stamp_with(message, { tk_public_key, tk_private_key })
  iex> %{public_key: tk_public_key, scheme: "SIGNATURE_SCHEME_TK_API_P256", signature: signature} = stamp
  ...> |> Base.url_decode64!(padding: false)
  ...> |> Jason.decode!(keys: :atoms)
  iex> pk_bytes = Base.decode16!(tk_public_key, case: :lower)
  iex> :crypto.verify(:ecdsa, :sha256, message, Base.decode16!(signature), [pk_bytes, :secp256r1])
  true

  Note: The actual return value of `encoded_stamp` is not shown here because it is
  non-deterministic due to the cryptographic signing process.
  """
  def stamp_with(message, {public_key, private_key}) do
    mac = :crypto.sign(:ecdsa, :sha256, message, [private_key, :secp256r1])

    %{
      public_key: public_key,
      signature: Base.encode16(mac),
      scheme: @turnkey_api_signature_scheme
    }
    |> Jason.encode!()
    |> Base.url_encode64(padding: false)
  end
end
