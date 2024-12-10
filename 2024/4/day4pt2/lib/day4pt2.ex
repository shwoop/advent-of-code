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

  def main(_args) do
    "./inputs.txt"
    |> File.stream!()
    |> Enum.reduce(nil, &XmasScan.scan/2)
  end
end
