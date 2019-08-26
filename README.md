# DbMonDemo

Running:

```elixir
ast = DbMonDemo.render(1..50)
{:ok, app_pid} = DbMonDemo.AppSupervisor.start_link(ast)
```