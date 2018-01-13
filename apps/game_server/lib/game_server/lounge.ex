defmodule GameServer.Lounge do
  use GenServer

  defmodule State do
    defstruct [players: %{}]
  end

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def join(lounge, name) do
    GenServer.call(lounge, {:join, name})
  end

  def all_players(lounge) do
    GenServer.call(lounge, :all_players)
  end

  def ready_players(lounge) do
    GenServer.call(lounge, :ready_players)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %State{}}
  end

  def handle_call({:join, name}, _from, state) do
    {:ok, player} = GameServer.PlayerSupervisor.create_player()

    GameServer.Player.set_name(player, name)
    uuid = GameServer.Player.uuid(player)
    players = Map.put(state.players, uuid, player)

    {:reply, uuid, %{state | players: players}}
  end

  def handle_call(:all_players, _from, state) do
    {:reply, state.players, state}
  end

  def handle_call(:ready_players, _from, state) do
    players =
      state.players
      |> Enum.filter(fn {_, player} ->
        GameServer.Player.status(player) == :ready
      end)
      |> Enum.into(%{})

    {:reply, players, state}
  end
end
