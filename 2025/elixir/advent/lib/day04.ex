defmodule Advent.Day04 do
  def run do
    parse()
    |> tap(&IO.puts(part1(&1)))
    |> tap(&IO.puts(part2(&1)))
  end

  defp parse do
    lines = File.stream!("../../input/day04") |> Stream.map(&String.trim_trailing/1)

    for {line, row} <- Stream.with_index(lines),
        {char, col} <- Stream.with_index(String.graphemes(line)),
        into: %{} do
      {{row, col}, if(char == "@", do: :paper, else: :empty)}
    end
  end

  defp is_paper?(grid, coord), do: Map.get(grid, coord, :empty) == :paper

  defp paper_neighbors(grid, {row, col}) do
    for n_row <- (row - 1)..(row + 1),
        n_col <- (col - 1)..(col + 1),
        {n_row, n_col} != {row, col},
        is_paper?(grid, {n_row, n_col}) do
      {n_row, n_col}
    end
  end

  defp inner(grid) do
    for {coord, :paper} <- grid,
        length(paper_neighbors(grid, coord)) < 4 do
      {coord, :paper}
    end
  end

  defp part1(grid) do
    grid
    |> inner()
    |> Enum.count()
  end

  defp part2(grid) do
    can_remove = inner(grid)
    res = length(can_remove)

    if res == 0 do
      res
    else
      res + part2(Map.drop(grid, Enum.map(can_remove, fn {key, _} -> key end)))
    end
  end
end
