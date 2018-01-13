defmodule GameServer.DictionaryTest do
  use ExUnit.Case, async: true

  describe "check_word/1 when found and of allowed category" do
    test "returns the word" do
      assert GameServer.Dictionary.check_word("swim") ==
        {:ok, "swim"}
    end
  end

  describe "check_word/1 when found and of denied category" do
    test "returns the word" do
      assert GameServer.Dictionary.check_word("other") ==
        {:error, :denied_category}
    end
  end

  describe "check_word/1 when not found" do
    test "returns :not_found" do
      assert GameServer.Dictionary.check_word("notfound") ==
        {:error, :not_found}
    end
  end

  describe "check_word/1 when connection failed" do
    test "returns error" do
      assert {:error, _} = GameServer.Dictionary.check_word("error")
    end
  end
end
