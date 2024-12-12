defmodule Advent.Day12 do
  def run do
    part1() |> IO.inspect()
  end

  defp parse() do
    File.read!("../../input/day12")
    |> String.split()
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.flat_map(fn {char, col} ->
        position = {row, col}
        [{position, char}]
      end)
    end)
    |> then(fn grid ->
      {grid |> Enum.map(&elem(&1, 0)), Map.new(grid)}
    end)
  end

  def part1() do
    {grid, mapping} = parse()

    grid
    |> Enum.reduce({0, MapSet.new()}, fn {x, y} = pos, {acc, seen} ->
      {area, perim, nseen} = step(pos, mapping, seen)
      {acc + area * perim, nseen}
    end)
    |> elem(0)
  end

  defp step(pos, mapping, seen) do
    if MapSet.member?(seen, pos) do
      {0, 0, seen}
    else
      step(mapping[pos], pos, mapping, seen)
    end
  end

  defp step(char, {x, y} = pos, mapping, seen) do
    cond do
      MapSet.member?(seen, pos) ->
        {0, 0, seen}

      !Map.has_key?(mapping, pos) ->
        {0, 0, seen}

      mapping[pos] != char ->
        {0, 0, seen}

      true ->
        seen = MapSet.put(seen, pos)
        {r_area, r_permiter, r_seen} = step(char, {x + 1, y}, mapping, seen)
        {d_area, d_permiter, d_seen} = step(char, {x, y + 1}, mapping, r_seen)

        {1 + r_area + d_area, permiter(pos, mapping) + r_permiter + d_permiter, d_seen}
    end
  end

  defp permiter({x, y} = pos, mapping) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.filter(fn npos -> mapping[npos] != mapping[pos] end)
    |> Enum.count()
  end
end
