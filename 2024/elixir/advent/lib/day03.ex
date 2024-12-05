defmodule Advent.Day03 do
  def run do
    lines = parse()
    IO.puts(part1(lines))
    IO.puts(part2(lines))
  end

  defp parse() do
    File.read!("../../input/day03")
  end

  defp part1(lines) do
    Regex.scan(~r/mul\((\d+),(\d+)\)/, lines)
    |> Enum.map(fn [_, x, y] -> String.to_integer(x) * String.to_integer(y) end)
    |> Enum.sum()
  end

  defp part2(lines) do
    pieces =
      String.split(lines, ~r/don't/)
      |> Enum.map(&String.split(&1, ~r/do/))

    part1(hd(hd(pieces))) +
      (tl(pieces)
       |> Enum.filter(fn piece -> length(piece) > 1 end)
       |> Enum.map(&Enum.drop(&1, 1))
       |> Enum.join()
       |> part1())
  end
end
