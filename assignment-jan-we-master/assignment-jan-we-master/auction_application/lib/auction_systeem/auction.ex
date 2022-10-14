defmodule AuctionApplication.Auction do
  use GenServer
  # werken met local db ipv dit // oke //
  # genserver met state waar lijst van auctions in steekt in init
  # api def add product en delete product
  require Logger

  @me __MODULE__
  defstruct title: "", seller: "", price: 0, ended: false
  
  # belongs_to :user, User voor wanneer we login proces doen // hoort niet in auction denk ik? 

  def start_link(args) do
    # Should be registered in the registry since there can be a dynamic amount of
    #   garbage cans.
    #title is key
    title = args[:title] || raise "no auction found with title \":title\""
    GenServer.start_link(@me, args, name: via_tuple(title))
  end

  @impl true
  def init(args) do
      {:ok, args}
  end

  def empty(title) do
    title
    |> via_tuple()
    |> GenServer.call(:empty)
  end
  

  @impl true
  def handle_info(:add_auction, %@me{} = state) do
  # title moet veranderen
    {:noreply, %{state | title: state.title }, {:continue, :report}}
  end
  

  @impl true
  def handle_info(:remove_auction, %@me{} = state) do
    # title moet veranderen
    {:noreply, %{state | title: state.title}, {:continue, :report}}
  end

  def via_tuple(title) do
    {:via, Registry, {AuctionApplication.MyRegistry, {:auction, title}}}
  end
end
