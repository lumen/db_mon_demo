defmodule Lumen.Web.Element do
  def set_attribute([tag_name, attributes], attribute_name, attribute_value) do
    attributes = List.insert_at(attributes, -1, {attribute_name, attribute_value})
    {:ok, [tag_name, attributes]}
  end

  def get_class_name([_tag_name, attributes]) do
    Enum.find_value(attributes, "", fn
      {"class", class_names} -> class_names
      _attribute -> false
    end)
  end
end
