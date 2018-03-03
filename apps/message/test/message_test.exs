defmodule MessageTest do
  use ExUnit.Case

  test "encodes to binary" do
    message = %Message{type: :a_type, payload: %{some: "data"}}

    assert {:ok, binary} = Message.encode(message)
    assert is_binary(binary)
  end

  test "decodes from binary" do
    message = %Message{type: :a_type, payload: %{some: "data"}}

    {:ok, binary} = Message.encode(message)

    assert {:ok, ^message} = Message.decode(binary)
  end
end
