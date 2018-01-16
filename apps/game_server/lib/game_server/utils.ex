defmodule GameServer.Utils do
  def generate_uuid(crypto_length \\ 10) do
    crypto_length
    |> :crypto.strong_rand_bytes
    |> Base.encode32()
    |> String.downcase()
  end
end
