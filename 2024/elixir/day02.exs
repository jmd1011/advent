defmodule Day02 do
  def parse(filename) do
    File.stream!(filename)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn line -> line |> Enum.map(&String.to_integer/1) end)
  end

  def part1(lines) do
    lines |> Enum.count(&is_safe(&1))
  end

  def part2(lines) do
    lines
    |> Enum.count(&dampener(&1, []))
  end

  defp dampener([head | tail], seen) do
    is_safe(Enum.reverse(seen, tail)) or
      dampener(tail, [head | seen])
  end

  defp dampener([], prefix) do
    is_safe(prefix)
  end

  defp is_safe([head, head | _]), do: false

  defp is_safe([x, y | _] = line) do
    diff = x - y
    is_safe(line, div(diff, abs(diff)))
  end

  defp is_safe(line, sign) do
    Enum.chunk_every(line, 2, 1)
    |> Enum.all?(fn chunks ->
      case chunks do
        [a, b] ->
          (sign * (a - b)) in 1..3

        [_] ->
          true
      end
    end)
  end
end

lines = Day02.parse("../input/day02")
IO.puts(Day02.part1(lines))
IO.puts(Day02.part2(lines))
