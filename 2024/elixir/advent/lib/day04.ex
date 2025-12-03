defmodule Advent.Day04 do
  def run do
    parse("../../input/day04")
    |> tap(&IO.inspect(part1(&1)))
    |> tap(&IO.inspect(part2(&1)))

    :ok
  end

  defp parse(filename) do
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

  defp part1(grid) do
    grid
    |> Enum.map(fn {pos, c} ->
      dirs()
      |> Enum.filter(&include?(grid, pos, &1, c))
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  defp part2(grid) do
    grid |> Enum.filter(fn {pos, c} -> mas_include?(grid, pos, c) end) |> length()
  end

  defp dirs(), do: [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
  defp mas_dirs(), do: [{{-1, -1}, {1, 1}}, {{-1, 1}, {1, -1}}]

  defp at(grid, pos, default) do
    case grid do
      %{^pos => x} -> x
      %{} -> default
    end
  end

  defp move({x, y}, {xd, yd}), do: {x + xd, y + yd}

  defp step(grid, pos, dir, matched) do
    npos = move(pos, dir)
    include?(grid, npos, dir, at(grid, npos, nil), matched + 1)
  end

  defp include?(grid, pos, dir, c), do: include?(grid, pos, dir, c, 0)
  defp include?(grid, pos, dir, "X", 0 = matched), do: step(grid, pos, dir, matched)
  defp include?(grid, pos, dir, "M", 1 = matched), do: step(grid, pos, dir, matched)
  defp include?(grid, pos, dir, "A", 2 = matched), do: step(grid, pos, dir, matched)
  defp include?(_, _, _, "S", 3), do: true
  defp include?(_, _, _, _, _), do: false

  defp mas_include?(grid, pos, "A") do
    mas_dirs()
    |> Enum.all?(fn {d1, d2} ->
      abs(
        hd(String.to_charlist(at(grid, move(pos, d1), "0"))) -
          hd(String.to_charlist(at(grid, move(pos, d2), "0")))
      ) == abs(?M - ?S)
    end)
  end

  defp mas_include?(_, _, _), do: false
end
