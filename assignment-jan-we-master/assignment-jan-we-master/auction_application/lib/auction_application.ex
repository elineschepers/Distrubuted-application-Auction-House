defmodule AuctionApplication.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: AuctionApplication.Worker.start_link(arg)
      # {AuctionApplication.Worker, arg}

      {Registry, keys: :unique, name: AuctionApplication.MyRegistry},
      {AuctionApplication.AuctionSystem, []},
      {AuctionApplication.UserSystem, []},
      AuctionApplication.WebserverPublisher,


      #om te communiceren met backend
      #AuctionApplication.WebserverPublisher,


      #enkem consumer process
      #AuctionApplication.ManagerOperationsConsumer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AuctionApplication.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
