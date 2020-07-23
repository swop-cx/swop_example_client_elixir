defmodule SwopClientTest do
  use ExUnit.Case

  describe "single_rate/2" do
    test "single rate for EUR/USD for today" do
      assert {:ok, _response} = SwopClient.single_rate("EUR", "USD")
    end
  end

  describe "single_rate/3" do
    test "single rate for EUR/USD for 21th July of 2020" do
      assert {:ok, _response} = SwopClient.single_rate("EUR", "USD", date: ~D[2020-07-21])
    end
  end

  describe "timeseries/3" do
    test "timeseries one week" do
      assert {:ok, _response} = SwopClient.timeseries(~D[2020-07-14], ~D[2020-07-21])
    end

    test "timeseries one week - with base currency USD" do
      assert {:ok, _response} = SwopClient.timeseries(~D[2020-07-14], ~D[2020-07-21], base: "USD")
    end

    test "timeseries one week - with base currency USD and target currencies GBP, EUR" do
      assert {:ok, _response} =
               SwopClient.timeseries(~D[2020-07-14], ~D[2020-07-21],
                 base: "USD",
                 targets: ["GBP", "EUR"]
               )
    end
  end
end
