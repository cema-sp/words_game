defmodule GameServer.LoungeTest do
  use ExUnit.Case, async: true

  alias GameServer.Lounge

  setup(context) do
    {:ok, lounge} = start_supervised({Lounge, name: context.test})
    %{lounge: lounge}
  end

  test "allows players to join with provided name", %{lounge: lounge} do
    assert Lounge.all_players(lounge) == %{}

    assert uuid = Lounge.join(lounge, "NAME")

    assert %{^uuid => player_pid} = Lounge.all_players(lounge)

    assert GameServer.Player.name(player_pid) == "NAME"
  end

  test "returns ready players", %{lounge: lounge} do
    assert Lounge.all_players(lounge) == %{}

    player1_uuid = Lounge.join(lounge, "NAME 1")
    Lounge.join(lounge, "NAME 2")

    assert map_size(Lounge.all_players(lounge)) == 2
    assert map_size(Lounge.ready_players(lounge)) == 0

    player1 = Lounge.all_players(lounge)[player1_uuid]

    GameServer.Player.ready(player1)
    assert map_size(Lounge.ready_players(lounge)) == 1
  end

  test "allows player to create a training game", %{lounge: lounge} do
    assert player_uuid = Lounge.join(lounge, "NAME")

    assert Lounge.all_games(lounge) == %{}

    assert uuid = Lounge.new_game(lounge, :training, player_uuid)

    assert %{^uuid => game_pid} = Lounge.all_games(lounge)

    assert game_pid |> GameServer.Game.players |> Enum.count() == 1
  end
end
