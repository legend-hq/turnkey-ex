defmodule Turnkey.APIClient.SignerTest do
  use ExUnit.Case, async: true

  alias Turnkey.APIClient.Signer
  doctest Signer

  # describe "sign/3" do
  #   test "properly signs a message" do
  #     {:ok, %{v: v, r: r, s: s}} = Sign.sign("55", <<1::160>>, <<1,2,3>>)
  #   end
  # end
end
