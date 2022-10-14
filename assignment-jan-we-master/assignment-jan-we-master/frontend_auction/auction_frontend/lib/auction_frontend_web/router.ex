defmodule AuctionFrontendWeb.Router do
  use AuctionFrontendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AuctionFrontendWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AuctionFrontendWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
  scope "/api", AuctionFrontendWeb do
    pipe_through :api
    get "/logs/short", PageController, :logs_short
    get "/logs/full", PageController, :logs_full
    get "/create/:title/:seller/:price/:ended", PageController, :create_auction
    get "/bid/:title", PageController, :increase_price
    get "/end/:title", PageController, :end_auction
    get "/auctions", PageController, :get_auctions

    ### user ###

    get "/create_user/:username/:password", PageController, :create_user
    get "/users", PageController, :get_users

  end
  # Other scopes may use custom stacks.
  # scope "/api", AuctionFrontendWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AuctionFrontendWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
