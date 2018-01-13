defmodule GameServer.PlayerSupervisor do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def create_player do
    Supervisor.start_child(__MODULE__, [])
  end

  def init(:ok) do
    Supervisor.init([GameServer.Player], strategy: :simple_one_for_one)
  end
end
