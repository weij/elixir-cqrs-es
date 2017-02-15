defmodule Bank.AccountRepo do

  alias Bank.{Account, EventStore}

  def get_by_id(id) do
    case Registry.lookup(:bank_process_registry, id) do
      [] -> 
        load_from_eventstore(id)
      
      [{pid, _value}] ->
        {:ok, pid}
    end
  end  

  def save(pid) do
    # why use closure "save"? it's due to anonymous function that passed and ran on an account process
    saver = fn(id, events) ->
      EventStore.append_events(id, events)
    end
    Account.process_unsaved_changes(pid, saver)
  end
  
  # load every events for this particular topic - account id 
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