defmodule Day03 do
  def parse() do
    File.read!("../input/day03")
  end

  def part1(lines) do
    lines
    |> (&Regex.scan(~r/mul\((\d+),(\d+)\)/, &1))
    |> Enum.map(fn [_, x, y] -> x * y end)
    |> Enum.sum()
  end
end

lines = Day03.parse()
IO.puts(Day03.part1(lines))
