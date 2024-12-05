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
    |> Enum.filter(&correct?(graph, &1))
    |> Enum.map(&middle(&1, 0, div(length(&1), 2)))
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  defp middle(l, curr, curr), do: hd(l)
  defp middle([_ | t], curr, tgt), do: middle(t, curr + 1, tgt)

  defp correct?(graph, [page | pages]) do
    pages
    |> Enum.all?(fn succ ->
      case :digraph.get_path(graph, succ, page) do
        false -> true
        _ -> false
      end
    end) and correct?(graph, pages)
  end

  defp correct?(_, []), do: true
end

Day05.parse("../input/day05") |> tap(&IO.inspect(Day05.part1(&1)))
