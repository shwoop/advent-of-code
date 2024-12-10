defmodule XmasScanT do
  @type pattern :: :sas | :mas | :sam | :mam
  @type charmap :: %{required(integer) => String.t()}
  @type indipat :: {integer, pattern}
  @type indipats :: [indipat]
  @type chariter :: {String.t(), integer}
end

defmodule LineIter do
  defstruct lookback: [], results: []

  @type t :: %__MODULE__{
          lookback: [XmasScanT.chariter()],
          results: XmasScanT.indipats()
        }
end

defmodule Iter do
  defstruct a_row: [], potential_scores: [], score: 0

  @type t :: %__MODULE__{
          a_row: XmasScanT.indipats(),
          potential_scores: XmasScanT.indipats(),
          score: integer
        }
end

defmodule XmasScan do
  @spec match_pattern(XmasScanT.chariter(), XmasScanT.chariter(), XmasScanT.chariter()) :: XmasScanT.indipat() | nil
  def match_pattern(n, nn, nnn) do
    {c, _} = n
    {_, i} = nn
    {cc, _} = nnn

    case {cc, c} do
      {"S", "S"} -> {i, :sas}
      {"M", "S"} -> {i, :mas}
      {"S", "M"} -> {i, :sam}
      {"M", "M"} -> {i, :mam}
      _ -> nil
    end
  end

  @spec find_patterns(XmasScanT.chariter(), %LineIter{} | nil) :: %LineIter{}
  def find_patterns(n, nil) do
    %LineIter{lookback: [n]}
  end

  def find_patterns(n, %LineIter{lookback: [nn]}) do
    %LineIter{lookback: [n | nn]}
  end

  def find_patterns(n, %LineIter{lookback: [nn | nnn]} = line_iter) do
    patterns =
      case match_pattern(n, nn, nnn) do
        nil -> line_iter.results
        x -> [x | line_iter.results]
      end

    %LineIter{
      lookback: [n | nn],
      results: patterns
    }
  end

  @spec find_indices(String.t()) :: [XmasScanT.indipat()]
  def find_indices(str) do
    li =
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(nil, &find_patterns/2)

    li.results
  end

  @spec find_indices(String.t(), String.t()) :: [integer]
  def find_indices(str, char) do
    str
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {c, _} -> c == char end)
    |> Enum.map(fn {_, i} -> i end)
  end

  @spec score(XmasScanT.indipats(), [integer], [integer]) :: integer
  def score(potential_scores, m_indices, s_indices) do
    potential_scores
    |> Enum.reduce(0, fn
      {i, :mam}, acc -> if Enum.member?(s_indices, i-1) and Enum.member?(s_indices, i+1), do: acc+1, else: acc
      {i, :sam}, acc -> if Enum.member?(s_indices, i-1) and Enum.member?(m_indices, i+1), do: acc+1, else: acc
      {i, :mas}, acc -> if Enum.member?(m_indices, i-1) and Enum.member?(s_indices, i+1), do: acc+1, else: acc
      {i, :sas}, acc -> if Enum.member?(m_indices, i-1) and Enum.member?(m_indices, i+1), do: acc+1, else: acc
      _, acc -> acc
    end)
  end

  @spec potential_scores(XmasScanT.indipats(), [integer]) :: XmasScanT.indipats()
  def potential_scores(a_row, a_indices) do
    a_row
    |> Enum.filter(fn {i, _} -> i in a_indices end)
  end

  @spec scan(String.t(), %Iter{} | nil) :: %Iter{}
  def scan(row, nil) do
    i = %Iter{
      a_row: find_indices(row)
    }
    i
  end

  def scan(row, iter) do
    m_indices = find_indices(row, "M")
    a_indices = find_indices(row, "A")
    s_indices = find_indices(row, "S")

    i = %Iter{
      a_row: find_indices(row),
      score: iter.score + score(iter.potential_scores, m_indices, s_indices),
      potential_scores: potential_scores(iter.a_row, a_indices)
    }
    i
  end
end
