defmodule Message do
  @moduledoc false

  @type t :: %__MODULE__{
    type: atom(),
    payload: map()
  }

  defstruct [:type, payload: %{}]

  @coder Application.get_env(:message, :coder)

  defdelegate encode(message), to: @coder
  defdelegate decode(binary), to: @coder

  def from_map(%{type: type, payload: payload}) do
    %__MODULE__{
      type: String.to_atom(type),
      payload: payload
    }
  end
end
