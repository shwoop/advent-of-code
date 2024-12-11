defmodule Day5.T do
  @type condition :: {integer, integer}
  @type condition_mapping:: %{integer => [condition]}
end

defmodule Day5.ConditionMapping do
  def map_to_condition(str, nil) do
    {smaller, larger} = condition = Regex.run(~r"^(\d+)\|(\d+)$", str, capture: :all_but_first)
    |> List.to_tuple

    %{smaller => [condition], larger => [condition]}
  end
  def map_to_condition(str, condition_map) do
    {smaller, larger} = condition = Regex.run(~r"^(\d+)\|(\d+)$", str, capture: :all_but_first)
    |> List.to_tuple

    condition_map
    |> Map.put(smaller, [condition | Map.get(condition_map, smaller, [])])
    |> Map.put(larger, [condition | Map.get(condition_map, larger, [])])
  end
end

defmodule Day5.Part1.Iter do
  defstruct condition_map: %{}, score: 0
end

defmodule Day5.Part1 do
  def score(str, condition_map) do
    order = str
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.into(%{})

    applicable_conditions = condition_map
    |> Enum.flat_map(fn { k, v } ->
      case order[k] do
        nil -> []
        _ -> v
      end
    end)
    |> MapSet.new
    |> MapSet.to_list

    failed_validation = applicable_conditions
    |> Enum.any?(fn {smaller, larger} ->
      case {order[smaller], order[larger]} do
        {nil, _} -> false
        {_, nil} -> false
        {smallerindex, largerindex} -> smallerindex > largerindex
      end
    end)

    case failed_validation do
      true -> 0
      false ->
        array = String.split(str, ",")
        String.to_integer(Enum.at(array, (length(array)/2 - 1) |> Float.ceil|> trunc()))
    end
  end
  def process(str, nil) do
    process(str, %Day5.Part1.Iter{})
  end
  def process("", iter) do
    iter
  end
  def process(str, iter) do
    case String.contains?(str, "|") do
      true ->
        %Day5.Part1.Iter{
          condition_map: Day5.ConditionMapping.map_to_condition(str, iter.condition_map),
        }
      false ->
        %Day5.Part1.Iter{iter | score: iter.score + Day5.Part1.score(str, iter.condition_map)
      }
    end
  end
end
