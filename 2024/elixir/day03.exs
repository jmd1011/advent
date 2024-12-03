defmodule Day03 do
  def parse() do
    File.read!("../input/day03")
  end

  def part1(lines) do
    Regex.scan(~r/mul\((\d+),(\d+)\)/, lines)
    |> Enum.map(fn [_, x, y] -> String.to_integer(x) * String.to_integer(y) end)
    |> Enum.sum()
  end

  def part2(lines) do
    pieces =
      String.split(lines, ~r/don't/)
      |> Enum.map(&String.split(&1, ~r/do/))

    p = part1(hd(hd(pieces)))

    p +
      (tl(pieces)
       |> Enum.filter(fn piece -> length(piece) > 1 end)
       |> Enum.map(&Enum.drop(&1, 1))
       |> Enum.join()
       |> part1())
  end
end

lines = Day03.parse()
IO.puts(Day03.part1(lines))
IO.puts(Day03.part2(lines))
