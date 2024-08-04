defmodule Turnkey.InstructerTest do
  use ExUnit.Case, async: true

  defmodule Attestation do
    @enforce_keys [:attestation_object, :client_data_json]
    defstruct @enforce_keys
  end

  defmodule Authenticator do
    @enforce_keys [:user_name, :attestation]
    defstruct @enforce_keys

    defmodule Attestation do
      @enforce_keys [:credential_id, :client_data_json]
      defstruct @enforce_keys
    end
  end

  # defining these for the doctest
  defmodule Cat do
    defstruct [:user_name, :friend]

    defmodule Dog do
      @enforce_keys [:bark, :bite]
      defstruct @enforce_keys
    end
  end

  doctest Turnkey.Instructer, import: true

  describe "instructify/3" do
    test "creates a struct with all required keys present" do
      authenticator_params = %{
        "user_name" => "test_user",
        "attestation" => %{"credential_id" => "abc123", "client_data_json" => "data"}
      }

      assert {:ok,
              %Authenticator{user_name: "test_user", attestation: %Authenticator.Attestation{}}} =
               Turnkey.Instructer.instructify(
                 authenticator_params,
                 {Authenticator, [attestation: Authenticator.Attestation]}
               )
    end

    test "returns an error when a required key is missing at top level" do
      incomplete_authenticator_params = %{
        "attestation" => %{"credential_id" => "abc123", "client_data_json" => "data"}
      }

      assert {
               :error,
               {:instructer_parsing_error,
                "the following keys must also be given when building struct Turnkey.InstructerTest.Authenticator: [:user_name] found only %{\"attestation\" => %Turnkey.InstructerTest.Authenticator.Attestation{credential_id: \"abc123\", client_data_json: \"data\"}} as %{\n  attestation: %Turnkey.InstructerTest.Authenticator.Attestation{\n    credential_id: \"abc123\",\n    client_data_json: \"data\"\n  }\n}"}
             } ==
               Turnkey.Instructer.instructify(
                 incomplete_authenticator_params,
                 {Authenticator, [attestation: Authenticator.Attestation]}
               )
    end

    test "returns an error when keys are missing on nested structs" do
      authenticator_params_with_missing_nested_keys = %{
        "user_name" => "test_user",
        # Missing 'client_data_json'
        "attestation" => %{"credential_id" => "abc123"}
      }

      assert Turnkey.Instructer.instructify(
               authenticator_params_with_missing_nested_keys,
               {Authenticator, [attestation: Authenticator.Attestation]}
             ) ==
               {:error,
                {:instructer_parsing_error,
                 "the following keys must also be given when building struct Turnkey.InstructerTest.Authenticator.Attestation: [:client_data_json] found only %{\"credential_id\" => \"abc123\"} as %{credential_id: \"abc123\"}"}}
    end

    test "can snakify an unnested struct" do
      attestation = %{
        "attestationObject" =>
          "o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YVikSZYN5YgOjGh0NBcPZHZgW4_krrmihjLHmVzzuoMdl2NFAAAAAK3OAAI1vMYKZIsLJfHwVQMAIFxvpL6wGshO38ZskUWO_pcj2-JaqETbjzDrhURchbxhpQECAyYgASFYIL3bKI7KFijoBcQyMezliBQiqbVMMdJURcBqyYpEz0o8Ilgg6LqqMQM3GeRj4DJKOXUbp9pphOrSCWukGE-o6HVCvGQ",
        "clientDataJson" =>
          "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoiQnd6RVZOczdXUVNlXzVDQ1pnM2Fmd3pkQkN3dTlHODFuYWNXaDI0NWZmQSIsIm9yaWdpbiI6Imh0dHA6Ly9sb2NhbGhvc3Q6NDQzMyIsImNyb3NzT3JpZ2luIjpmYWxzZSwib3RoZXJfa2V5c19jYW5fYmVfYWRkZWRfaGVyZSI6ImRvIG5vdCBjb21wYXJlIGNsaWVudERhdGFKU09OIGFnYWluc3QgYSB0ZW1wbGF0ZS4gU2VlIGh0dHBzOi8vZ29vLmdsL3lhYlBleCJ9",
        "credentialId" => "XG-kvrAayE7fxmyRRY7-lyPb4lqoRNuPMOuFRFyFvGE",
        "transports" => ["AUTHENTICATOR_TRANSPORT_INTERNAL"]
      }

      {:ok, a} = Turnkey.Instructer.instructify(attestation, Attestation, true)
      assert a.attestation_object == Map.get(attestation, "attestationObject")
    end
  end
end
