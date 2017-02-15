defmodule Bank.CommandConsumer do
  use GenStage

  require Logger

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

  def handle_events(events, _from, state) do
    for event <- events do
      process_event(event)
    end

  	{:noreply, [], state}
  end

  defp process_event(%CreateAccount{id: id}) do
  	IO.puts "Command Consumer: Create Account"
    case AccountRepo.get_by_id(id) do
      :not_found -> 
      	IO.puts "accound.new"
      	pid = Account.new(id) # spawn a new process for this account
      	Account.create(pid, id)  # keep create event into the account state
        AccountRepo.save(pid)         # save this create event into event store
      {:ok, pid} ->
        IO.puts "this account exists" 
        IO.inspect pid
      	:all_ready_created
    end
  end

  defp process_event(%DepositMoney{id: id, amount: amount}) do
  	IO.puts "deposit money: #{amount}"
  	case AccountRepo.get_by_id(id) do
  	  :not_found ->
        Logger.error(["No account found for: ", id])
  	  {:ok, pid} ->
        Account.deposit(pid, amount) # send the account process message to change state and store new event
        AccountRepo.save(pid)              # save all events from the account state into event store
  	end
  end

  defp process_event(%WithdrawMoney{amount: amount}) do
  	IO.puts "withdraw money: #{amount}"
  end

end