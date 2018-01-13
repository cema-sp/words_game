defmodule GameServer.LoungeTest do
  use ExUnit.Case, async: true

  setup(context) do
    {:ok, lounge} = start_supervised({GameServer.Lounge, name: context.test})
    %{lounge: lounge}
  end

  test "allows players to join with provided name", %{lounge: lounge} do
    assert GameServer.Lounge.all_players(lounge) == %{}

    assert uuid = GameServer.Lounge.join(lounge, "NAME")

    assert %{^uuid => player_pid} = GameServer.Lounge.all_players(lounge)

    assert GameServer.Player.name(player_pid) == "NAME"
  end

  test "returns ready players", %{lounge: lounge} do
    assert GameServer.Lounge.all_players(lounge) == %{}

    player1_uuid = GameServer.Lounge.join(lounge, "NAME 1")
    GameServer.Lounge.join(lounge, "NAME 2")

    assert map_size(GameServer.Lounge.all_players(lounge)) == 2
    assert map_size(GameServer.Lounge.ready_players(lounge)) == 0

    player1 = GameServer.Lounge.all_players(lounge)[player1_uuid]

    GameServer.Player.ready(player1)
    assert map_size(GameServer.Lounge.ready_players(lounge)) == 1
  end
end
