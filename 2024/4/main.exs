file = "./2024/4/input.txt"
|> File.read!

input_length = 140

horizontal = Regex.scan(~r'SMAX', file) |> Enum.count
IO.puts horizontal

# inverted_file = "./2024/4/input.txt"
# |> File.stream!
# |> Stream.map(&String.trim/1)
# |> Enum.map(&String.graphemes/1)
# |> List.zip
# |> Enum.map(&Tuple.to_list/1)
# |> Enum.map(&Enum.join/1)
# |> Enum.join("\n")
# vertical = Regex.scan(~r'XMAS|SMAX', inverted_file) |> Enum.count
# IO.puts vertical

defmodule Iter do
  defstruct score: 0, expected_m_indices: [], expected_a_indices: [], expected_s_indices: []
end

defmodule XmasScan do
  def find_indices(str, char) do
    str
    |> String.graphemes
    |> Enum.with_index
    |> Enum.filter(fn {c, _} -> c == char end)
    |> Enum.map(fn {_, i} -> i end)
  end

  def find_union(a, b) do
    MapSet.intersection(MapSet.new(a), MapSet.new(b)) |> MapSet.to_list
  end

  def scan(row, nil) do
    %Iter{expected_m_indices: find_indices(row, "X") }
  end
  def scan(row, iter) do
    x_indices = find_indices(row, "X")
    m_indices = find_indices(row, "M")
    a_indices = find_indices(row, "A")
    s_indices = find_indices(row, "S")
    %Iter{
      expected_m_indices: x_indices,
      expected_a_indices: find_union(iter.expected_m_indices, m_indices),
      expected_s_indices: find_union(iter.expected_a_indices, a_indices),
      score: iter.score + (find_union(iter.expected_s_indices, s_indices) |> Enum.count)
    }
  end
end

%{score: score} = "./2024/4/input.txt"
|> File.stream!
|> Enum.reduce(nil, &XmasScan.scan/2)

IO.puts score
