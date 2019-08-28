defmodule DbMonDemo.TextWorker do
  # use GenServer

  import DbMonDemo.ElementSupervisor, only: [append_child: 3]

  def start_link(args) do
    pid = spawn_link(__MODULE__, :init_it, [__MODULE__, self(), args])

    {:ok, pid}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :temporary,
      shutdown: 500
    }
  end

  def init_it(gen_mod, parent_proc, args) do
    {:ok, state} = apply(gen_mod, :init, [args])
    Process.flag(:trap_exit, true)
    loop(gen_mod, parent_proc, state)
  end

  defp loop(gen_mod, parent_proc, state) do
    receive do
      msg ->
        handle_msg(msg, {gen_mod, parent_proc, state})
    end
  end

  defp handle_msg(
         {:system, {to, tag}, {:terminate, reason}},
         {gen_mod, _parent_proc, state}
       ) do
    send(to, {tag, :ok})
    apply(gen_mod, :terminate, [reason, state])
  end

  defp handle_msg(
         {:"$gen_call", {to, tag} = from, msg},
         {gen_mod, parent_proc, state}
       ) do
    case handle_call(msg, from, state) do
      {:reply, return_val, new_state} ->
        send(to, {tag, return_val})
        loop(gen_mod, parent_proc, new_state)
    end
  end

  defp handle_msg({:EXIT, _from, _reason}, {_gen_mod, _parent_proc, _state}) do
    exit(:shutdown)
  end

  defp handle_msg(info, {gen_mod, parent_proc, state}) do
    case handle_info(info, state) do
      {:noreply, new_state} ->
        loop(gen_mod, parent_proc, new_state)
    end
  end

  def init({value, parent_proc, idx}) do
    document = GenServer.call(DbMonDemo.DocumentSupervisor, :document)
    parent_element = GenServer.call(parent_proc, :element)

    case Lumen.Web.Element.get_class_name(parent_element) do
      class_name when class_name in ["time", "query-count"] ->
        Process.send_after(self(), {:update_text, class_name}, 50)

      _other ->
        nil
    end

    {:ok, element} = Lumen.Web.Document.create_text_node(document, value)
    {:ok, element} = append_child(parent_proc, element, idx)

    {:ok, [element: element, value: value, parent_proc: parent_proc]}
  end

  @spec handle_call(:children | :element | :value, any, any) :: {:reply, any, any}
  def handle_call(:value, _from, state) do
    value = Keyword.get(state, :value)
    {:reply, value, state}
  end

  def handle_call(:children, _from, state) do
    {:reply, [], state}
  end

  def handle_call(:element, _from, state) do
    value = Keyword.get(state, :value)
    {:reply, [:text, value], state}
  end

  def handle_info({:update_text, "time"}, state) do
    element = Keyword.get(state, :element)
    Process.send_after(self(), {:update_text, "time"}, 50)
    new_value = Lumen.Web.Math.random_integer(1500) / 100
    Lumen.Web.Node.set_text_content(element, new_value)
    {:noreply, Keyword.put(state, :value, new_value)}
  end

  def handle_info({:update_text, "query-count"}, state) do
    element = Keyword.get(state, :element)
    Process.send_after(self(), {:update_text, "query-count"}, 50)
    new_value = Lumen.Web.Math.random_integer(10)
    Lumen.Web.Node.set_text_content(element, new_value)
    {:noreply, Keyword.put(state, :value, new_value)}
  end
end
