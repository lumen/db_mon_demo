defmodule Lumen.Web.Window do
  def window() do
    {:ok, ["window", []]}
  end

  def document(_window) do
    {:ok, ["document", []]}
  end
end
