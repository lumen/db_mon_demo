defmodule TemplateDemo.Parser do
  def basic_render do
    EEx.eval_file("lib/templates/app_1.html.eex")
    |> :erlang.binary_to_list()
    |> :xmerl_scan.string()
    |> optimize_doc()
  end

  defp optimize_doc({doc, _}) do
    [walk_element(doc)]
  end

  defp walk_element({:xmlElement, tag_name, _, _, _, _, _, attributes, children, _, _, _}) do
    [:element, tag_name, walk_elements(attributes), walk_elements(children)]
  end

  defp walk_element({:xmlAttribute, attr_name, _, _, _, _, _, _, value, _}) do
    [:attribute, attr_name, :erlang.list_to_binary(value)]
  end

  defp walk_element({:xmlText, _, _, _, text, _}) do
    [:text, :erlang.list_to_binary(text)]
  end

  defp walk_elements([]), do: []

  defp walk_elements([element]) do
    [walk_element(element)]
  end

  defp walk_elements([element | elements]) do
    [walk_element(element) | walk_elements(elements)]
  end
end
