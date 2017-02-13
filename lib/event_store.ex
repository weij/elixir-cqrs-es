defmodule Bank.EventStore do
  @doc """
  EvantStore has following characterists:
  1. wrapps persistence storage as well as append operation
  2. represents one or more topics that allow publish-subscribe by consumers. In Bank case, 
     account id is a topic. Anyone subscribes event related to this account, they will be notified.
  3. get events from an offset
  """
  
  @table_id __MODULE__

  def init() do
    :ets.new(@table_id, [:public, :named_table])
  end

  def append_events(key, events) do
    stored_events   = get_raw_events(key)
    new_event       = List.first(:lists.reverse(events))
    combined_events = stored_events ++ Map.to_list(new_event)
    
    IO.inspect combined_events
    :ets.insert(@table_id, {key, combined_events})

    IO.puts "Event Store Published Event"
    # EventBus.publish_event(new_event)
  end

  def get_events(key) do
    :lists.reverse(get_raw_events(key))
  end

  def delete(key) do
    :ets.delete(@table_id, key)
  end

  def get_raw_events(key) do
    case :ets.lookup(@table_id, key) do
      [{_key, events}] -> events
      [] -> []
     end
  end
  
end