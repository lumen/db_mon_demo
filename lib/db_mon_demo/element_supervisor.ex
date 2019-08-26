defmodule DbMonDemo.ElementSupervisor do
  use DbMonDemo.Supervisor

  def start_link(element) do
    DbMonDemo.Supervisor.start_link(__MODULE__, element)
  end

  def init({tag_name, attributes, ast, parent_node}) do
    {:ok, element} = init_element(tag_name, attributes)
    {:ok, element} = Lumen.Web.Node.append_child(parent_node, element)

    children = build_children_from_ast(ast, element)

    {:ok, children, [element: element, ast: ast]}
  end

  def build_children_from_ast([], _element), do: []

  def build_children_from_ast([node | nodes], element) do
    [build_child_from_node(node, element) | build_children_from_ast(nodes, element)]
  end

  def build_child_from_node([:element, tag_name, attributes, children], element) do
    {DbMonDemo.ElementSupervisor, {tag_name, attributes, children, element}}
  end

  def build_child_from_node([:text, value], element) do
    {DbMonDemo.TextWorker, {value, element}}
  end

  defp init_element(tag_name, attributes) do
    document = GenServer.call(DbMonDemo.DocumentSupervisor, :document)
    {:ok, element} = Lumen.Web.Document.create_element(document, tag_name)

    Enum.each(attributes, fn [:attribute, name, value] ->
      Lumen.Web.Element.set_attribute(element, name, value)
    end)

    {:ok, element}
  end

  def handle_call(:element, _from, state) do
    element = Keyword.get(state, :element)
    {:reply, element, state}
  end

  def handle_call(:ast, _from, state) do
    ast = Keyword.get(state, :ast)
    {:reply, ast, state}
  end

  def handle_call(:pid, _from, state) do
    {:reply, self(), state}
  end
end
