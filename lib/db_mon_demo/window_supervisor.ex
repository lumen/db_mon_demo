defmodule DbMonDemo.WindowSupervisor do
  use DbMonDemo.Supervisor

  def start_link(ast) do
    DbMonDemo.Supervisor.start_link(__MODULE__, ast, name: __MODULE__)
  end

  def init(ast) do
    {:ok, window} = Lumen.Web.Window.window()

    children = [
      {DbMonDemo.DocumentSupervisor, ast}
    ]

    {:ok, children, [window: window, ast: ast]}
  end

  def handle_call(:window, _from, state) do
    window = Keyword.get(state, :window)
    {:reply, window, state}
  end

  def handle_call(:ast, _from, state) do
    ast = Keyword.get(state, :ast)
    {:reply, ast, state}
  end

  def handle_call(:pid, _from, state) do
    {:reply, self(), state}
  end
end
