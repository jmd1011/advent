defmodule Advent.Day06 do
  def run do
    IO.inspect(part1())
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
  end

  defp add({x, y}, {xd, yd}), do: {x + xd, y + yd}

  # Up -> Right
  defp rot({-1, 0}), do: {0, 1}

  # Right -> Down
  defp rot({0, 1}), do: {1, 0}

  # Down -> Left
  defp rot({1, 0}), do: {0, -1}

  # Left -> Up
  defp rot({0, -1}), do: {-1, 0}

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
    cond do
      !Map.has_key?(grid, pos) ->
        0

      MapSet.member?(seen, pos) ->
        ndir = look(grid, pos, dir)
        step(grid, seen, add(pos, ndir), ndir)

      true ->
        ndir = look(grid, pos, dir)
        1 + step(grid, MapSet.put(seen, pos), add(pos, ndir), ndir)
    end
  end
end
