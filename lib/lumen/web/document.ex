defmodule Lumen.Web.Document do
  def create_element(_docuemnt, _tag_name) do
    {:ok, []}
  end

  def create_text_node(_document, _value) do
    {:ok, []}
  end

  def body(_document) do
    {:ok, []}
  end
end
