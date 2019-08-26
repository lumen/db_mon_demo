defmodule DbMonDemo.BodySupervisor do
  use DbMonDemo.Supervisor
  import DbMonDemo.ElementSupervisor, only: [build_children_from_ast: 2]

  def start_link(ast) do
    DbMonDemo.Supervisor.start_link(__MODULE__, ast, name: __MODULE__)
  end

  def init(ast) do
    document = GenServer.call(DbMonDemo.DocumentSupervisor, :document)
    {:ok, body} = Lumen.Web.Document.body(document)

    children = build_children_from_ast(ast, body)

    {:ok, children, [body: body, ast: ast]}
  end

  def handle_call(:body, _from, state) do
    document = Keyword.get(state, :body)
    {:reply, document, state}
  end

  def handle_call(:ast, _from, state) do
    ast = Keyword.get(state, :ast)
    {:reply, ast, state}
  end

  def handle_call(:pid, _from, state) do
    {:reply, self(), state}
  end
end
