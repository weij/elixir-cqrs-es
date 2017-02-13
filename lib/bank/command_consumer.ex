defmodule Bank.CommandConsumer do
  use GenStage

  alias Bank.Commands.{CreateAccount, DepositMoney, WithdrawMoney}
  alias Bank.{Account, AccountRepo}

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
      process_event(event)
    end

  	{:noreply, [], state}
  end

  defp process_event(%CreateAccount{} = command) do
  	IO.puts "Command Consumer: Create Account"
    case Registry.lookup(:bank_process_registry, command.id) do
      [] -> 
      	IO.puts "accound.new"
      	pid = Account.new(command.id)
      	Account.create(pid, command)
        AccountRepo.save(pid)
      [{_pid, _value}] ->
        IO.puts "the account exists" 
      	:all_ready_created
    end
  end

  defp process_event(%DepositMoney{amount: amount} = event) do
  	IO.puts "deposit money: #{amount}"
  end

  defp process_event(%WithdrawMoney{amount: amount}) do
  	IO.puts "withdraw money: #{amount}"
  end

end