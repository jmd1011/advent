defmodule Advent.Day05 do
  def run do
    parse()
    |> tap(&IO.puts(inspect(part1_2(&1))))
  end

  defp parse do
    lines =
      File.stream!("../../input/day05")
      |> Stream.map(&String.trim/1)
      |> Stream.chunk_by(fn line -> line != "" end)
      |> Stream.filter(fn chunk -> chunk != [""] end)
      |> Enum.to_list()

    [ranges_, inputs] = lines

    ranges =
      for range <- ranges_,
          [left, right] = String.split(range, "-"),
          do: {String.to_integer(left), String.to_integer(right)}

    {ranges |> Enum.sort_by(fn {l, _} -> l end), inputs |> Enum.map(&String.to_integer/1)}
  end

  defp union([], r), do: [r]

  defp union([{l1, r1} | t], {l2, r2}) when l2 in l1..r1//1 do
    [{l1, max(r1, r2)}] ++ t
  end

  defp union([{l1, r1} | t], {l2, r2}), do: [{l1, r1}] ++ union(t, {l2, r2})

  defp part1_2(input) do
    {ranges, inputs} = input

    c_ranges =
      ranges
      |> Enum.reduce([], fn range, acc ->
        union(acc, range)
      end)

    num_fresh =
      c_ranges
      |> Enum.reduce(0, fn {l, r}, acc ->
        acc + Enum.count(l..r)
      end)

    fresh_inputs =
      inputs
      |> Enum.filter(fn input ->
        Enum.any?(c_ranges, fn {l, r} -> input in l..r end)
      end)
      |> Enum.count()

    {fresh_inputs, num_fresh}
  end
end
