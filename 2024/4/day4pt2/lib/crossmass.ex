defmodule Unions do
  @spec find_union([], []) :: []
  def find_union(a, b) do
    MapSet.intersection(MapSet.new(a), MapSet.new(b)) |> MapSet.to_list()
  end
end

defmodule XmasScanT do
  @type pattern :: :sas | :mas | :sam | :mam
  @type charmap :: %{required(integer) => String.t()}
  # @type patternmap :: %{required(integer) => pattern}
  @type indipat :: {integer, pattern}
  @type indipats :: [indipat]

  @type chariter :: {String.t(), integer}
end

defmodule LineIter do
  defstruct lookback: [], results: %{}

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
      {"s", "s"} -> {i, :sas}
      {"m", "s"} -> {i, :mas}
      {"s", "m"} -> {i, :sam}
      {"m", "m"} -> {i, :mam}
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
      case match_pattern(n, n, nnn) do
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

    li.a_rows
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
    # mscore = iter.scoring_m
    # |> Enum.reduce(0, fn i, acc ->
    #   case Enum.member?(m_indices, i) do
    #     true -> acc +1
    #     false -> acc
    #   end
    # end)
    # sscore = iter.scoring_s
    # |> Enum.reduce(0, fn
    #   i, acc when Enum.member?(s_indices, i) -> acc + 1
    #   _, _ -> acc
    # end)
    # mscore + sscore
    ms = Unions.find_union(iter.scoring_m, m_indices) |> Enum.count()
    ss = Unions.find_union(iter.scoring_s, s_indices) |> Enum.count()
    ms + ss
  end

  @spec scan(String.t(), %Iter{} | nil) :: %Iter{}
  def scan(row, nil) do
    i = %Iter{
      #
      a_row: find_indices(row)
    }

    IO.inspect(i)
    i

    # score == iter.scoring_m U m_indices + iter.scoring_s U s_indices
    # iter.a_row = find_patterns(row)
    # iter.scoring_m = iter.a_row U a_indices : mas -> i-1 , mam -> {i-1, i+1}, sam -> i+1
    # iter.scoring_s = iter.s_row U s_indices : sam -> i-1 , sas -> {i-1, i+1}, mas -> i+1
  end

  def scan(row, iter) do
    m_indices = find_indices(row, "M")
    _a_indices = find_indices(row, "A")
    s_indices = find_indices(row, "S")

    i = %Iter{
      a_row: find_indices(row),
      score: iter.score + score(iter, m_indices, s_indices)
    }

    IO.inspect(i)
    i
    # score == iter.scoring_m U m_indices + iter.scoring_s U s_indices
    # iter.a_row = find_patterns(row)
    # iter.scoring_m = iter.a_row U a_indices : mas -> i-1 , mam -> {i-1, i+1}, sam -> i+1
    # iter.scoring_s = iter.s_row U s_indices : sam -> i-1 , sas -> {i-1, i+1}, mas -> i+1
  end
end
