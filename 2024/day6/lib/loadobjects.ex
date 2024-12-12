defmodule Day6.T do
  @type coord :: {integer, integer}
  @type direction :: :up | :down | :left | :right
end

defmodule Day6.Walk do
  defstruct direction: :up, start: nil, end: nil
end

defmodule Const do
  def rowsize() do
    130
  end
end

defmodule Day6.LoadObjects do
  defstruct guard: nil, objects: [], paths: [], pointing: :up, history: %{}

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

defmodule Day6.Patrol do
  def move(%Day6.LoadObjects{pointing: :up, guard: {gx, gy}} = state) do
    collisions =
      state.objects
      |> Enum.filter(fn
        {^gx, y} when y < gy -> true
        _ -> false
      end)

      collision = collisions
      |> Enum.reduce(fn
        {_, y} = obj, {_, yy} when y > yy -> obj
        _, acc -> acc
      end)

    case collision do
      nil ->
        %{state | paths: [%Day6.Walk{direction: :up, start: state.guard, end: {gx, 0}} | state.paths]}

      {collisionx, collisiony} ->
        last_position = {collisionx, collisiony + 1}
        visits = Map.get(state.history, last_position, "")
        IO.puts "#{inspect(last_position)}: ^ #{visits}"

        move(%Day6.LoadObjects{
          pointing: :right,
          guard: last_position,
          objects: state.objects,
          history: Map.put(state.history, last_position, "+" <> visits),
          paths: [
            %Day6.Walk{direction: :up, start: state.guard, end: last_position} | state.paths
          ]
        })
    end
  end

  def move(%Day6.LoadObjects{pointing: :right, guard: {gx, gy}} = state) do
    collisions =
      state.objects
      |> Enum.filter(fn
        {x, ^gy} when x > gx -> true
        _ -> false
      end)

      collision = collisions
      |> Enum.reduce(fn
        {x, _} = obj, {xx, _} when x < xx -> obj
        _, acc -> acc
      end)

    case collision do
      nil ->
        %{state | paths: [%Day6.Walk{direction: :right, start: state.guard, end: {Const.rowsize - 1, gy}} | state.paths]}

      {collisionx, collisiony} ->
        last_position = {collisionx - 1, collisiony}
               visits = Map.get(state.history, last_position, "")
        IO.puts "#{inspect(last_position)}: > #{visits}"
        case visits do
          "" ->
            move(%Day6.LoadObjects{
              pointing: :down,
              guard: last_position,
              objects: state.objects,
              history: Map.put(state.history, last_position, "+" <> visits),
              paths: [
                %Day6.Walk{direction: :right, start: state.guard, end: last_position} | state.paths
              ]
            })
          _ -> nil
            end

    end
  end

  def move(%Day6.LoadObjects{pointing: :down, guard: {gx, gy}} = state) do
    collision =
      state.objects
      |> Enum.filter(fn
        {^gx, y} when y > gy -> true
        _ -> false
      end)
      |> Enum.reduce(nil, fn
        first, nil -> first
        {_, y} = obj, {_, yy} when y < yy -> obj
        _, acc -> acc
      end)

    case collision do
      nil ->
        %{state | paths: [%Day6.Walk{direction: :down, start: state.guard, end: {gx, Const.rowsize - 1}} | state.paths]}

      {collisionx, collisiony} ->
        last_position = {collisionx, collisiony - 1}
               visits = Map.get(state.history, last_position, "")
        IO.puts "#{inspect(last_position)}: V #{visits}"

        move(%Day6.LoadObjects{
          pointing: :left,
          guard: last_position,
          objects: state.objects,
          history: Map.put(state.history, last_position, "+" <> visits),
          paths: [
            %Day6.Walk{direction: :down, start: state.guard, end: last_position} | state.paths
          ]
        })
    end
  end

  def move(%Day6.LoadObjects{pointing: :left, guard: {gx, gy}} = state) do
    collision =
      state.objects
      |> Enum.filter(fn
        {x, ^gy} when x < gx -> true
        _ -> false
      end)
      |> Enum.reduce(fn
        {x, _} = obj, {xx, _} when x > xx -> obj
        _, acc -> acc
      end)

    case collision do
      nil ->
        %{state | paths: [%Day6.Walk{direction: :left, start: state.guard, end: {0, gy}} | state.paths]}

      {collisionx, collisiony} ->
        last_position = {collisionx + 1, collisiony}
               visits = Map.get(state.history, last_position, "")
        IO.puts "#{inspect(last_position)}: < #{visits}"
        move(%Day6.LoadObjects{
          pointing: :up,
          guard: last_position,
          objects: state.objects,
          history: Map.put(state.history, last_position, "+" <> visits),
          paths: [
            %Day6.Walk{direction: :left, start: state.guard, end: last_position} | state.paths
          ]
        })
    end
  end

  def patrol(state) do
    move(state)
  end
end


defmodule Day6.Score do
  @spec expand_path(%Day6.Walk{}) :: [Day6.T.coord()]
  def expand_path(%Day6.Walk{direction: :up, start: {x1, y1}, end: {_, y2}}) do
    for y <- y1..y2, do: {x1, y}
  end
  def expand_path(%Day6.Walk{direction: :down, start: {x1, y1}, end: {_, y2}}) do
    for y <- y1..y2, do: {x1, y}
  end
  def expand_path(%Day6.Walk{direction: :left, start: {x1, y1}, end: {x2, _}}) do
    for x <- x1..x2, do: {x, y1}
  end
  def expand_path(%Day6.Walk{direction: :right, start: {x1, y1}, end: {x2, _}}) do
    for x <- x1..x2, do: {x, y1}
  end

  def score(paths) do
    paths
    |> Enum.flat_map(&expand_path/1)
    |> MapSet.new
    |> Enum.count
  end
end

defmodule Day6.PrintScene do
  @spec print([Day6.T.coord()]) :: nil
  def print(objects) do
    0..(Const.rowsize * Const.rowsize)
    |> Enum.reduce("", fn n, acc ->
      y = (n / Const.rowsize) |> trunc
      x = rem(n, Const.rowsize)

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
