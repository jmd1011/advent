defmodule Day05 do
  def parse(filename) do
    graph = :digraph.new()

    [rules, updates] = File.read!(filename) |> String.split("\n\n") |> Enum.map(&String.split/1)

    rules
    |> Enum.each(fn rule ->
      [source, sink] =
        String.split(rule, "|")
        |> Enum.map(fn v ->
          if !:digraph.vertex(graph, v) do
            :digraph.add_vertex(graph, v)
          end

          :digraph.vertex(graph, v)
        end)

      :digraph.add_edge(graph, source, sink)
    end)

    updates =
      updates
      |> Enum.map(fn update ->
        update |> String.split(",") |> Enum.reverse()
      end)

    {graph, updates}
  end

  def part1({graph, updates}) do
    :digraph.vertices(graph) |> Enum.map(&IO.inspect/1)
  end
end

Day05.parse("../input/day05") |> tap(&IO.inspect(Day05.part1(&1)))
