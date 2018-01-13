defmodule GameServer.GameTest do
  use ExUnit.Case, async: true

  alias GameServer.Game

  setup do
    {:ok, game} = start_supervised(GameServer.Game)
    %{game: game}
  end

  test "has initial state", %{game: game} do
    assert Game.players(game) == []
    assert Game.turn(game) == 0
  end

  test "allows players to join", %{game: game} do
    {:ok, player} = start_supervised(GameServer.Player)

    assert Game.players(game) == []

    Game.join(game, player)

    assert Game.players(game) == [%{pid: player, score: 0}]
  end
end
