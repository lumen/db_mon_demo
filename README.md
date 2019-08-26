# DbMonDemo

Running:

```elixir
ast = TemplateDemo.Parser.basic_render()
{:ok, app_pid} = DbMonDemo.AppSupervisor.start_link(ast)
```