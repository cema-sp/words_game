defmodule GameServer.Dictionary.Client do
  @moduledoc """
  Defines dictionary API client behaviour.
  """

  @doc """
  Retrieves lexical categories for the `word`.
  """
  @callback lexical_category(String.t) :: {:ok, Map.t} | {:error, term}

  @doc """
  Retrieves dictionary entries for the `word`.
  """
  @callback entries(String.t) :: {:ok, Map.t} | {:error, term}
end
