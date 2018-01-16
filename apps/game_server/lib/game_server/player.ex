defmodule GameServer.Player do
  use Agent, restart: :temporary

  import GameServer.Utils, only: [generate_uuid: 0]

  defmodule State do
    defstruct [:name, :uuid, :game, status: :idle]
  end

  def start_link(_opts) do
    Agent.start_link(fn ->
      %State{uuid: generate_uuid()}
    end)
  end

  def set_name(player, name) do
    Agent.update(player, Map, :put, [:name, name])
  end

  def name(player) do
    Agent.get(player, Map, :get, [:name])
  end

  def uuid(player) do
    Agent.get(player, Map, :get, [:uuid])
  end

  def status(player) do
    Agent.get(player, Map, :get, [:status])
  end

  def game(player) do
    Agent.get(player, Map, :get, [:game])
  end

  def ready(player) do
    Agent.update(player, Map, :put, [:status, :ready])
  end

  def start_game(player, game) do
    Agent.update(player, Map, :put, [:status, :in_game])
    Agent.update(player, Map, :put, [:game, game])
  end

  def finish_game(player) do
    Agent.update(player, Map, :put, [:status, :idle])
    Agent.update(player, Map, :put, [:game, nil])
  end
end
