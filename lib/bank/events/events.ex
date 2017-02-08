defmodule Bank.Events do

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