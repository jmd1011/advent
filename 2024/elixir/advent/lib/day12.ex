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
      {grid |> Enum.group_by(fn {_, c} -> c end, fn {pos, _} -> pos end) |> Map.new(),
       grid |> Map.new()}
    end)
  end

  def part1() do
    {char_to_coord, coord_to_char} = parse()

    char_to_coord
    |> Enum.reduce(0, fn {_, positions}, res ->
      letter =
        Enum.reduce(positions, {0, MapSet.new()}, fn {x, y} = pos, {acc, seen} ->
          {area, perim, nseen} = step(pos, coord_to_char, seen)
          # IO.inspect("{#{x},#{y}} = #{area} * #{perim}")
          # if area > 0 do
          #   IO.inspect(
          #     "A region of #{coord_to_char[pos]} plants with price #{area} * #{perim} = #{area * perim}"
          #   )
          # end

          {acc + area * perim, nseen}
        end)
        |> elem(0)

      res + letter
    end)
  end

  defp step(pos, coord_to_char, seen) do
    if MapSet.member?(seen, pos) do
      {0, 0, seen}
    else
      step(coord_to_char[pos], pos, coord_to_char, seen)
    end
  end

  defp step(char, {x, y} = pos, coord_to_char, seen) do
    cond do
      MapSet.member?(seen, pos) ->
        {0, 0, seen}

      !Map.has_key?(coord_to_char, pos) ->
        {0, 0, seen}

      coord_to_char[pos] != char ->
        {0, 0, seen}

      true ->
        seen = MapSet.put(seen, pos)
        {r_area, r_permiter, r_seen} = step(char, {x + 1, y}, coord_to_char, seen)
        {d_area, d_permiter, d_seen} = step(char, {x, y + 1}, coord_to_char, r_seen)
        {u_area, u_permiter, u_seen} = step(char, {x, y - 1}, coord_to_char, d_seen)
        {l_area, l_permiter, l_seen} = step(char, {x - 1, y}, coord_to_char, u_seen)

        {1 + r_area + d_area + u_area + l_area,
         permiter(pos, coord_to_char) + r_permiter + d_permiter + u_permiter + l_permiter, l_seen}
    end
  end

  defp permiter({x, y} = pos, coord_to_char) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.filter(fn npos -> coord_to_char[npos] != coord_to_char[pos] end)
    |> Enum.count()
  end
end
