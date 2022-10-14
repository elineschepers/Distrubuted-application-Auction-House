defmodule AuctionApplicationTest do
  use ExUnit.Case
  doctest AuctionApplication

  test "greets the world" do
    assert AuctionApplication.hello() == :world
  end
end
