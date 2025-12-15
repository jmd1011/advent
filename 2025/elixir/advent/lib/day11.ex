defmodule Advent.Day11 do
  def run do
    input = parse()
    IO.puts(inspect(part1(input)))
    IO.puts(inspect(part2(input)))
  end

  defp parse do
    File.stream!("../../input/day11")
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&String.split(&1, ":", parts: 2))
    |> Enum.reduce(%{}, fn [src, sinks], map ->
      String.split(sinks)
      |> Enum.reduce(map, fn sink, map ->
        Map.update(map, src, [sink], fn l -> [sink | l] end)
      end)
    end)
  end

  defp search("out", _, _, criteria_vals, criteria, _, cache) do
    if criteria.(criteria_vals) do
      {1, cache}
    else
      {0, cache}
    end
  end

  defp search(cur, map, seen, criteria_vals, criteria, update_criteria, cache) do
    seen_dac? = cur == "dac"
    seen_fft? = cur == "fft"

    criteria_vals = update_criteria.(criteria_vals, {seen_dac?, seen_fft?})

    cache_key = {cur, criteria_vals}

    cond do
      Map.has_key?(cache, cache_key) ->
        {Map.get(cache, cache_key), cache}

      MapSet.member?(seen, cur) ->
        {0, Map.put(cur, cache_key, 0)}

      true ->
        neighbors = Map.get(map, cur)

        {vals, cache} =
          neighbors
          |> Enum.map_reduce(
            cache,
            fn neighbor, cache ->
              search(
                neighbor,
                map,
                MapSet.put(seen, cur),
                criteria_vals,
                criteria,
                update_criteria,
                cache
              )
            end
          )

        res = vals |> Enum.sum()
        {res, Map.put(cache, cache_key, res)}
    end
  end

  defp part1(input) do
    {res, _} =
      search("you", input, MapSet.new(), {true}, fn _ -> true end, fn _, _ -> {true} end, %{})

    res
  end

  defp part2(input) do
    {res, _} =
      search(
        "svr",
        input,
        MapSet.new(),
        {false, false},
        fn {seen_dac?, seen_fft?} -> seen_dac? and seen_fft? end,
        fn {already_seen_dac?, already_seen_fft?}, {seen_dac?, seen_fft?} ->
          {already_seen_dac? or seen_dac?, already_seen_fft? or seen_fft?}
        end,
        %{}
      )

    res
  end
end
