defmodule Item do
  defstruct [:type, :id, :size]
end

defmodule Day9.Part1 do
  def process() do
    # key_length =
    #   "./eg_input.txt"
    #   |> File.read!()
    #   |> String.graphemes()
    #   |> Enum.count()

    # max_id = trunc((key_length - 1) / 2)
    # IO.inspect({key_length, max_id})

    process_string("2333133121414131402", {"00...111...2...333.44.5555.6666.777.888899", "0099811188827773336446555566", 1928})
    process_string("12345", {"0..111....22222", "022111222", 60})
    process_file("input.txt")

  end

  def process_string(data, {want_sparse, want_condenced, want_checksum}) do
        {_, _, sparse} =
          data
          |> String.graphemes
          |> Enum.reduce({:file, 0, ""}, fn
            n, {:file, id, result} ->
              {:space, id + 1,
               result <> String.duplicate(Integer.to_string(id), String.to_integer(n))}

            n, {:space, id, result} ->
              {:file, id, result <> String.duplicate(".", String.to_integer(n))}
          end)

        IO.inspect {sparse, sparse == want_sparse}, label: "sparse"

        {_, max_id, expanded, mapping} =
          data
          |> String.graphemes
          |> Enum.reduce({:file, 0, [], %{}}, fn
            n, {:file, id, expanded, mapping} ->
              nn = String.to_integer(n)
              item = %Item{type: :file, id: id, size: nn}
              {:space, id + 1, expanded ++ [item], Map.put(mapping, id, item)}

            n, {:space, id, expanded, mapping} ->
              nn = String.to_integer(n)
              item = %Item{type: :space, id: nil, size: nn}
              {:file, id, expanded ++ [item], mapping}
          end)

        {expanded_rearranged, _, _} = expanded
        |> Enum.reduce_while({[], mapping, max_id - 1}, &reorganise/2)

        # IO.inspect expanded_rearranged, label: "expanded: rearranged"
        sparse = reduce_to_sparse(expanded_rearranged)
        IO.inspect {sparse, sparse == want_condenced}, label: "expanded sparse"
        sum = calculate_checksum(expanded_rearranged)
        IO.inspect {sum, sum == want_checksum}, label: "checksum"

  end
  def process_file(file) do
    {_, _, sparse} =
      file
      |> File.stream!(1)
      |> Enum.reduce({:file, 0, ""}, fn
        n, {:file, id, result} ->
          {:space, id + 1,
           result <> String.duplicate(Integer.to_string(id), String.to_integer(n))}

        n, {:space, id, result} ->
          {:file, id, result <> String.duplicate(".", String.to_integer(n))}
      end)

    IO.inspect sparse, label: "sparse"

    {_, max_id, expanded, mapping} =
      file
      |> File.stream!(1)
      |> Enum.reduce({:file, 0, [], %{}}, fn
        n, {:file, id, expanded, mapping} ->
          nn = String.to_integer(n)
          item = %Item{type: :file, id: id, size: nn}
          {:space, id + 1, expanded ++ [item], Map.put(mapping, id, item)}

        n, {:space, id, expanded, mapping} ->
          nn = String.to_integer(n)
          item = %Item{type: :space, id: nil, size: nn}
          {:file, id, expanded ++ [item], mapping}
      end)

    {expanded_rearranged, _, _} = expanded
    |> Enum.reduce_while({[], mapping, max_id - 1}, &reorganise/2)

    rebuilt_map = expanded_rearranged
    |> Enum.reduce(%{}, fn %{id: id, size: size} = item, acc ->
      n = case Map.get(acc, id) do
        %Item{size: size} -> size
        _ -> 0
      end
      Map.put(acc, id, %Item{item | size: size + n})
    end)
    IO.inspect rebuilt_map == mapping

    File.write!("./mapping.txt", mapping |> Enum.map(fn {k, %Item{size: size}} -> "#{k}: #{size}" end) |> Enum.join("\n"), append: true)

    # IO.inspect expanded_rearranged, label: "expanded: rearranged"
    sparse = reduce_to_sparse(expanded_rearranged)
    File.write!("./expanded_sparse.txt", sparse)

    sum = calculate_checksum(expanded_rearranged)
    IO.inspect sum, label: "checksum"

end

  @spec reorganise(
          %Item{:id => integer, :type => atom, size: integer},
          {[%Item{}], %{}, integer}
        ) :: {:halt|:cont, {[%Item{}], %{}, integer}}
  def reorganise(%Item{type: :file, id: id}, {_, _, max_id} = result) when id > max_id do
        {:halt, result}
  end
  def reorganise(%Item{type: :file, id: id}, {acc, mapping, max_id}) when id == max_id do
    %Item{size: size_from_map} = Map.get(mapping, id)
    {:halt,
     {acc ++ [%Item{type: :file, id: id, size: size_from_map}], mapping, max_id}}
  end
  def reorganise(%Item{type: :file, id: id} = i, {acc, mapping, max_id}) do
        {:cont, {acc ++ [i], Map.delete(mapping, id), max_id}}
  end
  def reorganise(%Item{type: :space, size: free_space}, {acc, mapping, max_id}) do
        {:cont, fill_space(free_space, {acc, mapping, max_id})}
  end

  @spec fill_space(integer, {[], %{}, integer}) :: {[], %{}, integer}
  def fill_space(blocks, {acc, mapping, max_id}) do
    # IO.inspect({blocks, max_id, mapping}, label: "fill_space")
    case Map.get(mapping, max_id) do
      nil ->
        case Enum.count(Map.keys(mapping)) do
          0 -> {acc, mapping, max_id - 1}
          _ -> fill_space(blocks, {acc, mapping, max_id - 1})
        end
    %Item{size: last_file_blocks, id: id} ->
    case last_file_blocks do
      y when y == blocks ->
        {acc ++ [%Item{type: :file, id: id, size: blocks}], Map.delete(mapping, max_id),
         max_id - 1}

      y when y > blocks ->
        {acc ++ [%Item{type: :file, id: id, size: blocks}],
         Map.put(mapping, max_id, %Item{type: :file, id: id, size: last_file_blocks - blocks}),
         max_id}

      y when y < blocks ->
        fill_space(
          blocks - last_file_blocks,
          {acc ++ [%Item{type: :file, id: id, size: last_file_blocks}],
           Map.delete(mapping, max_id), max_id - 1}
        )
    end
    end
  end

  def reduce_to_sparse(expanded) do
    expanded
    |> Enum.reduce("", fn %Item{id: id, size: size}, acc ->
      sid = case id do
        n when n > 9 ->
          "{#{Integer.to_string(id)}}"
        _ ->
          Integer.to_string(id)
      end
      acc <> String.duplicate(sid, size) end)
  end

  def calculate_checksum(expanded) do
    {sum, _, _} = expanded
    |> Enum.reduce({0, 0, []}, fn %Item{id: id, size: size}, {acc, i, history} ->
      {inc, calculations} = i..(i + size - 1)
      |> Enum.reduce({0, []}, fn
        n, {total, hist} ->
          # IO.inspect({id, n, n*id}, label: "{id, n , n*id}")
          {total + (n * id), hist ++ [{n, id}]}
      end)
      # IO.inspect({acc, inc, i, i+size}, label: "{acc, inc, i, i+size}")
      {acc + inc, i + size, history ++ calculations}
     end)
     sum
  end
end
