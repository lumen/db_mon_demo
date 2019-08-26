defmodule TemplateDemoTest do
  use ExUnit.Case
  doctest TemplateDemo

  test "greets the world" do
    assert TemplateDemo.hello() == :world
  end
end
