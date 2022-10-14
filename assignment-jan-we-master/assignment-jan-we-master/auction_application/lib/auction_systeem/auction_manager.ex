defmodule AuctionApplication.AuctionManager do
  use GenServer

  require Logger
  require Kernel
  alias AuctionApplication.{Auction, AuctionDynSup}

  @me __MODULE__
  defstruct auctions: %{}

  @me __MODULE__
  @auctions [
    %{
      title: "Picasso painting",
      seller: "Ward",
      price: 2_000_000_000.50,
      ended: false
    }
  ]

  # gives hardcoded auction
  def all_auctions, do: @auctions
  # ### #
  # API #
  # ### #
  def start_link(args) do
    # This process can be name registered "normally" without a registry!
    # It's part of the static part of the tree and should be callable regardless of the
    #   registry
    GenServer.start_link(@me, args, name: @me)
  end

  # add auction to stack
  def add_auction(title, seller, price, ended) do
    GenServer.call(@me, {:place_auction, title, seller, price, ended})
  end

  # delete auction
  def delete_auction(title) do
    GenServer.call(@me, {:delete_auction, title})
  end

  # update auction price
  def update_price(title ) do
    GenServer.call(@me, {:increase_price, title})
  end
  def end_auction(title ) do
    GenServer.cast(@me, {:end_auction, title})
  end
  # gives all auctions added in terminal
  def list_auctions() do
    GenServer.call(@me, {:list_auctions})
  end

  # ######### #
  # CALLBACKS #
  # ######### #

  @impl true
  def init(_args) do
    {:ok, %@me{}}
  end

  # voeg toe aan auction wachtrij
  @impl true
  def handle_call({:place_auction, title, seller, price, ended}, _from,%@me{} = state) do
    case Map.has_key?(state.auctions, title) do
      true ->
        {:reply, {:error, :already_exists}, state}
      false ->
        response = DynamicSupervisor.start_child(AuctionDynSup, {Auction, [title: title, seller: seller, price: price, ended: ended]})
        new_auctions = Map.put_new(
            state.auctions,
            title,
            %{
              seller: seller,
              price: price,
              ended: ended
            }
          )
        {:reply, response, %{state | auctions: new_auctions}}
    end
  end

  @impl true
  def handle_call({:list_auctions}, _from,%@me{} = state) do
    {:reply, state.auctions, state}
  end

  #TODO
  # fix map.puts, manier van update prijs map.put(map, key, value)



 @impl true
  def handle_call({:increase_price, title}, _from,%@me{} = state) do

    v=Map.get(state.auctions,title)

    case v.ended == true do
      true ->
        IO.puts("auction is ended so there will be an error send out")
        {:reply, {:error, :already_exists}, state}

      false ->
        IO.puts("auction is getting increased on its price")

    new_price = v.price + 10
    new_list = Map.replace(state.auctions, title, %{price: new_price, ended: v.ended, seller: v.seller})

    new_state = %{state | auctions: new_list}

    {:reply,:ok, %{new_state | auctions: new_list}}


   end
    #Map.get_and_update(state.auctions, :, fn %{} ->
  #{current_value, "new value!"}
  end


  @impl true
  def handle_cast({:end_auction, title},%@me{} = state) do
    v=Map.get(state.auctions,title)
    new_list = Map.replace(state.auctions, title, %{price: v.price, ended: true, seller: v.seller})

    new_state = %{state | auctions: new_list}

    {:noreply, new_state}
    #Map.get_and_update(state.auctions, :, fn %{} ->
  #{current_value, "new value!"}


  end


  # auction is gedaan
  @impl true
  def handle_continue({:empty_auction, title}, %@me{} = state) do
    AuctionApplication.Auction.empty(title)
    {:noreply, state}
  end

end
