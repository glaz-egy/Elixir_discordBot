defmodule Discordbot2Test do
  use ExUnit.Case
  doctest Discordbot2

  test "greets the world" do
    assert Discordbot2.hello() == :world
  end
end
