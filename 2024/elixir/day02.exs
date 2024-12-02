defmodule Day02 do
  def parse(filename) do
    File.stream!(filename)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn line -> line |> Enum.map(&String.to_integer/1) end)
  end

  def part1(lines) do
    lines |> Enum.count(&is_safe(&1))
  end

  def part2(lines) do
    lines |> Enum.count(&damp(&1))
  end

  defp is_valid(a, b, sign) do
    diff = a - b

    (sign * abs(diff)) in 1..3
  end

  defp damp([a, b | tail] = line, can_ignore) do
    diff = a - b
    sign = div(diff, abs(diff))

    cond do
      is_valid(a, b, sign) ->
        foo(line, sign, can_ignore)

      damp([b | tail], false) ->
        true

      damp([a | tail], false) ->
        true

      true ->
        false
    end
  end

  defp damp([]), do: true
  defp damp([h | []] = line), do: true

  defp damp([_h | _tail] = line) do
    damp(line, true)
  end

  defp foo([a, b, c | []], sign, can_ignore) do
    comp = if can_ignore, do: &or/2, else: &and/2
    comp.(is_valid(a, b, sign), comp.(is_valid(b, c, sign), is_valid(a, c, sign)))
  end

  defp foo([a, b, c | tail], sign, can_ignore) do
    cond do
      is_valid(b, c, sign) ->
        foo([b, c, hd(tail) | tl(tail)], sign, can_ignore)

      can_ignore ->
        foo([a, c, hd(tail), tl(tail)], sign, false) or
          foo([a, b, hd(tail), tl(tail)], sign, false)

      true ->
        false
    end
  end

  defp is_safe([head, head | _]), do: false

  defp is_safe([x, y | _] = line) do
    diff = x - y
    is_safe(line, div(diff, abs(diff)))
  end

  defp is_safe(line, sign) do
    Enum.chunk_every(line, 2, 1)
    |> Enum.all?(fn chunks ->
      case chunks do
        [a, b] ->
          (sign * (a - b)) in 1..3

        [_] ->
          true
      end
    end)
  end
end

lines = Day02.parse("../input/day02")
IO.puts(Day02.part1(lines))
IO.puts(Day02.part2(lines))
