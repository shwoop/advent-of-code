defmodule Day11 do
  def main(_) do
    starting_arrangement = String.split("125 17")
    1..6
    |> Enum.reduce(starting_arrangement, fn
      n, arrangement ->
        next_arrangement = arrangement |> Enum.flat_map(&mutate/1)
        IO.inspect next_arrangement, label: n
        next_arrangement
      end)


    starting_arrangement = "./input.txt" |> File.read! |> String.split
    IO.inspect(starting_arrangement, label: "starting")
    1..25
    |> Enum.reduce(starting_arrangement, fn
      n, arrangement ->
        next_arrangement = arrangement |> Enum.flat_map(&mutate/1)
        IO.inspect next_arrangement, label: n
        next_arrangement
      end)
    |> Enum.count
    |> IO.inspect(label: "anser")
  end

  def mutate("0") do
    ["1"]
  end
  def mutate(d) do
  charlist = d |> String.graphemes()
  l = length(charlist)
  case Integer.mod(l,2) do
    0 ->
      {a , b} = charlist |> Enum.split(trunc(l/2))
      [Enum.join(a) , Enum.join(b) |> String.to_integer |> Integer.to_string]
    _ -> [(2024 * String.to_integer(d)) |> Integer.to_string]
  end
  end
end
