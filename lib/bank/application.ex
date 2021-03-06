defmodule Bank.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    
    Bank.EventStore.init()
    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Registry, [:unique, :bank_process_registry]),
      supervisor(Bank.CommandSupervisor, [])
      # Starts a worker by calling: Bank.Worker.start_link(arg1, arg2, arg3)
      # worker(Bank.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bank.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
