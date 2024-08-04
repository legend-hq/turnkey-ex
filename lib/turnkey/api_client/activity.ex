defmodule Turnkey.APIClient.Activity do
  @moduledoc """
  Turnkey mutating actions create an "Activity", with a status that
  indicates whether the endpoint should be polled until the status is "Completed"

  Some activities complete immediately, including signing.
  Some activities take time, including creating sub orgs and if the action
  requires a quorum.

  https://docs.turnkey.com/api#tag/Activities
  """

  @get_route "/public/v1/query/get_activity"
  @list_route "/public/v1/query/list_activities"

  @doc """
  Queries an activity, polling until completion if requested.
  """
  def get_activity(activity_id, organization_id, poll \\ false) do
    payload = %{
      organization_id: organization_id,
      activity_id: activity_id
    }

    Turnkey.APIClient.post(@get_route, payload, poll: poll)
  end

  def list_activities(%Turnkey.APITypes.ListActivitiesRequest{} = r) do
    Turnkey.APIClient.post(@list_route, r)
  end
end
