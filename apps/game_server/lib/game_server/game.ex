defmodule GameServer.Game do
  use Agent

  defmodule State do
    defstruct [players: [], turn: 0]
  end

  @initial_score 0

  def start_link(_opts) do
    Agent.start_link(fn -> %State{} end)
  end

  def players(game) do
    Agent.get(game, Map, :get, [:players])
  end

  def turn(game) do
    Agent.get(game, Map, :get, [:turn])
  end

  def join(game, player) do
    Agent.update(game, fn state ->
      players = state.players ++ [%{pid: player, score: @initial_score}]

      %{state | players: players}
    end)
  end
end
