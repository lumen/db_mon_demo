defmodule DbMonDemo.TextWorker do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init({value, parent, column_type}) do
    state = init({value, parent})

    Process.send_after(self(), {:update_text, column_type}, 500)

    state
  end

  def init({value, parent}) do
    document = GenServer.call(DbMonDemo.DocumentSupervisor, :document)
    {:ok, element} = Lumen.Web.Document.create_text_node(document, value)
    {:ok, element} = Lumen.Web.Node.append_child(parent, element)

    {:ok, [element: element, value: value]}
  end

  def handle_call(:value, _from, [value: value] = state) do
    {:reply, value, state}
  end

  def handle_call(:children, _from, state) do
    {:reply, [], state}
  end

  def handle_call(:element, _from, [value: value] = state) do
    {:reply, [:text, value], state}
  end

  def handle_cast({:update_text, :time}, [element: element] = state) do
    new_value = Lumen.Web.Math.random_integer(1500) / 100
    Lumen.Web.Node.set_text_content(element, new_value)
    {:noreply, state}
  end

  def handle_cast({:update_text, :query_count}, [element: element] = state) do
    new_value = Lumen.Web.Math.random_integer(10)
    Lumen.Web.Node.set_text_content(element, new_value)
    {:noreply, state}
  end
end
