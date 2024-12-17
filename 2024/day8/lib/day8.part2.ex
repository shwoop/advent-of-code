defmodule Day8.Part2 do
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
  |> Enum.flat_map(fn
    frequency_antennas ->
      antenna_pairs = frequency_antennas
      |> Enum.flat_map(fn
        a ->
          frequency_antennas
          |> Enum.drop(Enum.find_index(frequency_antennas, &(&1 == a)) + 1)
          |> Enum.map(fn b -> {a, b} end)
      end)
      # |> IO.inspect
      inbounds = fn {x, y} -> x >= 0 and x <= grid_boundary and y >= 0 and y <= grid_boundary end

      antenna_pairs
      |> Enum.map(fn {{x, y} = a, {xx, yy} = b} ->
        dx = xx - x
        dy = yy - y

        aaa = Stream.iterate(a, fn {x, y} -> {x - dx, y - dy} end)
        |> Stream.take_while(inbounds)
        |> Enum.to_list
        # |> IO.inspect(label: "iterate a")

        bbb = Stream.iterate(b, fn {x, y} -> {x + dx, y + dy} end)
        |> Stream.take_while(inbounds)
        |> Enum.to_list
        # |> IO.inspect(label: "iterate b")

        aaa ++ bbb
        # |> IO.inspect(label: "aaabbb")
      end)
  end)
  |> Enum.flat_map(&(&1))
  |> Enum.uniq
  # |> IO.inspect(label: "final result")
  |> Enum.count
  |> IO.inspect(label: "final score")

 end
end
