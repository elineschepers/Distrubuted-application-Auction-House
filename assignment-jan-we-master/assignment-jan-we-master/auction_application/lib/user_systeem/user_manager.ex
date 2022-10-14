defmodule AuctionApplication.UserManager do
  use GenServer

  require Logger
  require Kernel
  alias AuctionApplication.{User, UserDynSup}

  @me __MODULE__
  defstruct users: %{}

  # ### #
  # API #
  # ### #
  def start_link(args) do
    # This process can be name registered "normally" without a registry!
    # It's part of the static part of the tree and should be callable regardless of the
    #   registry
    GenServer.start_link(@me, args, name: @me)
  end

  # add User to stack
  def add_user(username, password) do
    GenServer.call(@me, {:place_User, username, password})
  end

  # delete User
  def delete_user(username) do
    GenServer.call(@me, {:delete_User, username})
  end

  # update User password
  def update_password(username,password ) do
    GenServer.cast(@me, {:change_password, username, password})
  end
  # gives all Users added in terminal
  def list_users() do
    GenServer.call(@me, {:list_Users})
  end

  # ######### #
  # CALLBACKS #
  # ######### #

  @impl true
  def init(_args) do
    {:ok, %@me{}}
  end

  # voeg toe aan User wachtrij
  @impl true
  def handle_call({:place_User, username, password}, _from,%@me{} = state) do
    case Map.has_key?(state.users, username) do
      true ->
        {:reply, {:error, :already_exists}, state}
      false ->
        response = DynamicSupervisor.start_child(UserDynSup, {User, [username: username, password: password]})
        new_Users = Map.put_new(
            state.users,
            username,
            password
          )
        {:reply, response, %{state | users: new_Users}}
    end
  end

  @impl true
  def handle_call({:list_Users}, _from,%@me{} = state) do
    {:reply, state.users, state}
  end

  #TODO
  # fix map.puts, manier van update prijs map.put(map, key, value)

  # update password van User
  @impl true
  def handle_cast({:change_password, username, password},%@me{} = state) do
    new_list = Map.replace(state.users, username, password)
    new_state = %{state | users: new_list}

    {:noreply, new_state}
  end
end
