defmodule Message.Coder.Json do
  @behaviour Message.Coder

  def encode(message) do
    Poison.encode(message)
  end

  def decode(binary) do
    with {:ok, map} <- Poison.decode(binary) do
      message = map |> atomize_keys() |> Message.from_map()
      {:ok, message}
    end
  end

  defp atomize_keys(map) when is_map(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), atomize_keys(val)}
  end

  defp atomize_keys(vals), do: vals
end
