defmodule Lumen.Web.Node do
  def append_child(_element, child), do: {:ok, child}
  def replace_child(_old_element, new_element), do: {:ok, new_element}
end
