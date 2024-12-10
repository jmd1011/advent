defmodule Advent.Day08 do
  def run do
    part1()
    part2()
  end

  def parse() do
    lines =
      File.read!("../../input/day08")
      |> String.split()
      |> then(fn lines ->
        max_pos = {String.length(hd(lines)), length(lines)}

        mapping =
          lines
          |> Enum.with_index()
          |> Enum.flat_map(fn {line, row} ->
            String.graphemes(line)
            |> Enum.with_index()
            |> Enum.flat_map(fn {char, col} ->
              position = {row, col}
              [{char, position}]
            end)
          end)
          |> Enum.filter(fn {char, _} -> char != "." end)
          |> Enum.reduce(Map.new(), fn {char, pos}, acc ->
            if !Map.has_key?(acc, char) do
              Map.put(acc, char, [pos])
            else
              Map.put(acc, char, [pos | acc[char]])
            end
          end)

        {mapping, max_pos}
      end)
  end

  def part1() do
    inner(fn pos1, pos2, _ -> antinodes(pos1, pos2) end)
  end

  def part2() do
    inner(fn {x1, y1} = pos1, {x2, y2} = pos2, max_pos ->
      diff = {x1 - x2, y1 - y2}
      all_antinodes(pos1, diff, max_pos) ++ all_antinodes(pos2, neg(diff), max_pos)
    end)
  end

  defp inner(antinode_func) do
    {mapping, max_pos} = parse()

    mapping
    |> Enum.reduce(MapSet.new(), fn {_, positions}, acc ->
      pos_pairs(positions)
      |> Enum.map(fn {pos1, pos2} ->
        antinode_func.(pos1, pos2, max_pos)
      end)
      |> Enum.flat_map(fn pos -> pos end)
      |> Enum.reduce(acc, fn pos, nacc -> MapSet.put(nacc, pos) end)
    end)
    |> Enum.filter(&valid?(&1, max_pos))
    |> Enum.count()
    |> IO.inspect()
  end

  defp pos_pairs([_ | []]), do: []

  defp pos_pairs([h | t]) do
    Enum.zip(Stream.cycle([h]), t) ++ pos_pairs(t)
  end

  defp valid?({x1, y1}, {max_x, max_y}), do: x1 >= 0 and y1 >= 0 and x1 < max_x and y1 < max_y
  defp add({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
  defp neg({x, y}), do: {-x, -y}

  defp antinodes({x1, y1} = pos1, {x2, y2} = pos2) do
    diff = {x1 - x2, y1 - y2}
    [add(pos1, diff), add(pos2, neg(diff))]
  end

  defp all_antinodes(pos, diff, max_pos) do
    Enum.take_while(
      Stream.unfold(pos, fn pos ->
        {pos, add(pos, diff)}
      end),
      fn pos ->
        valid?(pos, max_pos)
      end
    )
  end
end
