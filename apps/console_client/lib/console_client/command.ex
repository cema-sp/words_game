defmodule ConsoleClient.Command do
  @moduledoc false

  alias ConsoleClient.Store

  @doc ~S"""
  Parses a `line` into a command (Tuple).

  ## Examples

      iex> ConsoleClient.Command.parse(":connect NAME")
      {:ok, {:connect, "NAME"}}

      iex> ConsoleClient.Command.parse(":disconnect")
      {:ok, {:disconnect}}

      iex> ConsoleClient.Command.parse(":new training")
      {:ok, {:new_game, :training}}

      iex> ConsoleClient.Command.parse(":finish")
      {:ok, {:finish_game}}

      iex> ConsoleClient.Command.parse(":quit")
      {:ok, {:quit}}

  Unknown commands return an error:

      iex> ConsoleClient.Command.parse(":hello")
      {:error, :unknown_command}

  """
  def parse(""), do: {:ok, :no_command}

  def parse(line) do
    case String.split(line) do
      [":connect", name] -> {:ok, {:connect, name}}
      [":disconnect"] -> {:ok, {:disconnect}}
      [":new", "training"] -> {:ok, {:new_game, :training}}
      [":finish"] -> {:ok, {:finish_game}}
      [":quit"] -> {:ok, {:quit}}
      _ -> {:error, :unknown_command}
    end
  end

  def run({:connect, name}) do
    uuid = GameServer.Lounge.join(GameServer.Lounge, name)
    Store.connected(name, uuid)
    {:ok, "connected"}
  end

  def run({:new_game, :training}) do
    uuid = Store.uuid()
    _uuid = GameServer.Lounge.new_game(GameServer.Lounge, :training, uuid)
    {:ok, "a new training game created"}
  end

  def run({:disconnect}) do
    # uuid = GameServer.Lounge.join(GameServer.Lounge, name)
    Store.disconnected()
    {:ok, "disconnected"}
  end

  def run({:quit}) do
    # disconnect & finish game
    :quit
  end

  def run(_) do
    {:error, "Invalid command received"}
  end
end
