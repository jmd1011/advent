defmodule Advent.Day12_Unused do
  def run do
    input = parse()
    IO.puts(part1(input))
  end

  defmodule Region do
    defstruct [:rows, :cols, :requests]
  end

  defmodule Request do
    defstruct [:n, :shape]
  end

  defp parse do
    {[regions], shapes} =
      File.stream!("../../input/day12")
      |> Enum.map(&String.trim_trailing/1)
      |> Enum.chunk_by(&(&1 == ""))
      |> Enum.filter(&(&1 != [""]))
      |> Enum.split_with(fn parts -> String.contains?(hd(parts), "x") end)

    {shape_areas, shapes} =
      shapes
      |> Enum.reduce({%{}, %{}}, fn [index | shape], {shape_areas, acc} ->
        i = index |> String.slice(0..-2//1) |> String.to_integer()

        og_shape_coords =
          shape
          |> build_coords()

        flipped_shape_coords =
          shape
          |> Enum.reverse()
          |> build_coords()

        coord_set =
          build_rotations(og_shape_coords, MapSet.new())
          |> then(&build_rotations(flipped_shape_coords, &1))

        coords =
          coord_set
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {shape_set, var}, map ->
            Map.put(map, var, shape_set)
          end)

        {Map.put(shape_areas, i, MapSet.size(og_shape_coords)), Map.put(acc, i, coords)}
      end)

    shape_areas =
      shape_areas |> Enum.sort_by(fn {_, area} -> area end, :desc) |> Map.new()

    regions =
      regions
      |> Enum.map(fn region ->
        [area, reqs] = region |> String.split(":", parts: 2)
        [w, l] = area |> String.split("x", parts: 2) |> Enum.map(&String.to_integer/1)

        reqs =
          reqs
          |> String.trim_leading()
          |> String.split()
          |> Enum.map(&String.to_integer/1)
          |> Enum.with_index()
          |> Enum.filter(fn {n, _} -> n > 0 end)
          |> Enum.sort_by(
            fn {_, i} ->
              Map.fetch!(shape_areas, i)
            end,
            :desc
          )
          |> Enum.map(fn {n, i} -> %Request{n: n, shape: i} end)

        %Region{cols: w, rows: l, requests: reqs}
      end)

    {shape_areas, shapes, regions}
  end

  defp build_coords(shape) do
    shape
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, row}, set ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _} -> char == "#" end)
      |> Enum.reduce(set, fn {_, col}, set -> MapSet.put(set, {row, col}) end)
    end)
  end

  defp build_rotations(shape_coords, coord_set) do
    {_, coord_set} =
      1..4
      |> Enum.reduce({shape_coords, coord_set}, fn _, {shape, coord_set} ->
        rotated =
          shape
          |> Enum.map(fn {row, col} ->
            {col, -row}
          end)
          |> normalize()

        {rotated, MapSet.put(coord_set, rotated)}
      end)

    coord_set
  end

  defp normalize(coords) do
    {min_r, _} = Enum.min_by(coords, fn {r, _} -> r end)
    {_, min_c} = Enum.min_by(coords, fn {_, c} -> c end)

    coords
    |> Enum.map(fn {r, c} -> {r - min_r, c - min_c} end)
    |> MapSet.new()
  end

  # defp print_shape(coords) do
  #   {{min_r, _}, {max_r, _}} = Enum.min_max_by(coords, fn {r, _} -> r end)
  #   {{_, min_c}, {_, max_c}} = Enum.min_max_by(coords, fn {_, c} -> c end)

  #   for col <- min_c..max_c do
  #     for row <- min_r..max_r do
  #       if MapSet.member?(coords, {row, col}) do
  #         IO.write("#")
  #       else
  #         IO.write(".")
  #       end
  #     end

  #     IO.puts("")
  #   end
  # end

  # defp print_used(cols, rows, used) do
  #   for row <- 0..(rows - 1) do
  #     for col <- 0..(cols - 1) do
  #       if MapSet.member?(used, {row, col}) do
  #         IO.write("#")
  #       else
  #         IO.write(".")
  #       end
  #     end

  #     IO.puts("")
  #   end
  # end

  # Fit everything.
  defp can_fit?(_shape_areas, _shape_map, _shape_var, region, _used)
       when length(region.requests) == 0,
       do: true

  # Fit all shapes of type i, move to the next present type.
  defp can_fit?(shape_areas, shape_map, _shape_var, region, used) when hd(region.requests).n == 0,
    do:
      can_fit?(
        shape_areas,
        shape_map,
        0,
        %Region{cols: region.cols, rows: region.rows, requests: tl(region.requests)},
        used
      )

  # Try to fit 1 shape_i_j where i = type of shape, j = variation of that shape.
  defp can_fit?(shape_areas, shape_map, shape_var, region, used) do
    [req | reqs] = region.requests
    IO.puts("shape: #{req.shape}, variation: #{shape_var}")
    cur_shape_vars = Map.fetch!(shape_map, req.shape)

    cond do
      not fit_possible?(shape_areas, region, used) ->
        # Not enough area to fit this, bail.
        false

      not Map.has_key?(cur_shape_vars, shape_var) ->
        # We've checked every variation of this shape and none of them work.
        false

      true ->
        # Technically enough area, let's see if shape of variation `shape_var` can fit.
        cur_shape = Map.fetch!(cur_shape_vars, shape_var)

        # Find all the unused locations.
        # TODO: Should this only return unused locations of area N or something?
        unused = get_unused(region.cols, region.rows, used)

        # IO.puts("Attempting to place this shape:")
        # print_shape(cur_shape)
        # IO.puts("Current grid:")
        # print_used(region.cols, region.rows, used)

        {fit?, used} =
          unused
          |> Enum.reduce_while({false, used}, fn pos, {_found, acc} ->
            # `{row, col}` represents an unused place. We should try placing `cur_shape` there. If it
            # fits, we should then recursively call `can_fit?` to see if this solves the entire
            # problem. If it doesn't, we should move to the next unused place. Once we've tried every
            # unused place with this shape/variation, we should move to the next shape variation
            # (by rercusing).
            # IO.puts("Checking at #{inspect({pos})}")

            if can_place_at?(cur_shape, pos, region.cols, region.rows, acc) do
              # with_used = MapSet.put(acc, pos)
              with_used = place(cur_shape, pos, acc)

              # IO.puts(
              #   "Successfully placed shape #{req.shape} (variation #{shape_var}) at position #{inspect(pos)}"
              # )

              # print_used(region.cols, region.rows, with_used)

              if can_fit?(
                   shape_areas,
                   shape_map,
                   0,
                   %Region{
                     cols: region.cols,
                     rows: region.rows,
                     requests: [%Request{n: req.n - 1, shape: req.shape} | reqs]
                   },
                   with_used
                 ) do
                {:halt, {true, with_used}}
              else
                {:cont, {false, acc}}
              end
            else
              {:cont, {false, acc}}
            end
          end)

        if fit? do
          true
        else
          # `shape` of type `shape_var` didn't work. We should recurse with the next variation.
          can_fit?(shape_areas, shape_map, shape_var + 1, region, used)
        end
    end
  end

  defp get_unused(cols, rows, used) do
    for row <- 0..(rows - 1),
        col <- 0..(cols - 1),
        not MapSet.member?(used, {row, col}) do
      {row, col}
    end
  end

  defp place(shape, {row, col}, used) do
    shape
    |> Enum.reduce(used, fn {shape_row, shape_col}, used ->
      row_pos = row + shape_row
      col_pos = col + shape_col
      pos = {row_pos, col_pos}
      MapSet.put(used, pos)
    end)
  end

  defp can_place_at?(shape, {row, col}, cols, rows, used) do
    shape
    |> Enum.all?(fn {shape_row, shape_col} ->
      row_pos = row + shape_row
      col_pos = col + shape_col
      pos = {row_pos, col_pos}

      fits_row? = row_pos < rows
      fits_col? = col_pos < cols
      is_used? = MapSet.member?(used, pos)

      not is_used? and fits_row? and fits_col?
    end)
  end

  defp fit_possible?(shape_areas, region, used) do
    required_space =
      region.requests
      |> Enum.map(fn request -> Map.get(shape_areas, request.shape) * request.n end)
      |> Enum.sum()

    total_available_space = region.cols * region.rows
    used_space = used |> Enum.count()
    available_space = total_available_space - used_space
    could_fit_area? = available_space >= required_space

    num_presents =
      region.requests
      |> Enum.map(fn request -> request.n end)
      |> Enum.sum()

    max_num_presents =
      div(region.cols, 3) * div(region.rows, 3)

    could_fit_presents? = num_presents <= max_num_presents

    could_fit_area? and could_fit_presents?
  end

  defp part1({shape_areas, shape_map, regions}) do
    regions
    |> Enum.filter(&fit_possible?(shape_areas, &1, MapSet.new()))
    |> Enum.filter(&can_fit?(shape_areas, shape_map, 0, &1, MapSet.new()))
    |> Enum.count()
  end
end
