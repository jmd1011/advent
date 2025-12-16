defmodule Advent.Day12 do
  def run do
    IO.puts(solve())
  end

  defp solve do
    {[regions], shapes} =
      File.stream!("../../input/day12")
      |> Enum.map(&String.trim_trailing/1)
      |> Enum.chunk_by(&(&1 == ""))
      |> Enum.filter(&(&1 != [""]))
      |> Enum.split_with(fn parts -> String.contains?(hd(parts), "x") end)

    shape_areas =
      shapes
      |> Enum.reduce(%{}, fn [index | shape], shape_areas ->
        i = index |> String.slice(0..-2//1) |> String.to_integer()

        area =
          shape
          |> Enum.flat_map(&String.graphemes/1)
          |> Enum.count(&(&1 == "#"))

        Map.put(shape_areas, i, area)
      end)

    regions
    |> Enum.count(fn region ->
      [area, reqs] = region |> String.split(":", parts: 2)
      [w, l] = area |> String.split("x", parts: 2) |> Enum.map(&String.to_integer/1)

      {num_presents, requested_area} =
        reqs
        |> String.trim_leading()
        |> String.split()
        |> Enum.map(&String.to_integer/1)
        |> Enum.with_index()
        |> Enum.filter(fn {n, _} -> n > 0 end)
        |> Enum.reduce({0, 0}, fn {n, i}, {presents, requested_area} ->
          {presents + n, requested_area + n * Map.fetch!(shape_areas, i)}
        end)

      max_num_presents = div(w, 3) * div(l, 3)
      max_area = w * l

      max_num_presents >= num_presents and max_area >= requested_area
    end)
  end
end
