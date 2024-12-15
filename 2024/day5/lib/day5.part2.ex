defmodule Day5.Part2.Iter do
  defstruct conditions: [], score: 0
end

defmodule Day5.Part2 do
  def score(str, conditions) do
    items = str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

    g = :digraph.new()
    items |> Enum.map(&:digraph.add_vertex(g, &1))
    conditions |> Enum.each(fn {smaller, larger} -> :digraph.add_edge(g, smaller, larger) end)

    sorting = case :digraph_utils.topsort(g) do
      false -> "failed"
      sorted -> sorted |> Enum.map(&Integer.to_string/1)
    end
    IO.puts "result of #{str} is #{sorting}"
    sorting = sorting

    0
  end
  def process(str, nil) do
    process(str, %Day5.Part2.Iter{})
  end
  def process("", iter) do
    iter
  end
  def process(str, iter) do
    case String.contains?(str, "|") do
      true ->
        %Day5.Part2.Iter{
          conditions: parse_condition(str, iter.conditions)
        }
      false ->
        %Day5.Part2.Iter{iter | score: iter.score + Day5.Part2.score(str, iter.conditions)
      }
    end
  end

  @spec parse_condition(String.t(), [{integer(), integer()}]) :: [{integer(), integer()}]
  def parse_condition(str, conditions) do
    condition = Regex.run(~r"^(\d+)\|(\d+)$", str, capture: :all_but_first)
    |> List.to_tuple
    [condition] ++ conditions
  end
end
