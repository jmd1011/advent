defmodule Advent.Day09 do
  def run do
    input = parse()
    IO.puts(part1(input))
    IO.puts(part2(input))
  end

  defp parse do
    vertices =
      File.stream!("../../input/day09")
      |> Enum.map(&String.trim_trailing/1)
      |> Enum.map(fn line ->
        [x, y] = line |> String.split(",", parts: 2) |> Enum.map(&String.to_integer/1)
        {x, y}
      end)

    edges =
      vertices
      |> Enum.chunk_every(2, 1, [hd(vertices)])

    perimeter =
      edges
      |> Enum.reduce(MapSet.new(), fn [{x1, y1}, {x2, y2}], set ->
        min_x = min(x1, x2)
        max_x = max(x1, x2)
        min_y = min(y1, y2)
        max_y = max(y1, y2)

        min_x..max_x
        |> Enum.reduce(set, fn x, set ->
          min_y..max_y
          |> Enum.reduce(set, fn y, set ->
            MapSet.put(set, {x, y})
          end)
        end)
      end)
      |> MapSet.to_list()

    areas =
      for {t1, i1} <- Enum.with_index(vertices),
          {t2, i2} <- Enum.with_index(vertices),
          i1 < i2 do
        {t1, t2, area(t1, t2)}
      end

    {perimeter, areas}
  end

  defp area({x1, y1}, {x2, y2}), do: (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)

  defp part1({_, areas}) do
    areas
    |> Enum.map(&elem(&1, 2))
    |> Enum.max()
  end

  defp in_perimeter?({x1, y1}, {x2, y2}, perimeter) do
    min_x = min(x1, x2)
    max_x = max(x1, x2)
    min_y = min(y1, y2)
    max_y = max(y1, y2)

    perimeter
    |> Enum.reduce_while(perimeter, fn {px, py}, _ ->
      if min_x < px and px < max_x and min_y < py and py < max_y,
        do: {:halt, false},
        else: {:cont, true}
    end)
  end

  defp part2({perimeter, tiles}) do
    tiles
    |> Enum.reduce(0, fn {{x1, y1}, {x2, y2}, area}, acc ->
      if x1 != x2 and y1 != y2 and in_perimeter?({x1, y1}, {x2, y2}, perimeter) do
        max(acc, area)
      else
        acc
      end
    end)
  end
end
