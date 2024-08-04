defmodule Turnkey.APIClient.EmailRecovery do
  @moduledoc """
    Our organization api key can initiate an email recovery process for a user.


  https://docs.turnkey.com/api#tag/User-Recovery/operation/InitUserEmailRecovery
  """

  alias Turnkey.APITypes.{
    CreateActivity,
    InitUserEmailRecoveryIntent,
    InitUserEmailRecoveryResult
  }

  @api_client Turnkey.APIClient

  @create_route "/public/v1/submit/init_user_email_recovery"
  @activity_type_init_user_email_recovery "ACTIVITY_TYPE_INIT_USER_EMAIL_RECOVERY"

  @doc """
  Create the user email recovery activity, which will send the user an email and allow them to continue the process on our recovery webpage
  """
  @spec init_user_email_recovery(String.t(), String.t(), String.t()) ::
          {:ok, %InitUserEmailRecoveryResult{}}
          | {:error, {:instructer_parse_error, String.t()}}
          | {:error, String.t()}
  def init_user_email_recovery(email, sub_organization_id, embedded_key) do
    payload = %CreateActivity{
      type: @activity_type_init_user_email_recovery,
      timestampMs: DateTime.utc_now() |> DateTime.to_unix(:millisecond) |> Integer.to_string(),
      organizationId: sub_organization_id,
      parameters: %InitUserEmailRecoveryIntent{
        email: email,
        targetPublicKey: embedded_key,
        # 15 minutes
        expirationSeconds: "900"
      }
    }

    with {:ok, %{"activity" => %{"result" => %{"initUserEmailRecoveryResult" => result}}}} =
           @api_client.post(@create_route, payload, poll: false),
         {:ok, %InitUserEmailRecoveryResult{} = r} =
           Turnkey.Instructer.instructify(
             result,
             InitUserEmailRecoveryResult
           ) do
      {:ok, r}
    end
  end
end
