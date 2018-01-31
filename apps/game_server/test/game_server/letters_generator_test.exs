defmodule GameServer.LettersGeneratorTest do
  use ExUnit.Case, async: true

  alias GameServer.LettersGenerator

  describe "#generate(n)" do
    test "returns `n` uniq letters" do
      letters = LettersGenerator.generate(8)

      assert length(letters) == 8
      assert Enum.uniq(letters) == letters
    end

    test "for `n` >= 26, returns all the alphabet" do
      letters = LettersGenerator.generate(27)

      assert length(letters) == 26
      assert Enum.uniq(letters) == letters
      assert Enum.sort(letters) == Enum.to_list(?a..?z)
    end
  end
end
