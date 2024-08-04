defmodule Turnkey.APIClientTest do
  alias Turnkey.APIClient
  import ExUnit.CaptureLog

  use ExUnit.Case, async: true

  describe "poll_activity/1" do
    # TODO: regression tests for the other cases
    test "logs error and returns error with status of failure" do
      {r, log} =
        with_log(fn ->
          Turnkey.Fixtures.sample_sub_organization_create()
          |> put_in(["activity", "status"], "ACTIVITY_STATUS_FAILED")
          |> APIClient.poll_activity()
        end)

      assert log =~ "[Turnkey Poller][Activity Failure] "
      assert r == {:error, :failed}
    end
  end
end
