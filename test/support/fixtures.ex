defmodule Turnkey.Fixtures do
  def sample_authenticator() do
    %{
      "attestation" => %{
        "attestationObject" =>
          "o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YVikSZYN5YgOjGh0NBcPZHZgW4_krrmihjLHmVzzuoMdl2NFAAAAAK3OAAI1vMYKZIsLJfHwVQMAIEWDUtlK2oIGvMZtTJOqPJ3e0L7fy237pDsmmgX6lZgmpQECAyYgASFYIH_KBmEEIjmE8GQ8Q2jZMN_Bz4YNHc2eLtdBF_i4dFzDIlggY00UuJq97lcCWVrNjqssBvX_8QCqecIYGaS8m1UdSH0",
        "clientDataJson" =>
          "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoiaE5ra09IYV9HOWJSa2pENC00QWY3dURSTFNFMi1aNC1YOXZWTVR0QnJiVSIsIm9yaWdpbiI6Imh0dHA6Ly9sb2NhbGhvc3Q6NDQzMyIsImNyb3NzT3JpZ2luIjpmYWxzZX0",
        "credentialId" => "RYNS2Uragga8xm1Mk6o8nd7Qvt_LbfukOyaaBfqVmCY",
        "transports" => ["AUTHENTICATOR_TRANSPORT_INTERNAL"]
      },
      "authenticatorName" => "qwffqwpqwfp",
      "challenge" => "hNkkOHa_G9bRkjD4-4Af7uDRLSE2-Z4-X9vVMTtBrbU"
    }
  end

  def sample_sub_organization_create(attrs \\ %{}) do
    %{
      "activity" => %{
        "canApprove" => false,
        "canReject" => true,
        "createdAt" => %{"nanos" => "0", "seconds" => "1701400647"},
        "fingerprint" =>
          "sha256:a26bb8ff1a480362df8f79911b7c1396aadb466a933fbfa07acd86a47cf93ce2",
        "id" => Map.get(attrs, :activity_id, "c53274c7-cce7-4f23-b8de-272bdb782911"),
        "intent" => %{
          "createSubOrganizationIntentV4" => %{
            "disableEmailRecovery" => false,
            "rootQuorumThreshold" => 1,
            "rootUsers" => [
              %{
                "apiKeys" => [],
                "authenticators" => [
                  sample_authenticator()
                ],
                "userEmail" => "a@b.com",
                "userName" => "a@b.com"
              }
            ],
            "subOrganizationName" => "a@b.com",
            "wallet" => %{
              "accounts" => [
                %{
                  "addressFormat" => "ADDRESS_FORMAT_ETHEREUM",
                  "curve" => "CURVE_SECP256K1",
                  "path" => "m/44'/60'/0'/0/0",
                  "pathFormat" => "PATH_FORMAT_BIP32"
                }
              ],
              "walletName" => "Default EVM Wallet"
            }
          }
        },
        "organizationId" =>
          Map.get(attrs, :organization_id, "105d7217-3600-42b5-a818-226efdb25019"),
        "result" => %{
          "createSubOrganizationResultV4" => %{
            "subOrganizationId" =>
              Map.get(attrs, :sub_organization_id, "5d0ef3dc-e8f9-4d51-bc90-76bf24599c9a"),
            "wallet" => %{
              "addresses" => [
                Map.get(attrs, :ethereum_address, "0xC63C30d1227fD5568a99807D285e3ffFFa246c8d")
              ],
              "walletId" => Map.get(attrs, :wallet_id, "c384284a-849c-5158-934c-4f497bcff731")
            }
          }
        },
        "status" => "ACTIVITY_STATUS_COMPLETED",
        "type" => "ACTIVITY_TYPE_CREATE_SUB_ORGANIZATION_V4",
        "updatedAt" => %{"nanos" => "0", "seconds" => "1701400647"},
        "votes" => [
          %{
            "activityId" => Map.get(attrs, :activity_id, "c53274c7-cce7-4f23-b8de-272bdb782911"),
            "createdAt" => %{"nanos" => "0", "seconds" => "1701400647"},
            "id" => "6ef575f5-cba6-4908-b317-c8f214927b2c",
            "message" =>
              "{\"type\":\"ACTIVITY_TYPE_CREATE_SUB_ORGANIZATION_V4\",\"parameters\":{\"subOrganizationName\":\"a@b.com\",\"disableEmailRecovery\":false,\"rootUsers\":[{\"userName\":\"a@b.com\",\"userEmail\":\"a@b.com\",\"apiKeys\":[],\"authenticators\":[{\"attestation\":{\"credentialId\":\"RYNS2Uragga8xm1Mk6o8nd7Qvt_LbfukOyaaBfqVmCY\",\"clientDataJson\":\"eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoiaE5ra09IYV9HOWJSa2pENC00QWY3dURSTFNFMi1aNC1YOXZWTVR0QnJiVSIsIm9yaWdpbiI6Imh0dHA6Ly9sb2NhbGhvc3Q6NDQzMyIsImNyb3NzT3JpZ2luIjpmYWxzZX0\",\"attestationObject\":\"o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YVikSZYN5YgOjGh0NBcPZHZgW4_krrmihjLHmVzzuoMdl2NFAAAAAK3OAAI1vMYKZIsLJfHwVQMAIEWDUtlK2oIGvMZtTJOqPJ3e0L7fy237pDsmmgX6lZgmpQECAyYgASFYIH_KBmEEIjmE8GQ8Q2jZMN_Bz4YNHc2eLtdBF_i4dFzDIlggY00UuJq97lcCWVrNjqssBvX_8QCqecIYGaS8m1UdSH0\",\"transports\":[\"AUTHENTICATOR_TRANSPORT_INTERNAL\"]},\"authenticatorName\":\"qwffqwpqwfp\",\"challenge\":\"hNkkOHa_G9bRkjD4-4Af7uDRLSE2-Z4-X9vVMTtBrbU\"}]}],\"rootQuorumThreshold\":1,\"wallet\":{\"walletName\":\"Default EVM Wallet\",\"accounts\":[{\"path\":\"m/44'/60'/0'/0/0\",\"curve\":\"CURVE_SECP256K1\",\"pathFormat\":\"PATH_FORMAT_BIP32\",\"addressFormat\":\"ADDRESS_FORMAT_ETHEREUM\"}]}},\"timestampMs\":\"1701400646499\",\"organizationId\":\"105d7217-3600-42b5-a818-226efdb25019\"}",
            "publicKey" => "0371dd5ab2de3ba282ec0d5ee32a5425acd9280a1d70c5bb0e04d5c26d8ce04c41",
            "scheme" => "SIGNATURE_SCHEME_TK_API_P256",
            "selection" => "VOTE_SELECTION_APPROVED",
            "signature" =>
              "304402200CF5BBA8C76E9E5DAC4564B9DF58E336320DD40FACE2F2789688E8A5B03D6C560220345D0FBCD70F9C209954403CECFB23853FF118470452B53C37C31F13F0062C61",
            "user" => %{
              "apiKeys" => [
                %{
                  "apiKeyId" => "37421494-31d2-4668-bb22-3ebbabc64a0d",
                  "apiKeyName" => "y",
                  "createdAt" => %{"nanos" => "0", "seconds" => "1695305724"},
                  "credential" => %{
                    "publicKey" =>
                      "03f4cc07d37967a91acba9013433fcc5c32b014bc49799bd644dd5cfc7a8e984f1",
                    "type" => "CREDENTIAL_TYPE_API_KEY_P256"
                  },
                  "updatedAt" => %{"nanos" => "0", "seconds" => "1695305724"}
                },
                %{
                  "apiKeyId" => "7d05d7d7-6239-43c2-a5aa-2de78c28bfc1",
                  "apiKeyName" => "bacon",
                  "createdAt" => %{"nanos" => "0", "seconds" => "1695321355"},
                  "credential" => %{
                    "publicKey" =>
                      "026c0e322d03044d643821e57032ce925a2f1ec38e847bcb735932ba0630becf03",
                    "type" => "CREDENTIAL_TYPE_API_KEY_P256"
                  },
                  "updatedAt" => %{"nanos" => "0", "seconds" => "1695321355"}
                },
                %{
                  "apiKeyId" => "1e01cc1c-9305-47e5-8800-60839e16094e",
                  "apiKeyName" => "eee",
                  "createdAt" => %{"nanos" => "0", "seconds" => "1695324176"},
                  "credential" => %{
                    "publicKey" =>
                      "02834449f2f4c1b4adf11320c2c70960d905b91936bbe43bf12330414b3de09ba6",
                    "type" => "CREDENTIAL_TYPE_API_KEY_P256"
                  },
                  "updatedAt" => %{"nanos" => "0", "seconds" => "1695324176"}
                },
                %{
                  "apiKeyId" => "c7ab61e4-c376-45f4-bdd4-32bc3f3bf44a",
                  "apiKeyName" => "baba",
                  "createdAt" => %{"nanos" => "0", "seconds" => "1695329968"},
                  "credential" => %{
                    "publicKey" =>
                      "026278FE032C202E1E07CB19E410497849DE99E65429E3C3E1815100EC5E0CB6F4",
                    "type" => "CREDENTIAL_TYPE_API_KEY_P256"
                  },
                  "updatedAt" => %{"nanos" => "0", "seconds" => "1695329968"}
                },
                %{
                  "apiKeyId" => "eed532fa-8513-496d-aa62-eb0bb34fbe7d",
                  "apiKeyName" => "quickstart",
                  "createdAt" => %{"nanos" => "0", "seconds" => "1695333152"},
                  "credential" => %{
                    "publicKey" =>
                      "0371dd5ab2de3ba282ec0d5ee32a5425acd9280a1d70c5bb0e04d5c26d8ce04c41",
                    "type" => "CREDENTIAL_TYPE_API_KEY_P256"
                  },
                  "updatedAt" => %{"nanos" => "0", "seconds" => "1695333152"}
                }
              ],
              "authenticators" => [
                %{
                  "aaguid" => "rc4AAjW8xgpkiwsl8fBVAw",
                  "attestationType" => "packed",
                  "authenticatorId" => "c4050b41-1183-4dff-a165-256295dfabb1",
                  "authenticatorName" => "turnkey demo",
                  "createdAt" => %{"nanos" => "0", "seconds" => "1694015528"},
                  "credential" => %{
                    "publicKey" =>
                      "pQECAyYgASFYIInqPO5xlSqJvN5MjzE2Tcn9uhIPdsqU-0nIXKv2crb0Ilgg1a45bMoswFQ3jdm7QEArJvHSlvgsaR9yIMJqKqBDWN0",
                    "type" => "CREDENTIAL_TYPE_WEBAUTHN_AUTHENTICATOR"
                  },
                  "credentialId" => "JSF4EB5aLIl1X6MLmGJvVzT2PdWxZoOWKGDx5Miz3Nw",
                  "model" => "Google Chrome Mac Touch ID",
                  "transports" => ["AUTHENTICATOR_TRANSPORT_INTERNAL"],
                  "updatedAt" => %{"nanos" => "0", "seconds" => "1694015528"}
                }
              ],
              "createdAt" => %{"nanos" => "0", "seconds" => "1694015528"},
              "updatedAt" => %{"nanos" => "0", "seconds" => "1694015528"},
              "userEmail" => "coburn@compound.finance",
              "userId" => "3ae65e42-875f-456d-92f7-a43be012af28",
              "userName" => "Root user",
              "userTags" => []
            },
            "userId" => "3ae65e42-875f-456d-92f7-a43be012af28"
          }
        ]
      }
    }
  end
end
