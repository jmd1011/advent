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
    inner([&add/2, &mul/2])
  end

  def part2() do
    inner([&add/2, &mul/2, &concat/2])
  end

  defp inner(funcs) do
    parse()
    |> Enum.filter(fn {target, nums} -> calibrated?(target, nums, funcs) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  defp add(x, y), do: x + y
  defp mul(x, y), do: x * y
  defp concat(x, y), do: ("#{x}" <> "#{y}") |> String.to_integer()

  defp calibrated?(target, nums, funcs), do: calibrated?(0, target, nums, funcs)
  defp calibrated?(curr, target, [], _), do: curr == target
  defp calibrated?(curr, target, _, _) when curr > target, do: false

  defp calibrated?(curr, target, [num | nums], funcs) do
    funcs
    |> Enum.any?(fn f ->
      calibrated?(f.(curr, num), target, nums, funcs)
    end)
  end
end
