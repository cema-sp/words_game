defmodule GameServer.Player do
  use Agent, restart: :temporary

  defmodule State do
    defstruct [:name, :uuid, status: :idle]
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

  def ready(player) do
    Agent.update(player, Map, :put, [:status, :ready])
  end

  def start_game(player) do
    Agent.update(player, Map, :put, [:status, :in_game])
  end

  def finish_game(player) do
    Agent.update(player, Map, :put, [:status, :idle])
  end

  defp generate_uuid do
    crypto_length = 10

    crypto_length
    |> :crypto.strong_rand_bytes
    |> Base.encode32()
    |> String.downcase()
  end
end
