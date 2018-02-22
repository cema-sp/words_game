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

    test "generates letters for the game", %{game: game} do
      assert game |> Game.letters() |> Enum.empty?
      Game.start(game)
      refute game |> Game.letters() |> Enum.empty?
    end
  end

  describe "#finish(game)" do
    test "finishes the game", %{game: game} do
      Game.finish(game)
      assert Game.status(game) == :finished
    end

    # test "stops the Agent", %{game: game} do
    #   assert Process.alive?(game)
    #   Game.finish(game)
    #   refute Process.alive?(game)
    # end
  end

  describe "#stats/1" do
    test "returns game stats", %{game: game} do
      {:ok, player} = start_supervised(GameServer.Player)

      Game.join(game, player)

      stats = Game.stats(game)

      assert is_map(stats)
      assert %{scores: scores, leader: leader} = stats
      assert %{^player => _} = scores
      assert %{pid: ^player, score: _} = leader
    end
  end
end
