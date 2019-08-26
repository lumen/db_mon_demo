defmodule DbMonDemo.TextWorker do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init({value, parent}) do
    document = GenServer.call(DbMonDemo.DocumentSupervisor, :document)

    {:ok, element} = Lumen.Web.Document.create_text_node(document, value)
    {:ok, element} = Lumen.Web.Node.append_child(parent, element)

    {:ok, [element: element]}
  end
end
