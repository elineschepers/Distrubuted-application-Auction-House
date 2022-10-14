defmodule AuctionFrontendWeb.UserPublisher do
  use GenServer
  require IEx
  require Logger

  @channel :auction_channel
  @exchange "user-exchange"
  @queue "user-operations"

  @me __MODULE__

  @enforce_keys [:channel]
  defstruct [:channel]

  ## API ##

  def start_link(_args \\ []), do: GenServer.start_link(@me, :no_opts, name: @me)
  
  ### user ###
  
  def create_user(username, password), do: GenServer.call(@me, {:create_user, username, password})
    def get_users(), do: GenServer.call(@me, {:get_users})


  ## Callbacks ##

  @impl true
  def init(:no_opts) do
    {:ok, amqp_channel} = AMQP.Application.get_channel(@channel)
    state = %@me{channel: amqp_channel}
    rabbitmq_setup(state)

    {:ok, state}
  end

  @impl true
    def handle_call({:create_user, username, password}, _, %@me{channel: c} = state) do
      # Note: unique tags never should be created this way... consider a hash, unique string, but not this.
      #          Only doing this due to lack of time
      # Purpose of tags is to make events unique. Imagine in a bank a transaction accidentally happening twice (or not). If the message is somehow lost with the consumer, it can be resent. If the consumer had already processed it but the publisher was impatient, it can be ignored (or a message be sent back that it's fine).
      # Not going to use it actually in this demo, but just wanted to put it out there
      unique_tag = :erlang.make_ref() |> Kernel.inspect()
      payload = Jason.encode!(%{command: "create_user", username: username,password: password, unique_tag: unique_tag})
      :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
      {:reply, unique_tag, state}
    end


  @impl true
    def handle_call({:get_users}, _, %@me{channel: c} = state) do
      unique_tag = :erlang.make_ref() |> Kernel.inspect()
      payload = Jason.encode!(%{command: "getUsers", unique_tag: unique_tag})
      :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
      {:reply, unique_tag, state}
    end

  ## Helper functions ##
  defp rabbitmq_setup(%@me{} = state) do
    # Create exchange, queue and bind them.
    :ok = AMQP.Exchange.declare(state.channel, @exchange, :direct)
    {:ok, _consumer_and_msg_info} = AMQP.Queue.declare(state.channel, @queue)
    :ok = AMQP.Queue.bind(state.channel, @queue, @exchange, routing_key: @queue)
  end
end
