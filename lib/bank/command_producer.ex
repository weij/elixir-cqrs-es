defmodule Bank.CommandProducer do
  use GenStage

  def start_link(producer_id) do
  	name = via_tuple(producer_id)
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  defp via_tuple(producer_id) do
  	{:via, Registry, {:bank_process_registry, producer_id}}
  end

  ## Callbacks

  def init(:ok) do
  	{:producer, {:queue.new, 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

end