defmodule Message.Coder do
  @moduledoc """
  Defines coder API behaviour.
  """

  @doc """
  Encodes Message to binary format.
  """
  @callback encode(Message.t) :: {:ok, binary} | {:error, any}

  @doc """
  Decodes Message from binary format.
  """
  @callback decode(binary) :: {:ok, Message.t} | {:error, any}
end
