defmodule Bank.Account do
  require Logger

  ## Default Timeout
  @timeout 60000

  defmodule State do
    defstruct [:id, :date_created, :balance, :changes]
    @type t :: __MODULE__
  end

  ## Events
  alias Bank.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawn, PaymentDeclined}

  ## Repository
  # alias Bank.AccountRepo

  ## App State
  alias Bank.Account.State

  def new(account_id) when is_binary(account_id) do
    spawn fn -> init(account_id) end
  end

  ## API
  def create(pid, id) do
    send pid, {:attempt_command, {:create, id}}
  end

  def deposit(pid, amount) do
    send pid, {:attempt_command, {:deposit_money, amount}}
  end

  def withdraw(pid, amount) do
    send pid, {:attempt_command, {:withdraw_money, amount}}
  end

  def process_unsaved_changes(pid, saver) do
    send pid, {:process_unsaved_changes, saver}
  end

  def load_from_history(pid, events) do
    send pid, {:load_from_history, events}
  end

  def init(account_id) do
    with state = %{%State{} | :balance => 0, :changes => []},
         {:ok, _} <- Registry.register(:bank_process_registry, account_id, {IO, :inspect}) do
      loop(state)           
    end
  end

  def loop(state) do
    receive do
      {:apply_event, event} ->
        new_state = apply_event(event, state)
        loop(new_state)

      {:attempt_command, command} ->
        new_state = attempt_command(command, state)
        loop(new_state)

      {:process_unsaved_changes, saver} ->
        saver.(state.id, :lists.reverse(state.changes))
        new_state = %{state | :changes => state.changes}
        loop(new_state)

      {:load_from_history, events} ->
        new_state = apply_many_events(events, state = %{%State{} | :balance => 0, :changes => []} )
        loop(new_state)

      unknown ->
        :error_logger.info_msg("Recieved unknown message: ~p~n", [unknown])
        loop(state)
    after
      @timeout ->
        # if this process exits, Registry will remove its record from the table
        exit(:normal)
    end
  end

  def attempt_command({:create, id}, state) do
    # update AccountCreated struct
    event = %{%AccountCreated{} | :id => id, :date_created => :calendar.local_time}
    apply_new_event(event, state)
  end

  def attempt_command({:deposit_money, amount}, state) do
    new_balance = state.balance + amount
    event = %{%MoneyDeposited{} | :id => state.id, :amount => amount, :new_balance => new_balance, :transaction_date => :calendar.local_time}
    apply_new_event(event, state)
  end

  def attempt_command({:withdraw_money, amount}, state) do
    new_balance = state.balance - amount
    IO.inspect("new balance is: #{new_balance}")
    event = case new_balance < 0 do
      false ->
        %{%MoneyWithdrawn{} | :id => state.id, :amount => amount, :new_balance => new_balance, :transaction_date => :calendar.local_time}
      true ->
        %{%PaymentDeclined{} | :id => state.id, :amount => amount, :transaction_date => :calendar.local_time}
    end
    apply_new_event(event, state)
  end

  def attempt_command(_command, state) do
    Logger.error("attempt_command for unexpected command")
    state
  end

  def apply_new_event(event, state) do
    new_state = apply_event(event, state)
    state_changes = Map.update(new_state, :changes, [], &[event|&1])
  end

  def apply_event(event = %AccountCreated{}, state) do
    # AccountRepo.add_to_cache(event.id)
    new_state = %{state | :id => event.id, :date_created => event.date_created}
  end

  def apply_event(event = %MoneyDeposited{}, state) do
    new_balance = state.balance + event.amount
    new_state = %{state | :balance => new_balance}
  end

  def apply_event(event = %MoneyWithdrawn{}, state) do    
    new_balance = state.balance - event.amount
    new_state = %{state | :balance => new_balance}
  end

  def apply_event(event = %PaymentDeclined{}, state) do
    state
  end

  def apply_many_events([], state) do
    state
  end
  
  # replay every events for this account
  # not affficient if the list of events a huge; should offset from a latest snapshot
  def apply_many_events([event|rest], state) do
    new_state = apply_event(event, state)
    apply_many_events(rest, new_state)
  end

end