defmodule ValidateReport.Iter do
  defstruct previous: nil, unsafe: false, increasing: nil, used_dampener: false, iterations: 0
end

defmodule ValidateReports do
   alias ValidateReport.Iter
  def validate(current, nil) do
      {:cont, %Iter{previous: current}}
  end
  def validate(current, %Iter{previous: p, increasing: increasing}) when current - p in [1,2,3] and increasing in [nil, true]  do
      {:cont, %Iter{previous: current, increasing: true}}
  end
  def validate(current, %Iter{previous: p, increasing: increasing}) when current - p in [-1,-2,-3] and increasing in [nil, false] do
      {:cont, %Iter{previous: current, increasing: false}}
  end
  def validate(_, _) do
      {:halt, %Iter{unsafe: true}}
  end
end

"./2024/2/reports.txt"
|> File.stream!
|> Enum.reduce(0, fn lst, acc ->
  result = lst
  |> String.split
  |> Enum.map(&String.to_integer/1)
  |>Enum.reduce_while(nil, &ValidateReports.validate/2)

  case result do
    %{unsafe: true} -> acc
    _ -> acc + 1
  end
end)
|> Integer.to_string
|> (&("first answer: " <> &1)).()
|> IO.puts


defmodule Permutations do
  def remove_one(x) do
    for {_, i} <- Enum.with_index(x), do: List.delete_at(x, i)
  end
end

"./2024/2/reports.txt"
|> File.stream!
|> Enum.reduce(0, fn lst, acc ->
  reports = lst
  |> String.split
  |> Enum.map(&String.to_integer/1)

  result = Enum.any?(Permutations.remove_one(reports), fn x ->
    case Enum.reduce_while(x, nil, &ValidateReports.validate/2) do
      %{unsafe: true} ->
      false
      _ -> acc + 1
      true
    end
  end)

  case result do
    false -> acc
    _ -> acc + 1
  end

end)
|> Integer.to_string
|> (&("second answer: " <> &1)).()
|> IO.puts
