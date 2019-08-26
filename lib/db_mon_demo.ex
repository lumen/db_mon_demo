defmodule DbMonDemo do
  require EEx
  EEx.function_from_file(:def, :template, "lib/templates/db_mon.html.eex", [:rows])

  def db_name(row), do: "cluster#{row}"
  def db_slave_name(row), do: "#{db_name(row)} slave"

  def render(rows) do
    template(rows)
    |> TemplateDemo.Parser.parse()
  end
end
