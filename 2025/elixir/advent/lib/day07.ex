defmodule Advent.Day07 do
  def run do
    parse()
    |> tap(&IO.puts(part1(&1)))
    |> tap(&IO.puts(part2(&1)))
  end

  defp parse do
    File.stream!("../../input/day07")
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.with_index()
    |> Enum.reduce({nil, %{}}, fn {line, row}, {start, grid} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce({start, grid}, fn {char, col}, {start, grid} ->
        case char do
          "S" -> {{row, col}, grid}
          "^" -> {start, Map.put(grid, {row, col}, {:splitter, 0})}
          "." -> {start, Map.put(grid, {row, col}, {:empty, 0})}
        end
      end)
    end)
  end

  defp iter(grid, pos, max) do
    {row, col} = pos

    case Map.get(grid, pos, {:OOB, max}) do
      {:OOB, _} ->
        {0, grid}

      {:empty, x} ->
        n_grid = Map.put(grid, {row, col}, {:empty, x + 1})
        iter(n_grid, {row + 1, col}, max)

      {:splitter, ^max} ->
        {0, grid}

      {:splitter, _} ->
        n_grid = Map.put(grid, pos, {:splitter, 1})
        {right, r_grid} = iter(n_grid, {row, col + 1}, max)
        {left, l_grid} = iter(r_grid, {row, col - 1}, max)
        {1 + right + left, l_grid}
    end
  end

  defp part1({start, grid}) do
    {row, col} = start
    {res, _} = iter(grid, {row + 1, col}, 1)
    res
  end

  defp part2({{start_row, start_col}, grid}) do
    {max_row, max_col} =
      Map.keys(grid)
      |> Enum.reduce({0, 0}, fn {row, col}, {mr, mc} -> {max(row, mr), max(col, mc)} end)

    final =
      1..max_row
      |> Enum.reduce(Map.put(grid, {start_row + 1, start_col}, {:empty, 1}), fn row, acc_grid ->
        0..max_col
        |> Enum.reduce(acc_grid, fn col, n_grid ->
          case Map.get(n_grid, {row, col}) do
            {:empty, n} ->
              {_, up} = Map.get(n_grid, {row - 1, col}, {:OOB, 0})
              Map.put(n_grid, {row, col}, {:empty, up + n})

            {:splitter, _} ->
              {_, up} = Map.get(n_grid, {row - 1, col}, {:OOB, 0})

              left =
                Map.update(n_grid, {row, col - 1}, {:OOB, 0}, fn {label, n} -> {label, n + up} end)

              right =
                Map.update(left, {row, col + 1}, {:OOB, 0}, fn {label, n} -> {label, n + up} end)

              right
          end
        end)
      end)

    0..max_col
    |> Enum.reduce(0, fn col, acc ->
      {_, n} = Map.get(final, {max_row, col})
      acc + n
    end)
  end
end
