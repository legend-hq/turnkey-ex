defmodule Turnkey.APIClient do
  @moduledoc """
  Contextualized interfaces to Turnkey API.
  """

  require Logger
  def api_url, do: Application.get_env(:turnkey, :api_url, "https://api.turnkey.com")

  @doc "All requests (query and mutate), are POST requests to facilitate signed json bodies."
  def post(route, payload, opts \\ []) do
    stamp = __MODULE__.Stamper.stamp(payload)
    headers = [{"X-Stamp", stamp}]

    case Req.post(api_url() <> route, json: payload, headers: headers) do
      {:ok, %Req.Response{status: 200, body: json}} ->
        if opts[:poll] do
          # Creating an organization requires polling
          poll_activity(json)
        else
          {:ok, json}
        end

      {:ok, %Req.Response{status: status_code, body: body}} ->
        {:error, "turnkey api failure with status #{status_code}" <> inspect(body)}

      {:error, e} ->
        {:error, "HTTP request failed: #{inspect(e)}"}
    end
  end

  @doc "Polls an activity until completion"
  def poll_activity(
        %{
          "activity" =>
            activity = %{"status" => _status, "id" => id, "organizationId" => organization_id}
        } = z
      ) do
    case activity["status"] do
      "ACTIVITY_STATUS_COMPLETED" ->
        {:ok, activity}

      "ACTIVITY_STATUS_CREATED" ->
        :timer.sleep(100)
        __MODULE__.Activity.get_activity(id, organization_id, true)

      "ACTIVITY_STATUS_PENDING" ->
        :timer.sleep(100)
        __MODULE__.Activity.get_activity(id, organization_id, true)

      "ACTIVITY_STATUS_FAILED" ->
        # This happens in dev when we, for example, pass the wrong challenge
        # It should not occur in production
        Logger.error("[Turnkey Poller][Activity Failure] " <> inspect(z))
        {:error, :failed}

      "ACTIVITY_STATUS_CONSENSUS_NEEDED" ->
        {:error, :consensus_needed}

      "ACTIVITY_STATUS_REJECTED" ->
        {:error, :rejected}
    end
  end
end
