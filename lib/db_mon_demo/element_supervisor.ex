defmodule DbMonDemo.ElementSupervisor do
  use DbMonDemo.Supervisor

  def start_link(element) do
    DbMonDemo.Supervisor.start_link(__MODULE__, element)
  end

  def init({tag_name, attributes, ast, parent_proc, idx}) do
    {:ok, element} = init_element(tag_name, attributes)
    {:ok, element} = append_child(parent_proc, element, idx)

    children = build_children_from_ast(ast, 0)

    {:ok, children, [element: element, tag_name: tag_name, ast: ast, parent_proc: parent_proc]}
  end

  defp init_element(tag_name, attributes) do
    document = GenServer.call(DbMonDemo.DocumentSupervisor, :document)
    {:ok, element} = Lumen.Web.Document.create_element(document, tag_name)

    element =
      Enum.reduce(attributes, element, fn {name, value}, element ->
        {:ok, element} = Lumen.Web.Element.set_attribute(element, name, value)
        element
      end)

    {:ok, element}
  end

  def append_child(parent_proc, child, idx) do
    parent_node = GenServer.call(parent_proc, :element)

    next_child =
      parent_proc
      |> GenServer.call(:children)
      |> Enum.at(idx + 1)

    Lumen.Web.Node.insert_before(parent_node, child, next_child)
    {:ok, child}
  end

  def build_children_from_ast([], _idx), do: []

  def build_children_from_ast([element | elements], idx) do
    [
      build_child_from_node(element, idx)
      | build_children_from_ast(elements, idx + 1)
    ]
  end

  def build_children_from_ast(element, idx) when is_tuple(element) do
    build_children_from_ast([element], idx)
  end

  def build_child_from_node({tag_name, attributes, children}, idx) do
    {DbMonDemo.ElementSupervisor, {tag_name, attributes, children, self(), idx}}
  end

  def build_child_from_node(value, idx) when is_binary(value) do
    {DbMonDemo.TextWorker, {value, self(), idx}}
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
