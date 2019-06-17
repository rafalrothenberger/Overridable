defmodule OverridableTest do
  use ExUnit.Case
  doctest Overridable

  test "greets the world" do
    assert Overridable.hello() == :world
  end
end
