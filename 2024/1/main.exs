{first_list, second_list} = "./2024/1/input.txt"
|> File.stream!
|> Stream.map(fn x ->
    [f,l|_] = String.split(x)
    {f,l}
end)
|> Enum.to_list
|> Enum.unzip

first_answer = Enum.zip(Enum.sort(first_list), Enum.sort(second_list))
|> Enum.reduce(0, fn {a,b}, acc -> acc + abs(String.to_integer(b) - String.to_integer(a)) end)

IO.puts "first anser #{first_answer}"


counts = second_list
|> Enum.reduce(%{}, fn v, acc -> Map.update(acc, v, 1, &(&1 +1)) end)

second_answer = first_list
|> Enum.reduce(0, fn v, acc -> acc + String.to_integer(v) * Map.get(counts, v, 0) end)

IO.puts "second anser #{second_answer}"
