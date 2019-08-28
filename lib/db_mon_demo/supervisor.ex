defmodule DbMonDemo.Supervisor do
  defmacro __using__(_opts) do
    quote do
      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor,
          restart: :temporary,
          shutdown: 500
        }
      end

      def init_it(gen_mod, parent_proc, args) do
        {:ok, children, state} = apply(gen_mod, :init, [args])
        # Process.flag(:trap_exit, true)

        child_list = sup_children(children)

        loop(gen_mod, parent_proc, child_list, state)
      end

      defp loop(gen_mod, parent_proc, children, state) do
        receive do
          msg ->
            handle_msg(msg, {gen_mod, parent_proc, children, state})
        end
      end

      defp sup_children(children) do
        Enum.reduce(children, {[], 0}, fn {mod, args}, {children, index} ->
          {:ok, pid} = restart_child(mod, args)
          children = insert_child_at(children, {pid, mod, args}, index)
          {children, index + 1}
        end)
        |> elem(0)
      end

      defp restart_child(mod, args) do
        {:ok, {module, function_name, args}} =
          mod
          |> apply(:child_spec, [args])
          |> Map.fetch(:start)

        apply(module, function_name, args)
      end

      defp insert_child_at(children, child, index) do
        List.insert_at(children, index, child)
      end

      defp handle_msg(
             {:system, {to, tag}, {:terminate, reason} = msg},
             {gen_mod, _parent_proc, _children, state}
           ) do
        send(to, {tag, :ok})
        apply(gen_mod, :terminate, [reason, state])
      end

      defp handle_msg(
             {:"$gen_call", {to, tag} = from, :children},
             {gen_mod, parent_proc, children, state}
           ) do
        send(to, {tag, Enum.map(children, &elem(&1, 0))})
        loop(gen_mod, parent_proc, children, state)
      end

      defp handle_msg(
             {:"$gen_call", {to, tag} = from, msg},
             {gen_mod, parent_proc, children, state}
           ) do
        case handle_call(msg, from, state) do
          {:reply, return_val, new_state} ->
            send(to, {tag, return_val})
            loop(gen_mod, parent_proc, children, new_state)
        end
      end

      defp handle_msg({:EXIT, from, reason}, {gen_mod, parent_proc, children, state}) do
        case fetch_child_from_pid(children, from) do
          :error ->
            exit(:shutdown)

          {{_pid, mod, args}, index} ->
            {:ok, pid} = restart_child(mod, args)
            children = insert_child_at(children, {pid, mod, args}, index)
            loop(gen_mod, parent_proc, children, state)
        end
      end

      defp fetch_child_from_pid(children, pid) do
        Enum.reduce_while(children, {:error, 0}, fn
          {^pid, child_mod, child_args} = child, {:error, index} -> {:halt, {child, index}}
          {_pid, _child_mod, _child_args}, {:error, index} -> {:cont, {:error, index + 1}}
        end)
        |> case do
          {:error, _index} -> :error
          match -> match
        end
      end

      def terminate(_reason, _state), do: :ok

      defoverridable terminate: 2
    end
  end

  def start_link(gen_mod, args, opts \\ []) do
    pid = spawn_link(gen_mod, :init_it, [gen_mod, self(), args])

    name = Keyword.get(opts, :name)

    if name do
      :erlang.register(name, pid)
    end

    {:ok, pid}
  end
end
