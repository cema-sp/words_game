defmodule ConsoleClient.Store do
  use Agent

  # defmodule State do
  #   defstruct [:name, :uuid, connected: false]
  # end

  @initial_state %{name: nil, uuid: nil, connected: false}

  def start_link(), do: start_link([])

  def start_link(_) do
    Agent.start_link(fn -> @initial_state end, name: __MODULE__)
  end

  def connected?() do
    Agent.get(__MODULE__, Map, :get, [:connected])
  end

  def name() do
    Agent.get(__MODULE__, Map, :get, [:name])
  end

  def uuid() do
    Agent.get(__MODULE__, Map, :get, [:uuid])
  end

  def connected(name, uuid) do
    Agent.update(__MODULE__, fn state ->
      %{state | connected: true, name: name, uuid: uuid}
    end)
  end

  def disconnected() do
    Agent.update(__MODULE__, fn state ->
      %{state | connected: false, name: nil, uuid: nil}
    end)
  end
end
