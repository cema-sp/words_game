defmodule GameServer.Lounge do
  use GenServer

  defmodule State do
    defstruct [players: %{}, games: %{}]
  end

  alias GameServer.PlayerSupervisor
  alias GameServer.Player
  alias GameServer.GameSupervisor
  alias GameServer.Game

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def join(lounge, name) do
    GenServer.call(lounge, {:join, name})
  end

  def new_game(lounge, :training, player_uuid) do
    GenServer.call(lounge, {:new_game, :training, player_uuid})
  end

  def word(lounge, player_uuid, word) do
    GenServer.call(lounge, {:word, player_uuid, word})
  end

  def quit_game(lounge, player_uuid) do
    GenServer.call(lounge, {:quit_game, player_uuid})
  end

  def all_players(lounge) do
    GenServer.call(lounge, :all_players)
  end

  def ready_players(lounge) do
    GenServer.call(lounge, :ready_players)
  end

  def all_games(lounge) do
    GenServer.call(lounge, :all_games)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %State{}}
  end

  def handle_call({:join, name}, _from, state) do
    {:ok, player} = PlayerSupervisor.create_player()

    Player.set_name(player, name)
    uuid = Player.uuid(player)
    players = Map.put(state.players, uuid, player)

    {:reply, uuid, %{state | players: players}}
  end

  def handle_call({:new_game, :training, player_uuid}, _from, state) do
    player = state.players[player_uuid]

    {:ok, game} = GameSupervisor.create_game()
    Game.set_type(game, :training)

    uuid = Game.uuid(game)
    Game.join(game, player)

    Game.start(game)
    Player.start_game(player, game)

    letters = Game.letters(game)

    games = Map.put(state.games, uuid, game)

    {:reply, {uuid, letters}, %{state | games: games}}
  end

  def handle_call({:word, player_uuid, word}, _from, state) do
    player = state.players[player_uuid]
    game = Player.game(player)

    result = Game.word(game, player, word)

    {:reply, result, state}
  end

  def handle_call({:quit_game, player_uuid}, _from, state) do
    player = state.players[player_uuid]
    game = Player.game(player)
    game_uuid = Game.uuid(game)

    Game.finish(game)
    Player.finish_game(player)

    games = Map.delete(state.games, game_uuid)

    {:reply, game_uuid, %{state | games: games}}
  end

  def handle_call(:all_players, _from, state) do
    {:reply, state.players, state}
  end

  def handle_call(:ready_players, _from, state) do
    players =
      state.players
      |> Enum.filter(fn {_, player} -> Player.status(player) == :ready end)
      |> Enum.into(%{})

    {:reply, players, state}
  end

  def handle_call(:all_games, _from, state) do
    {:reply, state.games, state}
  end
end
