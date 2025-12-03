defmodule Advent.Day01 do
  def run do
    {part1(), part2()}
  end

  def parse() do
    lines = File.stream!("../../input/day01") |> Enum.map(&String.split/1)
    l = lines |> Enum.map(&hd/1) |> Enum.map(&String.to_integer/1) |> Enum.sort()

    r =
      lines |> Enum.map(&tl/1) |> Enum.map(&hd/1) |> Enum.map(&String.to_integer/1) |> Enum.sort()

    {l, r}
  end

  def part1() do
    {l, r} = parse()
    List.zip([l, r]) |> Enum.map(&abs(elem(&1, 0) - elem(&1, 1))) |> Enum.sum()
  end

  def part2() do
    {l, r} = parse()
    freqs = Enum.frequencies(r)
    l |> Enum.map(&(&1 * Map.get(freqs, &1, 0))) |> Enum.sum()
  end
end
