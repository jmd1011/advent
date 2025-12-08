defmodule Advent.Day08 do
  alias Collections.DisjointSet

  defmodule Junction do
    defstruct [:x, :y, :z]
  end

  def run do
    parse()
    |> tap(&IO.puts(part1(&1)))
    |> tap(&IO.puts(part2(&1)))
  end

  defp build_list(junctions) do
    for {j1, i1} <- Enum.with_index(junctions),
        {j2, i2} <- Enum.with_index(junctions),
        i1 < i2 do
      {j1, j2, distance(j1, j2)}
    end
  end

  defp parse do
    junctions =
      File.stream!("../../input/day08")
      |> Stream.map(&String.trim_trailing/1)
      |> Stream.map(fn line ->
        [x, y, z] = String.split(line, ",", parts: 3) |> Enum.map(&String.to_integer/1)
        %Junction{x: x, y: y, z: z}
      end)
      |> Enum.sort_by(& &1.x)

    junctions_set =
      junctions
      |> Enum.reduce(DisjointSet.new(), fn j, set ->
        {_, ds} = DisjointSet.find(set, j)
        ds
      end)

    graph =
      build_list(junctions)
      |> Enum.sort_by(fn {_, _, dist} -> dist end)

    {junctions, junctions_set, graph}
  end

  defp distance(j1, j2) do
    with dx <- j1.x - j2.x,
         dy <- j1.y - j2.y,
         dz <- j1.z - j2.z do
      :math.sqrt(dx * dx + dy * dy + dz * dz)
    end
  end

  defp part1({junctions, junctions_set, graph}) do
    res =
      graph
      |> Enum.take(1000)
      |> Enum.reduce(junctions_set, fn {j1, j2, _}, set ->
        DisjointSet.union(set, j1, j2)
      end)

    to_list(junctions, res)
    |> Enum.map(fn {_, l} -> length(l) end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp to_list(junctions, junctions_set) do
    junctions
    |> Enum.group_by(fn j ->
      {root, _} = DisjointSet.find(junctions_set, j)
      root
    end)
    |> Map.to_list()
  end

  defp part2({_, _, []}), do: 0

  defp part2({junctions, junctions_set, [{j1, j2, _} | t]}) do
    ds = DisjointSet.union(junctions_set, j1, j2)

    if length(to_list(junctions, ds)) == 1 do
      j1.x * j2.x
    else
      part2({junctions, ds, t})
    end
  end
end
