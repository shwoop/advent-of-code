defmodule Day4pt2 do
  @moduledoc """
  Documentation for `Day4pt2`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day4pt2.hello()
      :world

  """
  def hello do
    :world
  end

  @spec main(any()) :: any()
  def main(_args) do
    %{score: score} =
      "./inputs.txt"
      |> File.stream!()
      |> Enum.reduce(nil, &XmasScan.scan/2)

    IO.puts(score)
  end
end
