defmodule Advent.Day05 do
  def run do
    parse()
    |> solve()
    |> IO.inspect()
  end

  defp parse do
    {ranges_, [_ | inputs]} =
      File.stream!("../../input/day05")
      |> Enum.map(&String.trim/1)
      |> Enum.split_while(&(&1 != ""))

    ranges =
      for range <- ranges_,
          [left, right] = String.split(range, "-"),
          do: {String.to_integer(left), String.to_integer(right)}

    {ranges |> Enum.sort_by(&elem(&1, 0)) |> Enum.reduce([], &union/2),
     inputs |> Enum.map(&String.to_integer/1)}
  end

  defp union(r, []), do: [r]

  defp union({l2, r2}, [{l1, r1} | t]) when l1 - 1 <= l2 and l2 <= r1 + 1 do
    [{l1, max(r1, r2)} | t]
  end

  defp union({l2, r2}, [{l1, r1} | t]), do: [{l1, r1} | union({l2, r2}, t)]

  defp solve({ranges, inputs}) do
    num_fresh =
      ranges
      |> Enum.reduce(0, fn {l, r}, acc ->
        acc + r - l + 1
      end)

    fresh_inputs =
      inputs
      |> Enum.count(fn input ->
        Enum.any?(ranges, fn {l, r} -> input in l..r end)
      end)

    {fresh_inputs, num_fresh}
  end
end
