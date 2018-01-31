defmodule ConsoleClient.Command do
  @moduledoc false

  alias ConsoleClient.Store
  alias GameServer.Lounge

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

  Await word only when it is my turn

      iex> ConsoleClient.Command.parse("cat")
      {:ok, {:word, "cat"}}

  """
  def parse(""), do: {:ok, :no_command}

  def parse(line) do
    case String.split(line) do
      [":connect", name] -> {:ok, {:connect, name}}
      [":disconnect"] -> {:ok, {:disconnect}}
      [":new", "training"] -> {:ok, {:new_game, :training}}
      [":finish"] -> {:ok, {:finish_game}}
      [":quit"] -> {:ok, {:quit}}
      [":" <> _ | _] -> {:error, :unknown_command}
      [word] -> {:ok, {:word, word}}
      _ -> {:error, :unknown_command}
    end
  end

  def run({:connect, name}) do
    player_uuid = Lounge.join(Lounge, name)
    Store.connected(name, player_uuid)

    {:ok, "connected"}
  end

  def run({:new_game, :training}) do
    player_uuid = Store.uuid()
    {_game_uuid, letters} = Lounge.new_game(Lounge, :training, player_uuid)

    Store.set_letters(letters)
    Store.my_turn(true)

    {:ok, "a new training game created"}
  end

  def run({:word, word}) do
    if Store.my_turn?() do
      player_uuid = Store.uuid()
      case Lounge.word(Lounge, player_uuid, word) do
        {:ok, :miss} ->
          {:ok, "#{inspect(word)} doesn't work, sorry"}

        {:ok, score} ->
          Store.set_score(score)
          {:ok, "you have scored!"}

        {:error, error} ->
          {:error, error}
      end
    else
      {:error, "it is not your turn"}
    end
  end

  def run({:finish_game}) do
    player_uuid = Store.uuid()
    _game_uuid = Lounge.quit_game(Lounge, player_uuid)

    {:ok, "game finished"}
  end

  def run({:disconnect}) do
    # Lounge.quit(Lounge, player_uuid)
    Store.disconnected()

    {:ok, "disconnected"}
  end

  def run({:quit}) do
    {:ok, _} = run({:finish_game})
    {:ok, _} = run({:disconnect})

    :quit
  end

  def run(_) do
    {:error, "Invalid command received"}
  end
end
