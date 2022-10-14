defmodule AuctionFrontendWeb.PageController do
  use AuctionFrontendWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end


  def logs_short(conn, _) do
    data = AuctionFrontend.LogDatabase.get_logs(:short) |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> text(data)
  end

  def logs_full(conn, _) do
    data = AuctionFrontend.LogDatabase.get_logs(:all) |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> text(data)
  end

  def create_auction(conn, %{"title" => title, "seller" => seller, "price" => price, "ended" => ended}) do
    unique_tag = AuctionFrontendWeb.AuctionPublisher.create_auction(title, seller, price, ended)

    text(
      conn,
      "Well done! you just added a new auction with unique tag #{unique_tag}, normally you you should be able to view this auction in /api/logs/long"
    )
  end
  def increase_price(conn, %{"title" => title}) do
    unique_tag = AuctionFrontendWeb.AuctionPublisher.increase_price(title)

    text(
      conn,
      "Well done! you just increased the price of the given auction with unique tag #{unique_tag}, normally you you should be able to view this in /api/logs/long"
    )
  end

  def end_auction(conn, %{"title" => title}) do
    unique_tag = AuctionFrontendWeb.AuctionPublisher.end_auction(title)

    text(
      conn,
      "you just ended auction #{unique_tag} with title #{title}, normally you you should be able to view this in /api/logs/long"
    )
  end

  def get_auctions(conn, _) do
    list = AuctionFrontendWeb.AuctionPublisher.get_auctions()
    text(
      conn,
      "requested with tag #{list}, loaded the auctions"
    )
  end

  ### user ###

  def create_user(conn, %{"username" => username, "password" => password}) do
    unique_tag = AuctionFrontendWeb.UserPublisher.create_user(username, password)
    text(
      conn,
      "Well done! you just added a new user with unique tag #{unique_tag}, normally you you should be able to view this auction in /api/logs/long"
    )
  end

  def get_users(conn, _) do
    list = AuctionFrontendWeb.UserPublisher.get_users()
    text(
      conn,
      "requested with tag #{list}, loaded the auctions"
    )
  end

end
