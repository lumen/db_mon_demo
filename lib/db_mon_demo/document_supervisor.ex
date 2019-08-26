defmodule DbMonDemo.DocumentSupervisor do
  use DbMonDemo.Supervisor

  def start_link(ast) do
    DbMonDemo.Supervisor.start_link(__MODULE__, ast, name: __MODULE__)
  end

  def init(ast) do
    window = GenServer.call(DbMonDemo.WindowSupervisor, :window)
    {:ok, document} = Lumen.Web.Window.document(window)

    children = [
      {DbMonDemo.BodySupervisor, ast}
    ]

    {:ok, children, [document: document, ast: ast]}
  end

  def handle_call(:document, _from, state) do
    document = Keyword.get(state, :document)
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
