defmodule AuctionApplication.UserOperationsConsumer do
  use GenServer
  use AMQP

  require IEx

  # Most of this code is from https://hexdocs.pm/amqp/readme.html#setup-a-consumer-genserver

  @channel :auction_channel
  @exchange "user-exchange"
  @queue "user-operations"
  
  @me __MODULE__

  @enforce_keys [:channel]
  defstruct [:channel]

  def start_link(args \\ []), do: GenServer.start_link(@me, args, name: @me)

  def init(_opts) do
    {:ok, amqp_channel} = AMQP.Application.get_channel(@channel)
    state = %@me{channel: amqp_channel}
    rabbitmq_setup(state)
    {:ok, state}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    # do nothing
    {:noreply, state}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    # do nothing
    {:stop, :normal, state}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    # do nothing
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, meta_info}, %@me{} = state) do
    payload
    |> Jason.decode!()
    |> proces_message(meta_info.delivery_tag, state)

    {:noreply, %@me{} = state}
  end

  ## Helper functions ##

  ### user ###

  defp proces_message(%{"command" => "create_user", "username" => username, "password" => password} = msg, tag, state) do
    result = AuctionApplication.UserManager.add_user(username, password)
    Basic.ack(state.channel, tag)

    # Note: not always necessary to send the whole request back. If frontend would keep track of the request unique tag, then you should only send that tag and the result back in order to reduce bandwidth.
    case result do
      {:ok, _} ->
        %{request: msg, result: "succeeded"}
        |> AuctionApplication.WebserverPublisher.send_message()

      {:error, :already_exists} ->
        %{request: msg, result: "failed", reason: "User already exists"}
        |> AuctionApplication.WebserverPublisher.send_message()
    end
  end

  defp proces_message(%{"command" => "getUsers"} = msg, tag, state) do
    Basic.ack(state.channel, tag)
    %{request: msg, result: AuctionApplication.UserManager.list_users}
    |> AuctionApplication.WebserverPublisher.send_message()
  end


  
  defp rabbitmq_setup(%@me{} = state) do
    # Create exchange, queue and bind them.
    :ok = AMQP.Exchange.declare(state.channel, @exchange, :direct)
    {:ok, _consumer_and_msg_info} = AMQP.Queue.declare(state.channel, @queue)
    :ok = AMQP.Queue.bind(state.channel, @queue, @exchange, routing_key: @queue)

    # Limit unacknowledged messages to 1. THIS IS VERY SLOW! Just doing this for debugging
    :ok = Basic.qos(state.channel, prefetch_count: 1)

    # Register the GenServer process as a consumer. Consumer pid argument (3rd arg) defaults to self()
    {:ok, _unused_consumer_tag} = Basic.consume(state.channel, @queue)
  end
end
