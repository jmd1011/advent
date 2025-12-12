defmodule Advent.Day10 do
  import Bitwise

  def run do
    input = parse()
    IO.puts(inspect(part1(input)))
    IO.puts(inspect(part2(input)))
  end

  defp parse_int_list(l),
    do: l |> String.slice(1..-2//1) |> String.split(",") |> Enum.map(&String.to_integer/1)

  defp parse do
    File.stream!("../../input/day10")
    |> Enum.map(fn line ->
      [[machine], buttons, [joltage]] =
        line
        |> String.split()
        |> Enum.chunk_by(&hd(String.graphemes(&1)))

      {lights, n_lights} =
        machine
        |> String.slice(1..-2//1)
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({0, 0}, fn {c, i}, {acc, width} ->
          case c do
            "]" -> {acc, width}
            "." -> {acc ||| 1 <<< i, width + 1}
            "#" -> {acc, width + 1}
          end
        end)

      button_vals =
        buttons
        |> Enum.map(&parse_int_list/1)

      joltage_vals =
        parse_int_list(joltage)

      {{lights, n_lights}, button_vals, joltage_vals}
    end)
  end

  defp initialized?(lights, n), do: lights == (1 <<< n) - 1

  defp flip(lights, button) do
    button
    |> Enum.reduce(lights, fn i, lights ->
      Bitwise.bxor(lights, 1 <<< i)
    end)
  end

  defp inner({lights, n}, [], steps), do: {initialized?(lights, n), steps}

  defp inner({lights, n}, [h | t], steps) do
    if initialized?(lights, n) do
      {true, steps}
    else
      lights_with = flip(lights, h)
      {worked_with?, steps_with} = inner({lights_with, n}, t, steps + 1)

      {worked_without?, steps_without} = inner({lights, n}, t, steps)

      case {worked_with?, worked_without?} do
        {true, true} -> {true, min(steps_with, steps_without)}
        {false, true} -> {true, steps_without}
        {true, _} -> {true, steps_with}
        {false, _} -> {false, steps}
      end
    end
  end

  defp part1(input) do
    input
    |> Enum.map(fn {lights, buttons, _} -> inner(lights, buttons, 0) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp contains?([], _), do: false
  defp contains?([x | _], x), do: true
  defp contains?([_ | t], x), do: contains?(t, x)

  defp row_echelon_form(buttons, joltages) do
    ref =
      joltages
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {joltage, i}, map ->
        row =
          buttons
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {button, j}, map ->
            Map.put(map, j, if(contains?(button, i), do: 1, else: 0))
          end)

        with_joltage = Map.put(row, map_size(row), joltage)
        Map.put(map, i, with_joltage)
      end)

    reduced_matrix = pivot(0, 0, length(buttons), ref)

    {pivots, frees} = find_pivots(reduced_matrix, length(buttons))

    # TODO: Figure out how to calculate n_guesses instead of hard-coding 200.
    solve(pivots, frees, length(buttons), reduced_matrix, 200)
  end

  defp solve(pivots, frees, n_buttons, reduced_matrix, n_guesses) do
    free_guess_list = generate_guesses(frees, n_guesses)

    solutions =
      free_guess_list
      |> Enum.map(fn free_guesses ->
        minimize(pivots, free_guesses, n_buttons, reduced_matrix)
      end)
      |> Enum.reject(&is_nil/1)

    solutions |> Enum.min()
  end

  defp generate_guesses([], _), do: [%{}]

  defp generate_guesses([h | t], max_val) do
    guesses = generate_guesses(t, max_val)

    for val <- 0..max_val,
        guess <- guesses do
      Map.put(guess, h, val)
    end
  end

  defp swap(row, column, map) do
    swappable_maps =
      row..(map_size(map) - 1)//1
      |> Enum.map(fn i -> {i, Map.get(map, i)} end)

    sorted_swappable =
      swappable_maps
      |> Enum.sort_by(fn {_, row_map} ->
        val = abs(Map.get(row_map, column, 0))

        if val == 0 do
          {2, 0}
        else
          {0, val}
        end
      end)

    [{best_i, best_row} | _] = sorted_swappable

    best_val = Map.get(best_row, column, 0)

    cond do
      best_val == 0 ->
        {nil, map}

      best_i == row ->
        {best_row, map}

      true ->
        cur_row = Map.get(map, row)

        swap_map =
          map
          |> Map.put(row, best_row)
          |> Map.put(best_i, cur_row)

        {best_row, swap_map}
    end
  end

  defp pivot(_, column, n, map) when column >= n, do: map
  defp pivot(row, _, _, map) when row >= map_size(map), do: map

  defp pivot(row, column, n, map) do
    {pivot_row, pivot_map} = swap(row, column, map)

    cond do
      is_nil(pivot_row) ->
        pivot(row, column + 1, n, map)

      true ->
        pivot_val = Map.get(pivot_row, column)
        normalized_row = normalize_row(pivot_row, pivot_val)
        normalized_map = Map.put(pivot_map, row, normalized_row)
        subbed = subtract_rows(row, column, normalized_map)

        is_column_clean? =
          (row + 1)..(map_size(subbed) - 1)//1
          |> Enum.all?(fn r ->
            Map.get(Map.get(subbed, r), column, 0) == 0
          end)

        if is_column_clean? do
          pivot(row + 1, column + 1, n, subbed)
        else
          pivot(row, column, n, subbed)
        end
    end
  end

  defp normalize_row(row, pivot_val) when pivot_val >= 0, do: row

  defp normalize_row(row, pivot_val) do
    row
    |> Enum.reduce(row, fn {k, v}, acc ->
      Map.put(acc, k, -v)
    end)
  end

  defp subtract_rows(row, column, map) do
    cur_row = Map.get(map, row)

    (row + 1)..(map_size(map) - 1)//1
    |> Enum.reduce(map, fn i, map ->
      target_row = Map.get(map, i)
      factor = Map.get(target_row, column, 0)

      if factor == 0 do
        map
      else
        pivot_val = Map.get(cur_row, column, 0)
        multiplier = div(factor, pivot_val)

        reduced_row =
          Map.get(map, i)
          |> Enum.reduce(target_row, fn {j, val}, map ->
            cur_pivot_val = Map.get(cur_row, j, 0)
            Map.put(map, j, val - multiplier * cur_pivot_val)
          end)

        Map.put(map, i, reduced_row)
      end
    end)
  end

  defp find_pivots(map, n_buttons) do
    pivots =
      0..(map_size(map) - 1)
      |> Enum.reduce(%{}, fn row, pivots ->
        cur_row = Map.get(map, row)

        0..(n_buttons - 1)
        |> Enum.reduce_while(pivots, fn col, pivots ->
          if Map.get(cur_row, col) != 0 do
            {:halt, Map.put(pivots, col, row)}
          else
            {:cont, pivots}
          end
        end)
      end)

    frees =
      0..(n_buttons - 1)
      |> Enum.filter(fn i -> not Map.has_key?(pivots, i) end)

    row_to_col_pivots =
      pivots
      |> Enum.map(fn {x, y} -> {y, x} end)
      |> Map.new()

    {row_to_col_pivots, frees}
  end

  defp minimize(pivots, free_guesses, n_buttons, map) do
    vals =
      (map_size(map) - 1)..0//-1
      |> Enum.reduce_while(free_guesses, fn row, val_map ->
        cur_row = Map.get(map, row)
        pivot = Map.get(pivots, row)
        joltage = Map.get(cur_row, n_buttons)

        if is_nil(pivot) do
          if joltage != 0 do
            {:halt, nil}
          else
            {:cont, val_map}
          end
        else
          coefficient = Map.get(cur_row, pivot)

          if coefficient == 0 do
            {:halt, nil}
          else
            val =
              (pivot + 1)..(n_buttons - 1)//1
              |> Enum.reduce(0, fn i, sum ->
                val = Map.get(val_map, i) * Map.get(cur_row, i)
                sum + val
              end)

            target_val = joltage - val

            if rem(target_val, coefficient) == 0 do
              final_val = div(target_val, coefficient)

              if final_val < 0 do
                {:halt, nil}
              else
                {:cont, Map.put(val_map, pivot, final_val)}
              end
            else
              {:halt, nil}
            end
          end
        end
      end)

    if is_nil(vals) do
      nil
    else
      vals
      |> Enum.map(fn {_, val} -> val end)
      |> Enum.sum()
    end
  end

  defp print_row(row) do
    row
    |> Enum.each(fn {_, v} -> IO.write("#{v} ") end)
  end

  defp print_matrix(map) do
    map
    |> Enum.each(fn {_, v} ->
      print_row(v)
      IO.puts("")
    end)
  end

  defp part2(input) do
    input
    |> Enum.map(fn {_, buttons, joltages} -> row_echelon_form(buttons, joltages) end)
    |> Enum.sum()
  end
end
