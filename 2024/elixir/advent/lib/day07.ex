defmodule Advent.Day07 do
  def run do
    IO.inspect(part1())
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
    |> Enum.filter(fn {target, nums} -> calibrated?(target, nums) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  defp calibrated?(target, nums), do: calibrated?(0, target, nums)
  defp calibrated?(curr, target, []), do: curr == target
  defp calibrated?(curr, target, _) when curr > target, do: false

  defp calibrated?(curr, target, [num | nums]) do
    calibrated?(curr + num, target, nums) or calibrated?(curr * num, target, nums)
  end
end
