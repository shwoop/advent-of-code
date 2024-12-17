defmodule Day8.Part1 do
 def process() do
  {grid_size, antenna} = "./input.txt"
  |> File.stream!
  |> Enum.reduce({0, %{}}, fn
    line, {y, map} ->
      {_, map} = String.graphemes(line)
      |> Enum.reduce({0, map}, fn
        "\n", {x, map} -> {x+1, map}
        ".", {x, map} -> {x+1, map}
        char, {x, map} ->
          {x + 1, Map.put(map, char, Map.get(map, char, []) ++ [{x, y}])}
      end)
      {y+1, map}
  end)
  grid_boundary = grid_size - 1
  # IO.inspect grid_boundary, label: "grid boundary"

  antenna
  |> Map.values()
  |> Enum.reduce(MapSet.new(), fn
    frequency_antennas, acc ->
      antenna_pairs = frequency_antennas
      |> Enum.flat_map(fn
        a ->
          frequency_antennas
          |> Enum.drop(Enum.find_index(frequency_antennas, &(&1 == a)) + 1)
          |> Enum.map(fn b -> {a, b} end)
      end)
      # |> IO.inspect

      antenna_pairs
      |> Enum.map(fn {{x, y} = a, {xx, yy} = b} ->
        dx = xx - x
        dy = yy - y
        {{x - dx, y - dy}, a, b, {xx + dx, yy + dy}}
      end)
      # |> IO.inspect(label: "pairs")
      |> Enum.reduce(acc, fn
        {a1, _, _, a2}, acc ->
          acc = case a1 do
            {x, y} when x < 0 or x > grid_boundary or y < 0 or y > grid_boundary ->
              acc
            {x, y} ->
              MapSet.put(acc, {x, y})
          end
          acc = case a2 do
            {x, y} when x < 0 or x > grid_boundary or y < 0 or y > grid_boundary ->
              acc
            {x, y} ->
              MapSet.put(acc, {x, y})
          end
          acc
      end)
  end)
  # |> IO.inspect(label: "final result")
  |> Enum.count
  |> IO.inspect(label: "final score")

 end
end
