defmodule ConsoleClient do
  @moduledoc false

  alias ConsoleClient.Command
  alias ConsoleClient.Store

  def run() do
    init()
    IO.puts "Welcome to the Words Game"
    loop()
  end

  defp init() do
    Store.start_link()
  end

  def loop() do
    # IO.ANSI.clear() |> IO.puts()
    IO.puts(status())

    line = IO.gets("> ") |> String.trim()

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

  defp status() do
    connection_status = if Store.connected?(), do: "connected", else: "disconnect"
    name = Store.name() || "<no name>"

    "[#{connection_status}] [#{name}]"
  end
end
