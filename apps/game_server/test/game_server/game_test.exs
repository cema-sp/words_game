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
    assert Game.status(game) == :pending
    assert is_binary(Game.uuid(game))
  end

  test "allows players to join", %{game: game} do
    {:ok, player} = start_supervised(GameServer.Player)

    assert Game.players(game) == []

    Game.join(game, player)

    assert Game.players(game) == [%{pid: player, score: 0}]
  end

  describe "#start(game)" do
    test "starts the game", %{game: game} do
      Game.start(game)
      assert Game.status(game) == :started
    end

    test "changes players status to :in_game", %{game: game} do
      {:ok, player} = start_supervised(GameServer.Player)
      Game.join(game, player)

      prev_status = GameServer.Player.status(player)
      Game.start(game)

      new_status = GameServer.Player.status(player)

      assert new_status != prev_status
      assert new_status == :in_game
      assert GameServer.Player.game(player) == game
    end
  end

  describe "#finish(game)" do
    test "finishes the game", %{game: game} do
      Game.finish(game)
      assert Game.status(game) == :finished
    end

    test "changes players status to :in_game", %{game: game} do
      {:ok, player} = start_supervised(GameServer.Player)
      Game.join(game, player)
      Game.start(game)

      prev_status = GameServer.Player.status(player)
      Game.finish(game)

      new_status = GameServer.Player.status(player)

      assert new_status != prev_status
      assert new_status == :idle
      assert GameServer.Player.game(player) == nil
    end
  end
end
