defmodule Day6.T do
  @type coord :: {integer, integer}
  @type direction :: :up | :down | :left | :right | :finished
end

defmodule Day6.Walk do
  defstruct direction: :up, start: nil, end: nil
end

maxwidth = 10
maxdepth = 10

defmodule Day6.LoadObjects do
  defstruct guard: nil, objects: [], paths: [], pointing: :up

  # @type t :: %__MODULE__{
  #   guard: coord,
  #   objects: [coord],
  # }

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
    collision =
      state.objects
      |> Enum.filter(fn
        {^gx, y} when y < gy -> true
        _ -> false
      end)
      |> Enum.reduce(fn
        {_, y} = obj, {_, yy} when y < yy -> obj
        _, acc -> acc
      end)

    case collision do
      nil ->
        # todo: ad done last walk to edge of map
        state

      {collisionx, collisiony} ->
        last_position = {collisionx, collisiony + 1}
        IO.inspect(last_position)

        move(%Day6.LoadObjects{
          pointing: :right,
          guard: last_position,
          objects: state.objects,
          paths: [
            %Day6.Walk{direction: :up, start: state.guard, end: last_position} | state.paths
          ]
        })
    end
  end

  def move(%Day6.LoadObjects{pointing: :right, guard: {gx, gy}} = state) do
    collision =
      state.objects
      |> Enum.filter(fn
        {x, ^gy} when x > gx -> true
        _ -> false
      end)
      |> Enum.reduce(fn
        {_, x} = obj, {_, xx} when x < xx -> obj
        _, acc -> acc
      end)

    case collision do
      nil ->
        # todo: ad done last walk to edge of map
        state

      {collisionx, collisiony} ->
        last_position = {collisionx - 1, collisiony}
        IO.inspect(last_position)

        move(%Day6.LoadObjects{
          pointing: :down,
          guard: last_position,
          objects: state.objects,
          paths: [
            %Day6.Walk{direction: :right, start: state.guard, end: last_position} | state.paths
          ]
        })
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
        {_, y} = obj, {_, yy} when y > yy -> obj
        _, acc -> acc
      end)

    case collision do
      nil ->
        # todo: ad done last walk to edge of map
        state

      {collisionx, collisiony} ->
        last_position = {collisionx, collisiony - 1}
        IO.inspect(last_position)

        move(%Day6.LoadObjects{
          pointing: :left,
          guard: last_position,
          objects: state.objects,
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
        {_, x} = obj, {_, xx} when x > xx -> obj
        _, acc -> acc
      end)

    case collision do
      nil ->
        # todo: ad done last walk to edge of map
        state

      {collisionx, collisiony} ->
        last_position = {collisionx + 1, collisiony}
        IO.inspect(last_position)

        move(%Day6.LoadObjects{
          pointing: :up,
          guard: last_position,
          objects: state.objects,
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

defmodule Day6.PrintScene do
  @spec print([Day6.T.coord()]) :: nil
  def print(objects) do
    0..99
    |> Enum.reduce("", fn n, acc ->
      y = (n / 10) |> trunc
      x = rem(n, 10)

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

  @spec print([Day6.T.coord()]) :: Nx.Tensor.t()
  def tensor(objects) do
    data =
      0..99
      |> Enum.reduce([], fn n, acc ->
        y = (n / 10) |> trunc
        x = rem(n, 10)

        if {x, y} in objects do
          acc ++ [1]
        else
          acc ++ [0]
        end
      end)

    t = Nx.tensor(data) |> Nx.reshape({10, 10}, names: [:x, :y])
    IO.inspect(t)
    t
  end
end
