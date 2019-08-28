defmodule Lumen.Web.Node do
  def append_child(_element, child), do: {:ok, child}
  def replace_child(_old_element, new_element), do: {:ok, new_element}

  def set_text_content(_element, value), do: [value]

  def insert_before(_parent, new_element, _reference_element), do: {:ok, new_element}
end
