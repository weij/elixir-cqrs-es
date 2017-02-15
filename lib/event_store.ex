defmodule Bank.EventStore do
  @doc """
  
  ## EvantStore has following characterists:
    1. Allow ONLY append event into its storage on a topic
    2. Prevent any remove events operation from its storage
    3. Allow to take snapshot 
    4. Allow to replay events from a snapshot/offset
    5. Have pub-sub system in order to notify a topic subscriber/consumers to pull new events
    6. Get events one-by-one from an offset
  """
  
  @table_id __MODULE__

  def init() do
    :ets.new(@table_id, [:public, :named_table])
  end

  def append_events(key, events) do
    stored_events   = get_raw_events(key)
    new_event       = List.first(:lists.reverse(events))
    combined_events = [new_event | stored_events]
    
    :ets.insert(@table_id, {key, combined_events})

    IO.puts "Event Store Published Event"
    # EventBus.publish_event(new_event)
  end

  def get_events(key) do
    :lists.reverse(get_raw_events(key))
  end

  def get_raw_events(key) do
    case :ets.lookup(@table_id, key) do
      [{_key, events}] -> events
      [] -> []
     end
  end
  
end