defmodule Day9.Part1 do
  def process() do
    process_string(
      "2333133121414131402",
      {"00...111...2...333.44.5555.6666.777.888899", "0099811188827773336446555566", 1928}
    )

    process_string("12345", {"0..111....22222", "022111222", 60})
    process_file("input.txt")
  end

  def reduce([], compacted) do
    compacted
  end

  def reduce([-1], compacted) do
    compacted
  end

  def reduce([_] = space, compacted) do
    compacted ++ space
  end

  def reduce([-1 | tail], compacted) do
    result =
      Stream.iterate(0, &(&1 + 1))
      |> Enum.reduce_while({tail, nil}, fn _, {tail, _} ->
        case Enum.split(tail, length(tail) - 1) do
          {newtail, [-1]} -> {:cont, {newtail, nil}}
          {newtail, [_] = n} -> {:halt, {newtail, n}}
          {newtail, []} -> {:halt, {newtail, nil}}
        end
      end)

    case result do
      {_, nil} -> compacted
      {tail, n} -> reduce(tail, compacted ++ n)
    end
  end

  def reduce([n | tail], compacted) do
    reduce(tail, compacted ++ [n])
  end

  def process_string(data, {want_sparse, want_condenced, want_checksum}) do
    IO.puts "processing: #{data}"
    {_, _, expanded} =
      data
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.reduce({:file, 0, []}, fn
        n, {:file, id, result} ->
          new_blocks = Enum.flat_map(1..n, fn _ -> [id] end)
          {:space, id + 1, result ++ new_blocks}

        0, {:space, id, result} ->
          {:file, id, result}

        n, {:space, id, result} ->
          new_blocks = Enum.flat_map(1..n, fn _ -> [-1] end)
          {:file, id, result ++ new_blocks}
      end)

    string_repr =
      expanded
      |> Enum.reduce("", fn
        -1, acc -> acc <> "."
        n, acc -> acc <> Integer.to_string(n)
      end)

    IO.inspect({string_repr, string_repr == want_sparse}, label: "sparse")

    reordered = reduce(expanded, [])
    reorderd_string = reordered |> Enum.map(&Integer.to_string/1) |> Enum.join("")
    IO.inspect({reorderd_string, reorderd_string == want_condenced}, label: "condenced")

    {checksum, _} =
      reordered
      |> Enum.reduce({0, 0}, fn n, {total, pos} -> {total + pos * n, pos + 1} end)

    IO.inspect({checksum, checksum == want_checksum}, label: "checksum")
  end

  def process_file(file) do
    IO.puts "processing: #{file}"
    {_, _, expanded} =
      file
      |> File.stream!(1)
      |> Enum.map(&String.to_integer/1)
      |> Enum.reduce({:file, 0, []}, fn
        n, {:file, id, result} ->
          new_blocks = Enum.flat_map(1..n, fn _ -> [id] end)
          {:space, id + 1, result ++ new_blocks}

        0, {:space, id, result} ->
          {:file, id, result}

        n, {:space, id, result} ->
          new_blocks = Enum.flat_map(1..n, fn _ -> [-1] end)
          {:file, id, result ++ new_blocks}
      end)

    reordered = reduce(expanded, [])

    {checksum, _} =
      reordered
      |> Enum.reduce({0, 0}, fn n, {total, pos} -> {total + pos * n, pos + 1} end)

    IO.inspect(checksum, label: "checksum")
  end
end
