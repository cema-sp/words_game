defmodule GameServer.GameSupervisor do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def create_game do
    Supervisor.start_child(__MODULE__, [])
  end

  def init(:ok) do
    Supervisor.init([GameServer.Game], strategy: :simple_one_for_one)
  end
end
