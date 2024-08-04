defmodule Turnkey.TestClient do
  def post(_route, _payload, _opts \\ []) do
    {:ok, Turnkey.Fixtures.sample_sub_organization_create()["activity"]}
  end
end
