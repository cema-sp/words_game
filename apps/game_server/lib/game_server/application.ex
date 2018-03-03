defmodule GameServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      GameServer.PlayerSupervisor,
      GameServer.GameSupervisor,
      {GameServer.Lounge, name: GameServer.Lounge},
      {GameServer.TCPServer, name: GameServer.TCPServer}
    ]

    opts = [strategy: :one_for_one, name: GameServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
