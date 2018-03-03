defmodule GameServer.TCPServer do
  use GenServer

  @default_params [
    :binary,
    packet: :line,
    active: true,
    reuseaddr: true
  ]

  ## Client API

  def start_link(opts \\ []) do
    {:ok, ip} = "127.0.0.1" |> to_charlist() |> :inet.parse_address()
    port = 30035

    IO.puts "Starting.."
    GenServer.start_link(__MODULE__, [ip, port], opts)
  end

  ## Server Callbacks

  def init([ip, port]) do
    params = [{:ip, ip} | @default_params]

    {:ok, server_socket} = :gen_tcp.listen(port, params)

    Task.start_link(__MODULE__, :accept, [server_socket, self()])

    {:ok, %{ip: ip, port: port}}
  end

  def handle_info({:tcp, socket, packet}, state) do
    packet |> IO.inspect(label: "Received")

    :gen_tcp.send(socket, "RE: #{packet}")

    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state) do
    IO.puts("Socket has been closed")

    {:noreply, state}
  end

  def handle_info({:tcp_error, socket, reason}, state) do
    reason |> IO.inspect(label: "Error")

    {:noreply, state}
  end

  def handle_info(msg, state) do
    msg |> IO.inspect(label: "MESSAGE")

    {:noreply, state}
  end

  ## Acceptor

  def accept(server_socket, server) do
    IO.puts "Accepting.."

    case :gen_tcp.accept(server_socket) do
      {:ok, client_socket} ->
        :gen_tcp.controlling_process(client_socket, server)
        IO.puts "Accepted!"
      {:error, reason} ->
        IO.puts "Error: #{reason}"
    end

    accept(server_socket, server)
  end
end
