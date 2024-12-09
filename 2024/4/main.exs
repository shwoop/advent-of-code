file =
  "./2024/4/input.txt"
  |> File.read!()

input_length = 140

horizontal_xmas = (file |> String.split("XMAS") |> length) - 1
horizontal_samx = (file |> String.split("SAMX") |> length) - 1

defmodule Unions do
  def find_union(a, b) do
    MapSet.intersection(MapSet.new(a), MapSet.new(b)) |> MapSet.to_list()
  end
end

@type IterState :: %{
        score: intiger,
        expected_x_indices: array,
        expected_m_indices: array,
        expected_a_indices: array,
        expected_s_indices: array
      }
defmodule Iter.State do
  defstruct score: 0,
            expected_x_indices: [],
            expected_m_indices: [],
            expected_a_indices: [],
            expected_s_indices: []
end

defmodule StateTransitions do
  @spec vertical_xmas(IterState, array, aray, array, array) :: IterState
  def vertical_xmas(iter, x_indices, m_indices, a_indices, s_indices) do
    %Iter.State{
      expected_m_indices: x_indices,
      expected_a_indices: Unions.find_union(iter.expected_m_indices, m_indices),
      expected_s_indices: Unions.find_union(iter.expected_a_indices, a_indices),
      score: iter.score + (Unions.find_union(iter.expected_s_indices, s_indices) |> Enum.count())
    }
  end

  @spec vertical_samx(IterState, array, aray, array, array) :: IterState
  def vertical_samx(iter, x_indices, m_indices, a_indices, s_indices) do
    %Iter.State{
      expected_a_indices: s_indices,
      expected_m_indices: Unions.find_union(iter.expected_a_indices, a_indices),
      expected_x_indices: Unions.find_union(iter.expected_m_indices, m_indices),
      score: iter.score + (Unions.find_union(iter.expected_x_indices, x_indices) |> Enum.count())
    }
  end

  def shift_right(list) do
    list
    |> Enum.reduce([], fn
      140, acc -> acc
      n, acc -> [n + 1 | acc]
    end)
  end

  @spec diagonal_right_xmas(IterState, array, aray, array, array) :: IterState
  def diagonal_right_xmas(iter, x_indices, m_indices, a_indices, s_indices) do
    %Iter.State{
      expected_m_indices: shift_right(x_indices),
      expected_a_indices: shift_right(Unions.find_union(iter.expected_m_indices, m_indices)),
      expected_s_indices: shift_right(Unions.find_union(iter.expected_a_indices, a_indices)),
      score: iter.score + (Unions.find_union(iter.expected_s_indices, s_indices) |> Enum.count())
    }
  end

  @spec diagonal_right_samx(IterState, array, aray, array, array) :: IterState
  def diagonal_right_samx(iter, x_indices, m_indices, a_indices, s_indices) do
    %Iter.State{
      expected_a_indices: shift_right(s_indices),
      expected_m_indices: shift_right(Unions.find_union(iter.expected_a_indices, a_indices)),
      expected_x_indices: shift_right(Unions.find_union(iter.expected_m_indices, m_indices)),
      score: iter.score + (Unions.find_union(iter.expected_x_indices, x_indices) |> Enum.count())
    }
  end

  def shift_left(list) do
    list
    |> Enum.reduce([], fn
      0, acc -> acc
      n, acc -> [n - 1 | acc]
    end)
  end

  @spec diagonal_left_xmas(IterState, array, aray, array, array) :: IterState
  def diagonal_left_xmas(iter, x_indices, m_indices, a_indices, s_indices) do
    %Iter.State{
      expected_m_indices: shift_left(x_indices),
      expected_a_indices: shift_left(Unions.find_union(iter.expected_m_indices, m_indices)),
      expected_s_indices: shift_left(Unions.find_union(iter.expected_a_indices, a_indices)),
      score: iter.score + (Unions.find_union(iter.expected_s_indices, s_indices) |> Enum.count())
    }
  end

  @spec diagonal_left_samx(IterState, array, aray, array, array) :: IterState
  def diagonal_left_samx(iter, x_indices, m_indices, a_indices, s_indices) do
    %Iter.State{
      expected_a_indices: shift_left(s_indices),
      expected_m_indices: shift_left(Unions.find_union(iter.expected_a_indices, a_indices)),
      expected_x_indices: shift_left(Unions.find_union(iter.expected_m_indices, m_indices)),
      score: iter.score + (Unions.find_union(iter.expected_x_indices, x_indices) |> Enum.count())
    }
  end
