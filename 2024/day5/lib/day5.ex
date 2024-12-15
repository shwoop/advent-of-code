defmodule Day5 do
  @spec main(any()) :: any()
  def main(_args) do
    result = "./input.txt"
    |> File.stream!
    |> Enum.map(&String.trim/1)
    |> Enum.reduce(nil, &Day5.Part1.process/2)

    IO.puts "score: #{result.score}"
  end
end
