defmodule Advent.Day03 do
  def run do
    parse()
    |> Enum.to_list()
    |> tap(&IO.puts(part1(&1)))
    |> tap(&IO.puts(part2(&1)))
  end

  defp parse do
    File.stream!("../../input/day03")
    |> Stream.flat_map(&String.split/1)
    |> Stream.map(fn line ->
      String.graphemes(line) |> Enum.map(&String.to_integer/1)
    end)
  end

  # This was my original solution for part 1
  # defp iter([h1, h2 | []]), do: h1 * 10 + h2

  # defp iter([h1, h2, h3 | t]) do
  #   res = max(h1 * 10 + h2, max(h1 * 10 + h3, h2 * 10 + h3))
  #   iter([div(res, 10)] ++ [rem(res, 10)] ++ t)
  # end

  defp list_from(l, target_i, target_i), do: l
  defp list_from([_ | t], i, target_i), do: list_from(t, i + 1, target_i)

  defp find_max_before({9, cur_pos}, _, _, _), do: {9, cur_pos}

  defp find_max_before({cur_val, cur_pos}, _, i, max_i) when i > max_i,
    do: {cur_val, cur_pos}

  defp find_max_before({cur_val, _}, [h | t], i, max_i) when h > cur_val,
    do: find_max_before({h, i}, t, i + 1, max_i)

  defp find_max_before(cur, [_ | t], i, max_i), do: find_max_before(cur, t, i + 1, max_i)

  defp iter2(bank, last) do
    {res, _} =
      1..last
      |> Enum.reduce({0, -1}, fn from_end, {acc, i} ->
        next_start = i + 1
        n_bank = list_from(bank, 0, next_start)
        next_end = length(bank) - last + from_end - 1

        {cur_val, cur_pos} =
          find_max_before(
            {hd(n_bank), next_start},
            n_bank,
            next_start,
            next_end
          )

        {acc * 10 + cur_val, cur_pos}
      end)

    res
  end

  defp part1(banks) do
    banks |> Enum.map(&iter2(&1, 2)) |> Enum.sum()
  end

  defp part2(banks) do
    banks
    |> Enum.map(&iter2(&1, 12))
    # |> tap(fn jolts -> Enum.each(jolts, fn x -> IO.inspect(x) end) end)
    |> Enum.sum()
  end
end
