defmodule Advent.Day07 do
  def run do
    IO.inspect(part1())
    IO.inspect(part2())
  end

  defp parse() do
    File.read!("../../input/day07")
    |> String.split("\n")
    |> Enum.map(fn line ->
      [target, nums] = String.split(line, ":")
      target = String.to_integer(target)
      nums = String.split(nums) |> Enum.map(&String.to_integer/1)
      {target, nums}
    end)
  end

  def part1() do
    lines = parse()

    lines
    |> Enum.filter(fn {target, nums} -> calibrated?(target, nums, false) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def part2() do
    lines = parse()

    lines
    |> Enum.filter(fn {target, nums} -> calibrated?(target, nums, true) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  defp calibrated?(target, nums, concat?), do: calibrated?(0, target, nums, concat?)
  defp calibrated?(curr, target, [], _), do: curr == target
  defp calibrated?(curr, target, _, _) when curr > target, do: false

  defp calibrated?(curr, target, [num | nums], concat?) do
    concat = ("#{curr}" <> "#{num}") |> String.to_integer()

    calibrated?(curr + num, target, nums, concat?) or
      calibrated?(curr * num, target, nums, concat?) or
      (!concat? or calibrated?(concat, target, nums, concat?))
  end
end
