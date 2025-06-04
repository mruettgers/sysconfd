defmodule SysconfdTest do
  use ExUnit.Case
  doctest Sysconfd

  test "greets the world" do
    assert Sysconfd.hello() == :world
  end
end
