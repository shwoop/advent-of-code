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
  defstruct guard: nil,
            objects: [],
            paths: [],
            pointing: :up,
            history: %{},
            forked: nil,
            looping_forks: []

  @spec next_pointing(Day6.T.direction()) :: Day6.T.direction()
  defp next_pointing(:up) do
    :right
  end

  defp next_pointing(:right) do
    :down
  end

  defp next_pointing(:down) do
    :left
  end

  defp next_pointing(:left) do
    :up
  end

  @spec next(%__MODULE__{}, Day6.T.coord()) :: %__MODULE__{}
  def next(state, last_position) do
    %__MODULE__{
      pointing: next_pointing(state.pointing),
      guard: last_position,
      objects: state.objects,
      history: Map.put(state.history, last_position, true),
      paths: [
        %Day6.Path{direction: state.pointing, start: state.guard, end: last_position}
        | state.paths
      ]
    }
  end
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

defmodule Day6.Objects do
  @spec collide(Day6.T.direction(), [Day6.T.coord()], Day6.T.coord()) :: Day6.T.coord() | nil
  def collide(:up, objects, {gx, gy}) do
    objects
    |> Enum.filter(fn
      {^gx, y} when y < gy -> true
      _ -> false
    end)
    |> Enum.reduce(nil, fn
      first, nil -> first
      {_, y} = obj, {_, yy} when y > yy -> obj
      _, acc -> acc
    end)
  end

  def collide(:right, objects, {gx, gy}) do
    objects
    |> Enum.filter(fn
      {x, ^gy} when x > gx -> true
      _ -> false
    end)
    |> Enum.reduce(nil, fn
      first, nil -> first
      {x, _} = obj, {xx, _} when x < xx -> obj
      _, acc -> acc
    end)
  end

  def collide(:down, objects, {gx, gy}) do
    objects
    |> Enum.filter(fn
      {^gx, y} when y > gy -> true
      _ -> false
    end)
    |> Enum.reduce(nil, fn
      first, nil -> first
      {_, y} = obj, {_, yy} when y < yy -> obj
      _, acc -> acc
    end)
  end

  def collide(:left, objects, {gx, gy}) do
    objects
    |> Enum.filter(fn
      {x, ^gy} when x < gx -> true
      _ -> false
    end)
    |> Enum.reduce(nil, fn
      first, nil -> first
      {x, _} = obj, {xx, _} when x > xx -> obj
      _, acc -> acc
    end)
  end
end
