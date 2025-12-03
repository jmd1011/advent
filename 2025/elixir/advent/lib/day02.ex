defmodule Advent.Day02 do
  def run do
    parse()
    |> Enum.to_list()
    |> tap(&IO.inspect(part1(&1)))
    |> tap(&IO.inspect(part2(&1)))
  end

  defp parse do
    File.stream!("../../input/day02")
    |> Stream.flat_map(&String.split(&1, ",", trim: true))
    |> Stream.map(&String.split(&1, "-", parts: 2))
    |> Stream.map(fn [l, r] -> {String.to_integer(l), String.to_integer(r)} end)
  end

  defp repeated(x, 1), do: x

  defp repeated(x, n) do
    shift = Integer.pow(10, int_len(x))

    1..n
    |> Enum.reduce(0, fn _, acc ->
      acc * shift + x
    end)
  end

  defp patterned?(_, _, 0), do: false
  defp patterned?(_, len, cut_pow) when cut_pow < div(len, 2), do: false

  defp patterned?(x, len, cut_pow) do
    l = div(x, Integer.pow(10, cut_pow))
    l_len = int_len(l)

    if repeated(l, div(len, l_len)) == x do
      true
    else
      patterned?(x, len, cut_pow - 1)
    end
  end

  defp patterned?(x, max_pow) do
    patterned?(x, int_len(x), max_pow)
  end

  defp sum_patterned({l, r}, f) do
    Enum.reduce(l..r, 0, fn x, acc -> if f.(x), do: acc + x, else: acc end)
  end

  defp int_len(x), do: Integer.digits(x) |> length

  defp part1(ranges) do
    ranges
    |> Enum.map(fn range ->
      sum_patterned(range, fn x ->
        patterned?(x, div(int_len(x), 2))
      end)
    end)
    |> Enum.sum()
  end

  defp part2(ranges) do
    ranges
    |> Enum.map(fn range -> sum_patterned(range, fn x -> patterned?(x, int_len(x) - 1) end) end)
    |> Enum.sum()
  end
end
