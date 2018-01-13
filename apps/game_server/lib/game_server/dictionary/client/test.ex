defmodule GameServer.Dictionary.Client.Test do
  @moduledoc """
  Dictionary API client mock.
  """

  @behaviour GameServer.Dictionary.Client

  def lexical_category(word) do
    case word do
      "swim" ->
        data = %{
          "metadata" => %{
            "provider" => "Oxford University Press"
          },
          "results" => [
            %{
              "id" => "swim",
              "language" => "en",
              "lexicalEntries" => [
                %{
                  "language" => "en",
                  "lexicalCategory" => "Verb",
                  "text" => "swim"
                },
                %{
                  "language" => "en",
                  "lexicalCategory" => "Noun",
                  "text" => "swim"
                }
              ],
              "type" => "headword",
              "word" => "swim"
            }
          ]
        }

        {:ok, data}

      "other" ->
        data = %{
          "metadata" => %{
            "provider" => "Oxford University Press"
          },
          "results" => [
            %{
              "id" => "other",
              "language" => "en",
              "lexicalEntries" => [
                %{
                  "language" => "en",
                  "lexicalCategory" => "Other",
                  "text" => "other"
                },
              ],
              "type" => "headword",
              "word" => "other"
            }
          ]
        }

        {:ok, data}

      "notfound" ->
        {:error, :not_found}

      "error" ->
        {:error, :connection_error}
    end
  end

  def entries(word) do
    case word do
      "found" ->
        {:ok, %{}}

      "notfound" ->
        {:error, :not_found}

      "error" ->
        {:error, :connection_error}
    end
  end
end
