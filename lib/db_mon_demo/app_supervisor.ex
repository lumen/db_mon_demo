defmodule DbMonDemo.AppSupervisor do
  use Supervisor

  def start_link(ast) do
    Supervisor.start_link(__MODULE__, ast, name: __MODULE__)
  end

  @spec init(any) :: {:ok, {%{intensity: any, period: any, strategy: any}, [any]}}
  def init(ast) do
    children = [
      {DbMonDemo.WindowSupervisor, ast}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
