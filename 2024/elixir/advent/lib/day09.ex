defmodule Advent.Day09 do
  def run do
    part1()
    part2()
  end

  defp parse do
    nums =
      File.read!("../../input/day09")
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    starting_positions =
      nums
      |> Enum.map_reduce(0, fn num, prev_blocks -> {prev_blocks, num + prev_blocks} end)
      |> elem(0)

    Enum.zip(nums, starting_positions)
    |> Enum.with_index()
    |> Enum.split_with(fn {_, i} -> rem(i, 2) == 0 end)
    |> then(fn {files, frees} ->
      {files
       |> Enum.map(&elem(&1, 0))
       |> Enum.with_index()
       |> Enum.map(fn {{blocks, start_pos}, id} -> {blocks, start_pos, id} end),
       frees |> Enum.map(&elem(&1, 0))}
    end)
  end

  def part1 do
    {files, frees} =
      parse()
      |> then(fn {files, frees} ->
        {files |> Enum.map(fn {blocks, _, id} -> {blocks, id} end) |> Arrays.new(),
         frees |> Enum.map(fn {blocks, _} -> blocks end)}
      end)

    # `files` is [{# of blocks, block ID}]
    # `frees` is just number of free spots
    {blocks, _} = Arrays.get(files, 0)
    # Can always just files[0] and set the position to files[0].blocks
    step(blocks, 1, Arrays.size(files) - 1, files, frees, :free) |> IO.inspect()
  end

  def part2 do
    {files, frees} = parse()

    files
    |> Enum.reverse()
    |> Enum.map_reduce(frees, fn file, frees ->
      find_space(file, frees)
    end)
    |> elem(0)
    |> Enum.reduce(0, fn {blocks, start_pos, id}, acc -> acc + val(start_pos, {blocks, id}) end)
    |> IO.inspect()
  end

  defp find_space({_, start_pos, _} = file, [{_, free_pos} = fh | _] = frees)
       when start_pos <= free_pos,
       do: {file, frees}

  defp find_space({blocks, start_pos, id}, [{blocks, free_pos} | ft]) when start_pos > free_pos,
    do: {{blocks, free_pos, id}, ft}

  defp find_space({blocks, start_pos, id}, [{free_blocks, free_pos} | ft])
       when start_pos > free_pos and blocks < free_blocks do
    {{blocks, free_pos, id}, [{free_blocks - blocks, free_pos + blocks} | ft]}
  end

  defp find_space(file, [fh | ft]) do
    find_space(file, ft) |> then(fn {file, nft} -> {file, [fh | nft]} end)
  end

  defp find_space(file, []), do: {file, []}

  defp val(pos, {blocks, id}) do
    Enum.reduce(blocks..1, {pos, 0}, fn _, {pos, acc} ->
      {pos + 1, acc + pos * id}
    end)
    |> elem(1)
  end

  defp step(pos, front_ptr, front_ptr, files, _, _) do
    val(pos, Arrays.get(files, front_ptr))
  end

  defp step(pos, front_ptr, back_ptr, files, [0 | frees], :free),
    do: step(pos, front_ptr, back_ptr, files, frees, :file)

  defp step(pos, front_ptr, back_ptr, files, [free | ft], :free) do
    {blocks, id} = Arrays.get(files, back_ptr)

    nblocks = blocks - 1

    nback_ptr =
      if nblocks <= 0 do
        back_ptr - 1
      else
        back_ptr
      end

    pos * id +
      step(
        pos + 1,
        front_ptr,
        nback_ptr,
        Arrays.replace(files, back_ptr, {blocks - 1, id}),
        [free - 1 | ft],
        :free
      )
  end

  defp step(pos, front_ptr, back_ptr, files, frees, :file) do
    {blocks, _} = file = Arrays.get(files, front_ptr)
    val(pos, file) + step(pos + blocks, front_ptr + 1, back_ptr, files, frees, :free)
  end
end
