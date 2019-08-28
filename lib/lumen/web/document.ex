defmodule Lumen.Web.Document do
  def create_element(_docuemnt, tag_name) do
    {:ok, [tag_name, []]}
  end

  def create_text_node(_document, value) do
    {:ok, [value]}
  end

  def body(_document) do
    {:ok, ["body", []]}
  end
end
