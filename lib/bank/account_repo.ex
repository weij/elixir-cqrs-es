defmodule Bank.AccountRepo do

  alias Bank.{Account, EventStore}

  def save(pid) do
    # why use closure "save"? it's due to anonymous function that passed and ran on an account process
    saver = fn(id, events) ->
      EventStore.append_events(id, events)
    end
    Account.process_unsaved_changes(pid, saver)
  end
  
  def load_from_eventstore(id) do
    case EventStore.get_events(id) do
      [] ->
        :not_found
      
      events ->
        pid = Account.new(id)
        Account.load_from_history(pid, events)
        {:ok, pid}
    end
  end
end