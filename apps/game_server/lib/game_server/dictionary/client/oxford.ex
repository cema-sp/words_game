defmodule GameServer.Dictionary.Client.Oxford do
  @moduledoc """
  Dictionary API client for Oxford Dictionaries.
  Link: https://developer.oxforddictionaries.com/documentation#/
  """

  @behaviour GameServer.Dictionary.Client

  @base_url Application.get_env(:game_server, :dictionary_base_url)
  @app_id Application.get_env(:game_server, :dictionary_app_id)
  @app_key Application.get_env(:game_server, :dictionary_app_key)

  def lexical_category(word) do
    url = @base_url <> "/entries/en/#{word}/lexicalCategory"
    get(url)
  end

  def entries(word) do
    url = @base_url <> "/entries/en/#{word}"
    get(url)
  end

  defp get(url) do
    case HTTPoison.get(url, headers()) do
      {:ok, response} ->
        case response do
          %HTTPoison.Response{body: body, status_code: 200} ->
            Poison.decode(body)
          _ ->
            {:error, :not_found}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      _ ->
        {:error, :unknown}
    end
  end

  defp headers do
    [
      "Accept": "application/json",
      "app_id": @app_id,
      "app_key": @app_key
    ]
  end
end
