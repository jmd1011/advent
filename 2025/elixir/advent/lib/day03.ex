defmodule Advent.Day03 do
  def run do
    parse()
    |> tap(&IO.puts(runner(&1, 2)))
    |> tap(&IO.puts(runner(&1, 12)))
  end

  defp parse do
    File.stream!("../../input/day03")
    |> Stream.flat_map(&String.split/1)
    |> Stream.map(fn line ->
      String.graphemes(line) |> Enum.map(&String.to_integer/1)
    end)
  end

  defp find_max_before(bank, i, max_i) do
    bank
    |> Enum.drop(i)
    |> Enum.take(max_i - i + 1)
    |> Enum.with_index(i)
    |> Enum.max_by(fn {val, _} -> val end)
  end

  defp inner(bank, last) do
    with bank_len = length(bank) do
      {res, _} =
        1..last
        |> Enum.reduce({0, -1}, fn from_end, {acc, i} ->
          next_start = i + 1
          next_end = bank_len - last + from_end - 1

          {cur_val, cur_pos} =
            find_max_before(bank, next_start, next_end)

          {acc * 10 + cur_val, cur_pos}
        end)

      res
    end
  end

  defp runner(banks, num) do
    banks |> Enum.map(&inner(&1, num)) |> Enum.sum()
  end
end
