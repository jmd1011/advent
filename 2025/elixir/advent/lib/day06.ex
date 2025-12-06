defmodule Advent.Day06 do
  def run do
    parse()
    |> solve()
    |> IO.inspect()
  end

  defp parse do
    {lines, ops} =
      File.stream!("../../input/day06")
      |> Enum.map(&String.trim_trailing/1)
      |> Enum.split_while(&(not String.starts_with?(&1, ["*", "+"])))

    digits =
      lines
      |> Enum.map(fn line ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.chunk_by(&(elem(&1, 0) == " "))
        |> Enum.filter(fn [{c, _} | _] -> c != " " end)
        |> Enum.map(fn ns ->
          ns
          |> Enum.map(fn {n, i} -> {String.to_integer(n), i} end)
        end)
      end)

    nums =
      digits
      |> Enum.map(fn row ->
        row
        |> Enum.map(fn digit_list ->
          digit_list |> Enum.reduce(0, fn {digit, _}, acc -> acc * 10 + digit end)
        end)
      end)

    digit_map =
      digits
      |> Enum.flat_map(& &1)
      |> Enum.reduce(%{}, fn digit_list, map ->
        digit_list
        |> Enum.reduce(map, fn {n, i}, map ->
          Map.update(map, i, n, &(&1 * 10 + n))
        end)
      end)

    {min, max} = Map.keys(digit_map) |> Enum.min_max()

    chunks =
      min..max
      |> Enum.chunk_by(&Map.has_key?(digit_map, &1))
      |> Enum.filter(&(length(&1) > 1))
      |> Enum.map(fn keys -> Enum.map(keys, &Map.fetch!(digit_map, &1)) end)

    opers =
      ops
      |> Enum.flat_map(&String.split/1)
      |> Enum.map(fn
        "+" -> {0, &+/2}
        "*" -> {1, &*/2}
      end)

    transposed_nums = transpose(nums)

    {Enum.zip(transposed_nums, opers), Enum.zip(chunks, opers)}
  end

  defp transpose(rows) do
    rows |> Enum.zip() |> Enum.map(&Tuple.to_list/1)
  end

  defp inner(input) do
    input
    |> Enum.reduce(0, fn {nums, {start, op}}, acc ->
      acc +
        (nums
         |> Enum.reduce(start, fn num, inner_acc ->
           op.(inner_acc, num)
         end))
    end)
  end

  defp solve({p1_input, p2_input}) do
    {inner(p1_input), inner(p2_input)}
  end
end
