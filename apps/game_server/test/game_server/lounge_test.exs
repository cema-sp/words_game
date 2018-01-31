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

  describe "when a player joined" do
    setup :join_player

    test "allows player to start a training game", context do
      %{lounge: lounge, player: player, player_uuid: player_uuid} = context

      assert lounge |> Lounge.all_games() |> map_size() == 0

      assert uuid = Lounge.new_game(lounge, :training, player_uuid)

      assert %{^uuid => game} = Lounge.all_games(lounge)

      assert game |> GameServer.Game.players() |> Enum.count() == 1
      assert GameServer.Game.status(game) == :started
      assert GameServer.Game.type(game) == :training
      assert GameServer.Player.status(player) == :in_game
      assert GameServer.Player.game(player) == game
    end
  end

  describe "when a player started a training game" do
    setup [:join_player, :start_training_game]

    test "allows player to quit a training game", context do
      %{
        lounge: lounge,
        player: player,
        player_uuid: player_uuid,
        game_uuid: game_uuid,
        game: game
      } = context

      assert ^game_uuid = Lounge.quit_game(lounge, player_uuid)

      assert lounge |> Lounge.all_games() |> map_size() == 0

      assert GameServer.Game.status(game) == :finished
      assert GameServer.Player.status(player) == :idle
      assert GameServer.Player.game(player) == nil
    end
  end

  defp join_player(context) do
    %{lounge: lounge} = context

    player_uuid = Lounge.join(lounge, "NAME")
    %{^player_uuid => player} = Lounge.all_players(lounge)

    [player_uuid: player_uuid, player: player]
  end

  defp start_training_game(context) do
    %{lounge: lounge, player_uuid: player_uuid} = context

    game_uuid = Lounge.new_game(lounge, :training, player_uuid)
    %{^game_uuid => game} = Lounge.all_games(lounge)

    [game_uuid: game_uuid, game: game]
  end
end
