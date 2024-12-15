defmodule Day7.Part1 do
  def process(_) do
    x = "./input.txt"
    |> File.stream!()
    |> Enum.reduce(0, fn line, acc ->
      [target, parts] = line
      |> String.split(":", trim: true)
      target = String.to_integer(target)

      parts = String.split(parts)
      |> Enum.map(&String.to_integer/1)

      n_operators = length(parts) - 1
      success = Enum.reduce_while(0..(2 ** n_operators), false, fn
        n, _->
          # Iterate over all permutations of operators by using the binary representation of the number
          operators = Integer.to_string(n, 2)
          |> String.pad_leading(n_operators, "0")
          |> String.graphemes
          |> Enum.map(fn
            "0" -> &Kernel.*/2
            "1" -> &Kernel.+/2
          end)
          result = Enum.zip([nil] ++ operators, parts)
          |> Enum.reduce(nil, fn
            {nil, i}, nil -> i
            {operator, i}, acc -> operator.(i, acc)
          end)
          case result == target do
            true -> {:halt, true}
            false -> {:cont, false}
          end
      end)

      case success do
        true ->acc + target
        false -> acc
      end
    end)

    IO.inspect x, lable: "Score Part1: "

  end
end
