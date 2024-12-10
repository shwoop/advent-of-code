defmodule Unions do
  @spec find_union([], []) :: []
  def find_union(a, b) do
    MapSet.intersection(MapSet.new(a), MapSet.new(b)) |> MapSet.to_list()
  end
end

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
  defstruct a_row: [], scoring_m: [], scoring_s: [], score: 0

  @type t :: %__MODULE__{
          a_row: XmasScanT.indipats(),
          scoring_m: [integer],
          scoring_s: [integer],
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

    %LineIter{lookback: [n | nn], results: patterns}
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

  @spec score(%Iter{}, [integer], [integer]) :: integer
  def score(iter, m_indices, s_indices) do
    ms = Unions.find_union(iter.scoring_m, m_indices) |> Enum.count()
    ss = Unions.find_union(iter.scoring_s, s_indices) |> Enum.count()
    ms + ss
  end

  @spec potential_scores(XmasScanT.indipats(), [integer]) :: {[integer], [integer]}
  def potential_scores(a_row, a_indices) do
    a_row
    |> Enum.filter(fn {i, _} -> i in a_indices end)
    |> Enum.reduce({[], []}, fn
      {i, :mam}, {m, s} -> {m, [i - 1, i + 1 | s]}
      {i, :sam}, {m, s} -> {[i - 1 | m], [i + 1 | s]}
      {i, :mas}, {m, s} -> {[i + 1 | m], [i - 1 | s]}
      {i, :sas}, {m, s} -> {[i - 1, i + 1 | m], s}
      _, _ -> nil
    end)
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

    {potential_m, potential_s} = potential_scores(iter.a_row, a_indices)

    i = %Iter{
      a_row: find_indices(row),
      score: iter.score + score(iter, m_indices, s_indices),
      scoring_m: potential_m,
      scoring_s: potential_s
    }

    i
  end
end
