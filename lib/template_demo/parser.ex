defmodule TemplateDemo.Parser do
  def parse(html), do: Floki.parse(html)
end
