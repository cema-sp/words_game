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

  describe "word/3" do
    setup [:join_player, :join_another_player, :start_game]

    test "when it's not players turn returns error", context do
      %{game: game, another_player: another_player} = context
      assert {:error, :not_your_turn} = Game.word(game, another_player, "cat")
    end

    test "when wrong letters used returns error", context do
      %{game: game, player: player} = context
      assert {:error, :denied_letters} = Game.word(game, player, "c@t")
    end

    test "when word not found returns miss", context do
      %{game: game, player: player} = context

      Agent.update(game, fn state ->
        %{state | letters: 'ntfound'}
      end)

      assert {:ok, :miss} = Game.word(game, player, "notfound")
    end

    test "when word found updates and returns score", context do
      %{game: game, player: player} = context

      Agent.update(game, fn state ->
        %{state | letters: 'miws'}
      end)

      assert {:ok, score} = Game.word(game, player, "swim")
      assert score == Game.score(game, player)
      assert score == 4
    end

    test "when already used word provided returns error", context do
      %{game: game, player: player} = context

      Agent.update(game, fn state ->
        %{state | letters: 'miws'}
      end)

      {:ok, _} = Game.word(game, player, "swim")

      assert {:error, :already_used_word} = Game.word(game, player, "swim")
    end
  end

  defp start_game(%{game: game}), do: Game.start(game)

  defp join_player(%{game: game}) do
    {:ok, player} = start_supervised(GameServer.Player)

    :ok = Game.join(game, player)

    [player: player]
  end

  defp join_another_player(%{game: game}) do
    player_spec = %{
      id: AnotherPlayer,
      start: {GameServer.Player, :start_link, [[]]}
    }

    {:ok, player} = start_supervised(player_spec)

    :ok = Game.join(game, player)

    [another_player: player]
  end
end
