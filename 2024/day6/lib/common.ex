defmodule Day6.T do
  @type coord :: {integer, integer}
  @type direction :: :up | :down | :left | :right
end

defmodule Day6.Path do
  defstruct direction: :up, start: nil, end: nil
end

defmodule Const do
  def rowsize() do
    130
  end
end

defmodule Day6.State do
  defstruct guard: nil, objects: [], paths: [], pointing: :up, history: %{}
end

defmodule Day6.Scene do
  defstruct guard: nil, objects: []

  @spec load(String.t()) :: %__MODULE__{}
  def load(filepath) do
    filepath
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.reduce(%__MODULE__{}, &identify_objects/2)
  end

  @spec identify_objects({String.t(), integer}, %__MODULE__{}) :: %__MODULE__{}
  def identify_objects({line, y}, state) do
    rowstate =
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(%__MODULE__{}, fn
        {".", _}, acc ->
          acc

        {"^", x}, acc ->
          %__MODULE__{
            guard: {x, y},
            objects: acc.objects
          }

        {"#", x}, acc ->
          %__MODULE__{
            guard: acc.guard,
            objects: [{x, y} | acc.objects]
          }
      end)

    %__MODULE__{
      guard:
        if rowstate.guard != nil do
          rowstate.guard
        else
          state.guard
        end,
      objects: state.objects ++ rowstate.objects
    }
  end
end

defmodule Day6.PrintScene do
  @spec print([Day6.T.coord()]) :: nil
  def print(objects) do
    0..(Const.rowsize() * Const.rowsize())
    |> Enum.reduce("", fn n, acc ->
      y = (n / Const.rowsize()) |> trunc
      x = rem(n, Const.rowsize())

      nl =
        if x == 0 and n != 0 do
          "\n"
        else
          ""
        end

      icon =
        if {x, y} in objects do
          "#"
        else
          "."
        end

      acc <> nl <> icon
    end)
    |> IO.puts()

    nil
  end
end
