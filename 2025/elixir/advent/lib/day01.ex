defmodule Advent.Day01 do
  def run do
    parse()
    |> tap(&IO.inspect(elem(part1(&1), 1)))
    |> tap(&IO.inspect(elem(part2(&1), 1)))
  end

  defp parse do
    File.stream!("../../input/day01")
    |> Stream.flat_map(&String.split/1)
    |> Enum.map(fn
      "L" <> distance -> {:L, String.to_integer(distance)}
      "R" <> distance -> {:R, String.to_integer(distance)}
    end)
  end

  defp rot(pos, {:L, distance}), do: mod(pos, -distance)
  defp rot(pos, {:R, distance}), do: mod(pos, distance)

  defp mod(pos, distance) do
    npos = pos + distance
    flip? = pos != 0 and (npos <= 0 or npos > 99)
    {Integer.mod(npos, 100), flip?}
  end

  defp part1(instrs) do
    instrs
    |> Enum.reduce({50, 0}, fn instr, {pos, res} ->
      {npos, _} = rot(pos, instr)
      {npos, res + if(npos == 0, do: 1, else: 0)}
    end)
  end

  defp part2(instrs) do
    instrs
    |> Enum.reduce({50, 0}, fn {dir, distance}, {pos, res} ->
      {flips, rem} = {div(distance, 100), Integer.mod(distance, 100)}
      {npos, flip?} = rot(pos, {dir, rem})
      {npos, res + flips + if(flip?, do: 1, else: 0)}
    end)
  end
end
