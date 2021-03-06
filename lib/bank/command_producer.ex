defmodule Bank.CommandProducer do
  use GenStage

  def start_link(producer_id) do
  	name = via_tuple(producer_id)
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  defp via_tuple(producer_id) do
  	{:via, Registry, {:bank_process_registry, producer_id}}
  end

  @doc """
  Sends an event and returns only after the event is dispatched.
  """
  def sync_notify(event, timeout \\ 5000) do
  	GenStage.call(via_tuple(__MODULE__), {:notify, event}, timeout)
  end

  ## Callbacks

  def init(:ok) do
  	{:producer, {:queue.new, 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:notify, event}, from, {queue, demand}) do
  	dispatch_events(:queue.in({from, event}, queue), demand, [])
  end

  def handle_demand(incoming_demand, {queue, demand}) do
  	dispatch_events(queue, incoming_demand + demand, [])
  end

  defp dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand,
         {{:value, {from, event}}, queue} <- :queue.out(queue) do
      GenStage.reply(from, :ok) 
      dispatch_events(queue, demand - 1, [event | events])	
    else
      _ -> {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end

end