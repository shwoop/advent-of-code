file = "./2024/3/input.txt"
|> File.read!

Regex.scan(~r'mul\(\d{1,3},\d{1,3}\)', file)
|> Enum.reduce(0, fn [x], acc ->
  [a, b] = x |> String.trim(")") |> String.trim_leading("mul(") |> String.split(",")
  String.to_integer(a) * String.to_integer(b) + acc
end)
|> Integer.to_string
|> (&("first answer: " <> &1)).()
|> IO.puts

defmodule StatefulProcessor do
  def process(["do()"], {_, acc}) do
    {true, acc}
  end
  def process(["don't()"], {_, acc}) do
    {false, acc}
  end
  def process([x], {true, acc}) do
    [a, b] = x |> String.trim(")") |> String.trim_leading("mul(") |> String.split(",")
    {true, String.to_integer(a) * String.to_integer(b) + acc}
  end
  def process(_, {false, acc}) do
    {false, acc}
  end
end

{_, result } = Regex.scan(~r'mul\(\d{1,3},\d{1,3}\)|do\(\)|don\'t\(\)', file)
|> Enum.reduce({true, 0}, &StatefulProcessor.process/2)

IO.puts "second answer: #{Integer.to_string(result)}"
