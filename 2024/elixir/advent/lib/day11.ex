defmodule Advent.Day11 do
  use Memoize

  def run do
    Application.ensure_all_started(:memoize)
    part1() |> IO.inspect()
    part2() |> IO.inspect()
  end

  defp parse do
    File.read!("../../input/day11")
    |> String.split()
  end

  def part1() do
    parse() |> Enum.map(&count(&1, 25)) |> Enum.sum()
  end

  def part2() do
    parse() |> Enum.map(&count(&1, 75)) |> Enum.sum()
  end

  defmemop(count(_, 0), do: 1)

  defmemop count(x, n) do
    step(x) |> Enum.map(&count(&1, n - 1)) |> Enum.sum()
  end

  defp step("0"), do: ["1"]

  defp step(x) do
    cond do
      rem(String.length(x), 2) == 0 ->
        x
        |> String.split_at(div(String.length(x), 2))
        |> then(fn {a, b} -> [a, Integer.to_string(String.to_integer(b))] end)

      true ->
        [Integer.to_string(String.to_integer(x) * 2024)]
    end
  end
end
