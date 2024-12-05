defmodule AdventTest do
  use ExUnit.Case
  doctest Advent

  test "greets the world" do
    assert Advent.hello() == :world
  end

  test "day01" do
    assert Advent.Day01.part1() == 2_196_996
    assert Advent.Day01.part2() == 23_655_822
  end
end
