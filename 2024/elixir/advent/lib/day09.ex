defmodule Advent.Day09 do
  def run do
    part1()
  end

  defp parse do
    File.read!("../../input/day09")
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.split_with(fn {_, i} -> rem(i, 2) == 0 end)
    |> then(fn {files, frees} ->
      {files |> Enum.map(&elem(&1, 0)) |> Enum.with_index() |> Arrays.new(),
       frees |> Enum.map(&elem(&1, 0))}
    end)
  end

  def part1 do
    {files, frees} = parse()
    # `files` is {# of blocks, block ID}
    # `frees` is just number of free spots
    {blocks, _} = Arrays.get(files, 0)
    # Can always just skip hd(files) and set the position to elem(hd(files), 0)
    step(blocks, 1, Arrays.size(files) - 1, files, frees, :free) |> IO.inspect()
  end

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
