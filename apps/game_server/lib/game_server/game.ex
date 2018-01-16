defmodule GameServer.Game do
  use Agent

  import GameServer.Utils, only: [generate_uuid: 0]

  defmodule State do
    defstruct [:uuid, :type, status: :pending, players: [], turn: 0]
  end

  @initial_score 0

  def start_link(_opts) do
    Agent.start_link(fn ->
      %State{uuid: generate_uuid()}
    end)
  end

  def players(game) do
    Agent.get(game, Map, :get, [:players])
  end

  def turn(game) do
    Agent.get(game, Map, :get, [:turn])
  end

  def uuid(game) do
    Agent.get(game, Map, :get, [:uuid])
  end

  def status(game) do
    Agent.get(game, Map, :get, [:status])
  end

  def join(game, player) do
    Agent.update(game, fn state ->
      players = state.players ++ [%{pid: player, score: @initial_score}]

      %{state | players: players}
    end)
  end

  def start(game) do
    Agent.update(game, fn state ->
      Enum.each(state.players, fn %{pid: player} ->
        GameServer.Player.start_game(player, game)
      end)

      %{state | status: :started}
    end)
  end

  def finish(game) do
    Agent.update(game, fn state ->
      Enum.each(state.players, fn %{pid: player} ->
        GameServer.Player.finish_game(player)
      end)

      %{state | status: :finished}
    end)
  end
end
