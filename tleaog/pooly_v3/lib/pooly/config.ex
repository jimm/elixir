defmodule Pooly.Config do
  @moduledoc """
  Configuration struct for Pooly.
  """

  defstruct name: nil, module: nil, function: nil, args: nil, size: 5

  @type t :: %__MODULE__{
    name: String.t,
    module: module,
    function: atom,
    args: [any],
    size: integer
  }
end
