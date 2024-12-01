defmodule Day01 do
    def part1(l, r) do
        List.zip([l, r]) \
            |> Enum.map(fn {a, b} -> abs(a - b) end)\
            |> Enum.sum
    end

    def part2(l, r) do
        freqs = Enum.frequencies(r)
        l \
            |> Enum.map(&(&1 * Map.get(freqs, &1, 0))) \
            |> Enum.sum
    end
end

lines = File.stream!("../input/day01") \
    |> Enum.map(&String.trim/1) \
    |> Enum.map(&String.split/1)

l = lines |> Enum.map(&hd/1) \
    |> Enum.map(&String.to_integer/1) \
    |> Enum.sort

r = lines |> Enum.map(&tl/1) \
    |> Enum.map(&hd/1) \
    |> Enum.map(&String.to_integer/1) \
    |> Enum.sort

IO.puts Day01.part1(l, r)
IO.puts Day01.part2(l, r)

