defmodule Bank.CommandConsumer do
  use GenStage

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}

  def start_link(consumer_id) do
  	name = via_tuple(consumer_id)
  	GenStage.start_link(__MODULE__, :ok, name: name)
  end

  defp via_tuple(consumer_id) do
  	{:via, Registry, {:bank_process_registry, consumer_id}}
  end

  # Callbacks

  def init(:ok) do
  	{:consumer, :ok, subscribe_to: [via_tuple(Bank.CommandProducer)]}
  end

  def handle_events(events, from, state) do
    for event <- events do
      handle_event(event)
    end

  	{:noreply, [], state}
  end

  defp handle_event(%CreateAccount{}) do
  	IO.puts "just create a new account"
  end

  defp handle_event(%DepositMoney{amount: amount} = event) do
  	IO.puts "deposit money: #{amount}"
  end

  defp handle_event(%WithdrawMoney{amount: amount}) do
  	IO.puts "withdraw money: #{amount}"
  end

end