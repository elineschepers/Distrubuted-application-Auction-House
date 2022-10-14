defmodule AuctionApplication.User do
  use GenServer
  # werken met local db ipv dit // oke //
  # genserver met state waar lijst van auctions in steekt in init
  # api def add product en delete product
  require Logger

  @me __MODULE__
  defstruct username: "", password: ""

  # belongs_to :user, User voor wanneer we login proces doen // hoort niet in auction denk ik?

  def start_link(args) do
    # Should be registered in the registry since there can be a dynamic amount of
    #   garbage cans.
    #username is key
    username = args[:username] || raise "no user found with username \":username\""
    GenServer.start_link(@me, args, name: via_tuple(username))
  end

  @impl true
  def init(args) do
      {:ok, args}
  end

  def empty(username) do
    username
    |> via_tuple()
    |> GenServer.call(:empty)
  end


  @impl true
  def handle_info(:add_user, %@me{} = state) do
  # username moet veranderen
    {:noreply, %{state | username: state.username }, {:continue, :report}}
  end


  @impl true
  def handle_info(:remove_username, %@me{} = state) do
    # username moet veranderen
    {:noreply, %{state | username: state.username}, {:continue, :report}}
  end

  def via_tuple(username) do
    {:via, Registry, {AuctionApplication.MyRegistry, {:user, username}}}
  end
end