end

defmodule Iter do
  defstruct vertical_xmas: %Iter.State{},
            vertical_samx: %Iter.State{},
            diagonal_right_xmas: %Iter.State{},
            diagonal_right_samx: %Iter.State{},
            diagonal_left_xmas: %Iter.State{},
            diagonal_left_samx: %Iter.State{}

  def score(iter) do
    iter.vertical_xmas.score + iter.vertical_samx.score + iter.diagonal_right_xmas.score +
      iter.diagonal_right_samx.score + iter.diagonal_left_xmas.score +
      iter.diagonal_left_samx.score
  end
end

defmodule XmasScan do
  @spec find_indices(string, grapheme) :: array(integer)
  def find_indices(str, char) do
    str
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {c, _} -> c == char end)
    |> Enum.map(fn {_, i} -> i end)
  end

  def scan(row, nil) do
    x_indices = find_indices(row, "X")
    s_indices = find_indices(row, "S")

    %Iter{
      vertical_xmas: StateTransitions.vertical_xmas(%Iter.State{}, x_indices, [], [], []),
      vertical_samx: StateTransitions.vertical_samx(%Iter.State{}, [], [], [], s_indices),
      diagonal_right_xmas: StateTransitions.diagonal_right_xmas(%Iter.State{}, x_indices, [], [], []),
      diagonal_right_samx: StateTransitions.diagonal_right_samx(%Iter.State{}, [], [], [], s_indices),
      diagonal_left_xmas: StateTransitions.diagonal_left_xmas(%Iter.State{}, x_indices, [], [], []),
      diagonal_left_samx: StateTransitions.diagonal_left_samx(%Iter.State{}, [], [], [], s_indices)
    }
  end

  def scan(row, iter) do
    x_indices = find_indices(row, "X")
    m_indices = find_indices(row, "M")
    a_indices = find_indices(row, "A")
    s_indices = find_indices(row, "S")

    %Iter{
      vertical_xmas:
        StateTransitions.vertical_xmas(
          iter.vertical_xmas,
          x_indices,
          m_indices,
          a_indices,
          s_indices
        ),
      vertical_samx:
        StateTransitions.vertical_samx(
          iter.vertical_samx,
          x_indices,
          m_indices,
          a_indices,
          s_indices
        ),
      diagonal_right_xmas:
        StateTransitions.diagonal_right_xmas(
          iter.diagonal_right_xmas,
          x_indices,
          m_indices,
          a_indices,
          s_indices
        ),
      diagonal_right_samx:
        StateTransitions.diagonal_right_samx(
          iter.diagonal_right_samx,
          x_indices,
          m_indices,
          a_indices,
          s_indices
        ),
      diagonal_left_xmas:
        StateTransitions.diagonal_left_xmas(
          iter.diagonal_left_xmas,
          x_indices,
          m_indices,
          a_indices,
          s_indices
        ),
      diagonal_left_samx:
        StateTransitions.diagonal_left_samx(
          iter.diagonal_left_samx,
          x_indices,
          m_indices,
          a_indices,
          s_indices
        )
    }
  end
end

result =
  "./2024/4/input.txt"
  |> File.stream!()
  |> Enum.reduce(nil, &XmasScan.scan/2)

IO.puts("score is #{(Iter.score(result) + horizontal_samx + horizontal_xmas) |> Integer.to_string()}")
