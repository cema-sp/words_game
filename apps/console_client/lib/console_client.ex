defmodule ConsoleClient do
  @moduledoc false

  @default_server_host "127.0.0.1"

  alias ConsoleClient.Command
  alias ConsoleClient.Store

  def main(args \\ []) do
    server_host = @default_server_host

    init(server_host: server_host)
    IO.puts "Welcome to the Words Game"
    loop()
  end

  defp init(server_host: server_host) do
    with {:ok, _store} <- Store.start_link() do
      Store.set_server_host(server_host)
    end
  end

  defp loop do
    IO.puts(IO.ANSI.green() <> status() <> IO.ANSI.default_color())

    line = "> " |> IO.gets() |> String.trim()

    case Command.parse(line) do
      {:ok, :no_command} ->
        loop()

      {:ok, command} ->
        case Command.run(command) do
          {:ok, result} ->
            IO.puts("< RESULT: #{result}")
            loop()

          {:error, error} ->
            IO.puts("< ERROR: #{error}")
            loop()

          :quit ->
            IO.puts("< BYE BYE")
        end

      {:error, :unknown_command} ->
        IO.puts("< ERROR: unknown command")
        loop()
    end
  end

  defp status do
    connection_status =
      if Store.connected?(), do: "connected", else: "disconnect"

    name = Store.name() || "<no name>"

    letters =
      Store.letters() |> to_string()

    letters = if letters == "", do: "-", else: letters

    score = Store.score()

    turn =
      if Store.connected?() do
        if Store.my_turn?(), do: "Your turn!", else: "Waiting for another palyer"
      else
        "-"
      end

    sections = [
      connection_status,
      name,
      "letters: #{letters}",
      "score: #{score}",
      turn
    ]

    sections
    |> Enum.map(&("[#{&1}]"))
    |> Enum.join(" ")
  end
end
