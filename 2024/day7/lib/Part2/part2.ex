defmodule Day7.Part2 do
  @spec parallel_reduce([], integer, (String.t(), integer() -> integer())) :: integer()
  def parallel_reduce(enumerable, i, fun) do
    enumerable
    |> Enum.map(fn x ->
      Task.async(fn -> fun.(x, i) end)
    end)
    |> Enum.map(&Task.await/1)
    |> Enum.reduce(fn result, total -> total + result end)
  end

  @spec solve(String.t(), integer()) :: integer()
  def solve(line, acc) do
    [target, parts] = line
      |> String.split(":", trim: true)
      target = String.to_integer(target)

      parts = String.split(parts)
      |> Enum.map(&String.to_integer/1)

      n_operators = length(parts) - 1
      success = Enum.reduce_while(0..(3 ** n_operators), false, fn
        n, _->
          # Iterate over all permutations of operators by using the trinary representation of the number
          operators = Integer.to_string(n, 3)
          |> String.pad_leading(n_operators, "0")
          |> String.graphemes
          |> Enum.map(fn
            "0" -> &Kernel.*/2
            "1" -> &Kernel.+/2
            "2" -> fn a, b ->
              n = Integer.to_string(a) <> Integer.to_string(b)
              String.to_integer(n)
            end
          end)
          result = Enum.zip([nil] ++ operators, parts)
          |> Enum.reduce(nil, fn
            {nil, i}, nil -> i
            {operator, i}, acc -> operator.(acc, i)
          end)
          # IO.inspect {target, result, Enum.zip([nil] ++ operators, parts)}
          case result == target do
            true ->
              {:halt, true}
            false -> {:cont, false}
          end
      end)

      case success do
        true ->acc + target
        false -> acc
      end
  end

  def process(_) do
    x = "./input.txt"
    |> File.stream!()
    |> parallel_reduce(0, &solve/2)


    IO.inspect x, label: "Score Part2: "

  end
end
