defmodule Advent.Day10 do
  def run do
    part1() |> IO.inspect()
  end

  defp parse do
    graph = :digraph.new()

    File.read!("../../input/day10")
    |> String.split()
    |> then(fn lines ->
      max_pos = {String.length(hd(lines)) - 1, length(lines) - 1}

      grid =
        lines
        |> Enum.with_index()
        |> Enum.flat_map(fn {line, row} ->
          String.graphemes(line)
          |> Enum.with_index()
          |> Enum.flat_map(fn {char, col} ->
            position = {row, col}
            :digraph.add_vertex(graph, position)
            [{position, String.to_integer(char)}]
          end)
        end)
        |> Map.new()

      {graph, grid, max_pos}
    end)
  end

  def part1 do
    {graph, grid, max_pos} = parse()
    {starts, ends} = get_paths(graph, grid, max_pos)

    Enum.reduce(starts, 0, fn v1, acc ->
      acc +
        Enum.count(ends, fn v2 ->
          :digraph.get_path(graph, v1, v2)
        end)
    end)
  end

  defp get_paths(graph, grid, {max_x, max_y}) do
    Enum.each(grid, fn {{x, y} = pos, h1} ->
      # This is gross, clean this up.

      if x < max_x do
        pos2 = {x + 1, y}
        h2 = grid[pos2]
        :digraph.vertex(graph, pos2)
        add_edge(graph, pos, pos2, h1 - h2)
      end

      if y < max_y do
        pos2 = {x, y + 1}
        h2 = grid[pos2]
        add_edge(graph, pos, pos2, h1 - h2)
      end
    end)

    grid
    |> Enum.filter(fn {_, height} -> height == 0 or height == 9 end)
    |> Enum.split_with(fn {_, height} -> height == 0 end)
    |> then(fn {starts, ends} ->
      starts = starts |> Enum.map(&elem(&1, 0))
      ends = ends |> Enum.map(&elem(&1, 0))

      valid_starts =
        Enum.filter(starts, fn v1 ->
          Enum.any?(ends, fn v2 -> :digraph.get_path(graph, v1, v2) end)
        end)

      valid_ends =
        Enum.filter(ends, fn v2 ->
          Enum.any?(valid_starts, fn v1 -> :digraph.get_path(graph, v1, v2) end)
        end)

      {valid_starts, valid_ends}
    end)
  end

  defp add_edge(g, v1, v2, -1), do: :digraph.add_edge(g, v1, v2)
  defp add_edge(g, v1, v2, 1), do: :digraph.add_edge(g, v2, v1)
  defp add_edge(_, _, _, _), do: nil
end
