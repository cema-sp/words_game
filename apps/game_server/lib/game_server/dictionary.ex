require IEx

defmodule GameServer.Dictionary do
  @moduledoc """
  Defines dictionary interface.
  """

  @allowed_categories ["Verb", "Noun", "Adjective"]
  @client Application.get_env(:game_server, :dictionary_client)

  @type check_word_error :: :denied_category
                          | :not_found
                          | :api_error
                          | :unknown
                          | term
  @doc """
  Checks if `word` exists in the dictionary and if it is of allowed category.
  """
  @spec check_word(String.t) :: {:ok, String.t}
                              | {:error, check_word_error }
  def check_word(word) do
    with {:ok, data} <- @client.lexical_category(word) do
      if allowed_category?(data) do
        {:ok, word}
      else
        {:error, :denied_category}
      end
    end
  end

  defp allowed_category?(data) do
    results = data["results"]

    if is_nil(results) do
      false
    else
      results
      |> Enum.flat_map(&(&1["lexicalEntries"]))
      |> Enum.map(&(&1["lexicalCategory"]))
      |> Enum.any?(&(&1 in @allowed_categories))
    end
  end
end
