defmodule Lumen.Web.Math do
  def random_integer(max) do
    :rand.uniform(max)
  end
end
