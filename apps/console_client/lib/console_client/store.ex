defmodule ConsoleClient.Store do
  use Agent

  @initial_state %{
    server_host: nil,
    name: nil,
    uuid: nil,
    connected: false,
    turn: false,
    letters: [],
    score: 0
  }

  def start_link, do: start_link([])

  def start_link(_) do
    Agent.start_link(fn -> @initial_state end, name: __MODULE__)
  end

  def connected? do
    Agent.get(__MODULE__, Map, :get, [:connected])
  end

  def my_turn? do
    Agent.get(__MODULE__, Map, :get, [:turn])
  end

  def server_host do
    Agent.get(__MODULE__, Map, :get, [:server_host])
  end

  def name do
    Agent.get(__MODULE__, Map, :get, [:name])
  end

  def uuid do
    Agent.get(__MODULE__, Map, :get, [:uuid])
  end

  def letters do
    Agent.get(__MODULE__, Map, :get, [:letters])
  end

  def score do
    Agent.get(__MODULE__, Map, :get, [:score])
  end

  def set_server_host(server_host) do
    Agent.update(__MODULE__, Map, :put, [:server_host, server_host])
  end

  def set_letters(letters) do
    Agent.update(__MODULE__, Map, :put, [:letters, letters])
  end

  def set_score(score) do
    Agent.update(__MODULE__, Map, :put, [:score, score])
  end

  def my_turn(turn) do
    Agent.update(__MODULE__, Map, :put, [:turn, turn])
  end

  def connected(name, uuid) do
    Agent.update(__MODULE__, fn state ->
      %{state | connected: true, name: name, uuid: uuid}
    end)
  end

  def disconnected do
    Agent.update(__MODULE__, fn state ->
      %{state | connected: false, name: nil, uuid: nil}
    end)
  end
end
