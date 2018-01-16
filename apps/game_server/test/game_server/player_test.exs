defmodule GameServer.PlayerTest do
  use ExUnit.Case, async: true

  alias GameServer.Player

  setup do
    {:ok, player} = start_supervised(GameServer.Player)
    %{player: player}
  end

  test "has initial state", %{player: player} do
    assert Player.name(player) == nil
    assert Player.status(player) == :idle
    assert is_binary(Player.uuid(player))
  end

  test "could change status with transitions", %{player: player} do
    assert Player.status(player) == :idle

    Player.ready(player)
    assert Player.status(player) == :ready

    {:ok, game} = start_supervised(GameServer.Game)
    Player.start_game(player, game)
    assert Player.status(player) == :in_game

    Player.finish_game(player)
    assert Player.status(player) == :idle
  end

  test "could set name", %{player: player} do
    Player.set_name(player, "NAME")
    assert Player.name(player) == "NAME"
  end

  test "should not be restarted" do
    assert Supervisor.child_spec(Player, []).restart == :temporary
  end

  describe "#start_game(player, game)" do
    test "remembers game", %{player: player} do
      {:ok, game} = start_supervised(GameServer.Game)
      Player.start_game(player, game)

      assert Player.game(player) == game
    end
  end
end
