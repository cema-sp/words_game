require Logger

defmodule GameServer.Game do
  @moduledoc false

  use Agent

  import GameServer.Utils, only: [generate_uuid: 0]
  import GameServer.LettersGenerator, only: [generate: 1]

  @letters_amount 8
  @initial_score 0

  def start_link(_opts) do
    Agent.start_link(__MODULE__, :initial_state, [])
  end

  def initial_state do
    %{
      uuid:     generate_uuid(),
      type:     nil,
      status:   :pending,
      letters:  [],
      players:  [],
      turn:     0
    }
  end

  def uuid(game) do
    Agent.get(game, Map, :get, [:uuid])
  end

  def type(game) do
    Agent.get(game, Map, :get, [:type])
  end

  def status(game) do
    Agent.get(game, Map, :get, [:status])
  end

  def letters(game) do
    Agent.get(game, Map, :get, [:letters])
  end

  def players(game) do
    Agent.get(game, Map, :get, [:players])
  end

  def player(game, player_pid) do
    game |> players() |> Enum.find(&(&1[:pid] == player_pid))
  end

  def turn(game) do
    Agent.get(game, Map, :get, [:turn])
  end

  def score(game, player) do
    player(game, player).score
  end

  def stats(game) do
    players = players(game)

    do_stats(players)
  end

  defp do_stats([]), do: nil

  defp do_stats(players) do
    scores =
      Enum.reduce(players, %{}, fn(%{pid: player, score: score}, acc) ->
        name = GameServer.Player.name(player)
        Map.put(acc, player, %{name: name, score: score})
      end)

    leader = leader(players)
    leader = Map.put(leader, :name, GameServer.Player.name(leader.pid))

    %{scores: scores, leader: leader}
  end

  def update_score(game, player, scored) do
    Agent.update(game, fn state ->
      players = Enum.map(state.players, fn pl ->
        if pl.pid == player do
          %{pl | score: pl.score + scored}
        else
          pl
        end
      end)

      %{state | players: players}
    end)
  end

  def set_type(game, type) do
    Agent.update(game, Map, :put, [:type, type])
  end

  def join(game, player) do
    Agent.update(game, fn state ->
      players = state.players ++ [%{pid: player, score: @initial_score}]

      %{state | players: players}
    end)
  end

  def start(game) do
    Agent.update(game, fn state ->
      %{state | status: :started, letters: generate(@letters_amount)}
    end)
  end

  def word(game, player, word) do
    cond do
      not players_turn?(game, player) ->
        {:error, :not_your_turn}

      not allowed_letters?(game, word) ->
        {:error, :denied_letters}

      true ->
        case GameServer.Dictionary.check_word(word) do
          {:ok, word} ->
            update_score(game, player, score_word(word))
            {:ok, score(game, player)}

          {:error, :denied_category} ->
            {:ok, :miss}

          {:error, :not_found} ->
            {:ok, :miss}

          {:error, error} ->
            {:error, error}
        end
    end
  end

  def finish(game) do
    Agent.update(game, fn state ->
      %{state | status: :finished}
    end)

    stats = stats(game)
    log_stats(stats)
    # Agent.stop(game)
  end

  defp players_turn?(game, player) do
    turn = turn(game)

    idx =
      game
      |> players()
      |> Enum.find_index(&(&1[:pid] == player))

    idx == turn
  end

  defp allowed_letters?(game, word) do
    word_letters = word |> to_charlist() |> Enum.uniq()

    exceeding_letters = word_letters -- letters(game)

    Enum.empty?(exceeding_letters)
  end

  defp score_word(word) do
    String.length(word)
  end

  defp log_stats(stats) when is_nil(stats), do: :ok

  defp log_stats(%{scores: scores, leader: leader}) do
    score_lines =
      scores
      |> Map.values()
      |> Enum.map(fn %{name: name, score: score} ->
        "  #{name} - #{score}"
      end)

    leader_line = "  #{leader.name} with #{leader.score}"

    message =
      ~s"""
      Leader:
      #{leader_line}
      Scores:
      #{Enum.join(score_lines, "\n")}
      """

    Logger.info(message)
  end

  defp leader([]), do: nil

  defp leader(players) do
    Enum.max_by(players, &(&1.score))
  end
end
