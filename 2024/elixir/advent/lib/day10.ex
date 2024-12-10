defmodule Advent.Day10 do
  def run do
    part1() |> IO.inspect()
    part2() |> IO.inspect()
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
    parse()
    |> then(fn {graph, grid, max_pos} ->
      get_paths(graph, grid, max_pos)
      |> Enum.reduce(0, fn {_, ends}, acc ->
        acc + length(ends)
      end)
    end)
  end

  def part2 do
    {graph, grid, max_pos} = parse()

    get_paths(graph, grid, max_pos)
    |> Enum.map(fn {v1, ends} ->
      Enum.each(ends, fn e -> :digraph.add_edge(graph, e, e) end)
      Enum.map(ends, &count_paths(graph, v1, &1)) |> Enum.sum()
    end)
    |> Enum.sum()
  end

  defp get_paths(graph, grid, {max_x, max_y}) do
    Enum.each(grid, fn {{x, y} = pos, h1} ->
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

      starts
      |> Enum.map(fn v1 ->
        {v1, Enum.filter(ends, fn v2 -> :digraph.get_path(graph, v1, v2) end)}
      end)
      |> Enum.filter(fn {_, v2s} -> length(v2s) > 0 end)
    end)
  end

  defp count_paths(_, v1, v1), do: 1

  defp count_paths(graph, v1, v2) do
    :digraph.out_neighbours(graph, v1)
    |> Enum.filter(&:digraph.get_path(graph, &1, v2))
    |> Enum.map(&count_paths(graph, &1, v2))
    |> Enum.sum()
  end

  defp add_edge(g, v1, v2, -1), do: :digraph.add_edge(g, v1, v2)
  defp add_edge(g, v1, v2, 1), do: :digraph.add_edge(g, v2, v1)
  defp add_edge(_, _, _, _), do: nil
end
