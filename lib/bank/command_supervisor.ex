defmodule Bank.CommandSupervisor do
  use Supervisor

  def start_link() do
  	Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Bank.CommandProducer, [Bank.CommandProducer]),
      worker(Bank.CommandConsumer, [Bank.CommandConsumer])
    ]

    supervise(children, strategy: :one_for_one)	
  end
end