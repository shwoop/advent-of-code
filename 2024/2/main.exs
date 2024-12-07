"./2024/2/reports.txt"
|> File.stream!
|> Enum.reduce(0, fn lst, acc ->
  result = lst
  |> String.split
  |> Enum.map(&String.to_integer/1)
  |>Enum.reduce_while(%{previous: nil, unsafe: false, increasing: nil}, fn
    _, acc when acc.unsafe == true ->
      {:halt, acc}
    current, %{previous: nil} ->
      {:cont, %{previous: current, unsafe: false, increasing: nil}}
    current, %{previous: p, increasing: increasing} when current - p in [1,2,3] and increasing in [nil, true]  ->
      {:cont, %{previous: current, unsafe: false, increasing: true}}
    current, %{previous: p, increasing: increasing} when current - p in [-1,-2,-3] and increasing in [nil, false] ->
      {:cont, %{previous: current, unsafe: false, increasing: false}}
    _, _ ->
      {:halt, %{unsafe: true}}
  end)

  case result do
    %{unsafe: true} -> acc
    _ -> acc + 1
  end
end)
|> Integer.to_string
|> (&("first answer: " <> &1)).()
|> IO.puts
