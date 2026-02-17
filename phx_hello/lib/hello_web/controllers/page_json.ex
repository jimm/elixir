defmodule HelloWeb.PageJSON do
  @moduledoc """
  This module contains JSON rendered by PageController.
  """

  def home(_assigns) do
    %{message: "this is some JSON"}
  end
end
