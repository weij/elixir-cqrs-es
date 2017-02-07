defmodule Bank.Commands do
  
  defmodule CreateAccount do
  	@type t :: __MODULE__
  	defstruct [:id]
  end  
  defmodule DepositMoney do
  	@type t :: __MODULE__
  	defstruct [:id, :amount]
  end  
  defmodule WithdrawMoney do
  	@type t :: __MODULE__
  	defstruct [:id, :amount]
  end

end