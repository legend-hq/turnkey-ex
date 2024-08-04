defmodule Turnkey do
  alias Turnkey.APIClient
  alias Turnkey.APITypes

  @moduledoc """
  Turnkey interactions that are a little higher level than api client
  """

  @doc """
  takes embedded key from turnkey recovery iframe, and
  sub organization id looked up by us using user's email.

  Will trigger an email from turnkey to the user, and the user will
  copy data from that email back into the recovery iframe.
  """
  @spec initiate_recovery(String.t(), String.t(), String.t()) ::
          %APITypes.InitUserEmailRecoveryResult{}
  def initiate_recovery(email, sub_organization_id, embedded_key) do
    APIClient.EmailRecovery.init_user_email_recovery(
      email,
      sub_organization_id,
      embedded_key
    )
  end

  @doc """
  Read the attestation used to create the authenticator which is assigned to the turnkey suborg.

  """
  @spec fetch_recovered_passkey_attestation(String.t()) ::
          %APITypes.Authenticator.Attestation{} | nil
  def fetch_recovered_passkey_attestation(sub_organization_id) do
    request = %APITypes.ListActivitiesRequest{
      organizationId: sub_organization_id,
      filterByStatus: ["ACTIVITY_STATUS_COMPLETED"],
      filterByType: ["ACTIVITY_TYPE_RECOVER_USER"],
      paginationOptions: %APITypes.ListActivitiesRequest.PaginationOptions{
        limit: "1",
        before: "",
        after: ""
      }
    }

    with {:ok, %{"activities" => [%{"intent" => %{"recoverUserIntent" => intent}}]}} <-
           Turnkey.APIClient.Activity.list_activities(request),
         {:ok, %APITypes.RecoverUserIntent{} = i} <-
           Turnkey.Instructer.instructify(
             intent,
             {APITypes.RecoverUserIntent,
              [
                authenticator:
                  {APITypes.Authenticator, [attestation: APITypes.Authenticator.Attestation]}
              ]}
           ) do
      i.authenticator.attestation
    else
      {:ok, %{"activities" => []}} ->
        nil
    end
  end
end
