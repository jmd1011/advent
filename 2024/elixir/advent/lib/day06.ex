defmodule Advent.Day06 do
  def run do
    # IO.inspect(part1())
    IO.inspect(part2())
  end

  def parse(filename) do
    File.read!(filename)
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
    |> Map.new()
  end

  def part1() do
    grid = parse("../../input/day06")
    {start_pos, _} = grid |> Enum.find(fn {_, c} -> c == "^" end)

    step(grid, MapSet.new(), start_pos, {-1, 0})
    |> elem(1)
    |> Enum.map(fn {pos, _} -> pos end)
    |> MapSet.new()
    |> MapSet.size()
  end

  def part2() do
    grid = parse("../../input/day06")
    {start_pos, _} = grid |> Enum.find(fn {_, c} -> c == "^" end)
    possibles = step(grid, MapSet.new(), start_pos, {-1, 0}) |> elem(1)

    # possibles
    [{5, 3}]
    |> Enum.reduce(0, fn pos, acc ->
      IO.inspect("Checking position:")
      IO.inspect(pos)
      case step(Map.put(grid, pos, "#"), MapSet.new(), start_pos, {-1, 0}) do
        {:cyclic, _} -> acc + 1
        _ -> acc
      end
    end)
  end

  defp add({x, y}, {xd, yd}), do: {x + xd, y + yd}
  defp rot({x, y}), do: {y, -x}

  defp look(grid, pos, dir) do
    npos = add(pos, dir)

    cond do
      !Map.has_key?(grid, npos) ->
        dir

      grid[npos] == "#" ->
        look(grid, pos, rot(dir))

      true ->
        dir
    end
  end

  defp step(grid, seen, pos, dir) do
    test =
      seen
      |> Enum.filter(fn {seen_pos, seen_dir} ->
        seen_pos == pos
      end)

    case pos do
      {6, 4} ->
        IO.puts("At")
        IO.inspect(pos)
        IO.puts("and going")
        IO.inspect(dir)

        IO.inspect(test)
        IO.puts("Have we seen this before: #{MapSet.member?(seen, {pos, dir})}")
      _ -> nil
    end

    cond do
      !Map.has_key?(grid, pos) ->
        {:acyclic, seen}

      MapSet.member?(seen, {pos, dir}) ->
        {:cyclic, seen}

      true ->
        ndir = look(grid, pos, dir)
        step(grid, MapSet.put(seen, {pos, dir}), add(pos, ndir), ndir)
    end
  end
end
