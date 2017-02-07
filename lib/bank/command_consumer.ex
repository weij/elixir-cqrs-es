defmodule Bank.CommandConsumer do
  use GenStage

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
  	  IO.inspect {self(), event}
  	end
  	{:noreply, [], state}
  end
end