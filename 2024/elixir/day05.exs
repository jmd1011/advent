defmodule Day05 do
  def parse(filename) do
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

  def part1({graph, updates}) do
    updates
    |> Enum.filter(&correct?(graph, &1, MapSet.new()))
    |> Enum.map(&middle(&1, 0, div(length(&1), 2)))
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
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

Day05.parse("../input/day05") |> tap(&IO.inspect(Day05.part1(&1)))
