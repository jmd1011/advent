defmodule Advent.Day05 do
  def run do
    parse("../../input/day05")
    |> tap(&IO.inspect(part1(&1)))
    |> tap(&IO.inspect(part2(&1)))
  end

  defp parse(filename) do
    graph = :digraph.new()

    [rules, updates] = File.read!(filename) |> String.split("\n\n") |> Enum.map(&String.split/1)

    rules
    |> Enum.each(fn rule ->
      [source, sink] = String.split(rule, "|")

      source = :digraph.add_vertex(graph, source)
      sink = :digraph.add_vertex(graph, sink)
      :digraph.add_edge(graph, source, sink)
    end)

    updates =
      updates
      |> Enum.map(fn update ->
        update |> String.split(",")
      end)

    {graph, updates}
  end

  defp score(updates) do
    updates
    |> Enum.map(&middle(&1, 0, div(length(&1), 2)))
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  defp part1({graph, updates}) do
    updates
    |> Enum.filter(&correct?(graph, &1, MapSet.new()))
    |> score()
  end

  defp part2({graph, updates}) do
    updates
    |> Enum.filter(&(!correct?(graph, &1, MapSet.new())))
    |> Enum.map(fn update ->
      Enum.sort(update, fn a, b ->
        :digraph.out_neighbours(graph, a) |> MapSet.new() |> MapSet.member?(b)
      end)
    end)
    |> score()
  end

  defp middle(l, curr, curr), do: hd(l)
  defp middle([_ | t], curr, tgt), do: middle(t, curr + 1, tgt)

  defp correct?(graph, [page | pages], seen) do
    neighbors = :digraph.out_neighbours(graph, page)

    !Enum.any?(neighbors, fn edge -> MapSet.member?(seen, edge) end) and
      correct?(graph, pages, MapSet.put(seen, page))
  end

  defp correct?(_, [], _), do: true
end
