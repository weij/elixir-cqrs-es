defmodule Bank.Events do
  
  # thinking point: should modeling event as function instead, not num.
  # Common elements in an event are:
  # 1. unique id (related to who, not this event) - e.g. sessionId, 
  # 2. event type,
  # 3. timestamp, 
  # 4. locations - e.g. ip address, lat/lng, pageURL 
  defmodule AccountCreated do
  	@type t :: __MODULE__
  	defstruct [:id, :date_created]
  end

  defmodule MoneyDeposited do
  	@type t :: __MODULE__
  	defstruct [:id, :amount, :new_balance, :transaction_date] 
  end

  defmodule MoneyWithdrawn do
  	@type t :: __MODULE__
  	defstruct [:id, :amount, :new_balance, :transaction_date] 
  end

  defmodule PaymentDeclined do
  	@type t :: __MODULE__
  	defstruct [:id, :amount, :transaction_date] 
  end

end