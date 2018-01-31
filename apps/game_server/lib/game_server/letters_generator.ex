defmodule GameServer.LettersGenerator do
  def generate(0), do: []
  def generate(n) when n > 26, do: generate(26)

  def generate(n) do
    do_generate(n, [])
  end

  defp do_generate(n, letters, alphabet \\ Enum.to_list(?a..?z))
  defp do_generate(0, letters, _), do: letters

  defp do_generate(n, letters, alphabet) do
    idx = alphabet |> length() |> :rand.uniform()

    {char, alphabet} = List.pop_at(alphabet, idx - 1)

    do_generate(n - 1, [char | letters], alphabet)
  end
end
