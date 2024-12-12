defmodule Day6.Day1.Patrol do
  defp move(%Day6.State{pointing: :up, guard: {gx, gy}} = state) do
    collision = Day6.Objects.collide(:up, state.objects, state.guard)

    case collision do
      nil ->
        %{
          state
          | paths: [%Day6.Path{direction: :up, start: state.guard, end: {gx, 0}} | state.paths]
        }

      {collisionx, collisiony} ->
        last_position = {collisionx, collisiony + 1}
        visits = Map.get(state.history, last_position, "")
        IO.puts("#{inspect(last_position)}: ^ #{visits}")

        move(%Day6.State{
          pointing: :right,
          guard: last_position,
          objects: state.objects,
          history: Map.put(state.history, last_position, "+" <> visits),
          paths: [
            %Day6.Path{direction: :up, start: state.guard, end: last_position} | state.paths
          ]
        })
    end
  end

  defp move(%Day6.State{pointing: :right, guard: {gx, gy}} = state) do
    collision = Day6.Objects.collide(:right, state.objects, state.guard)

    case collision do
      nil ->
        %{
          state
          | paths: [
              %Day6.Path{direction: :right, start: state.guard, end: {Const.rowsize() - 1, gy}}
              | state.paths
            ]
        }

      {collisionx, collisiony} ->
        last_position = {collisionx - 1, collisiony}
        visits = Map.get(state.history, last_position, "")
        IO.puts("#{inspect(last_position)}: > #{visits}")

        case visits do
          "" ->
            move(%Day6.State{
              pointing: :down,
              guard: last_position,
              objects: state.objects,
              history: Map.put(state.history, last_position, "+" <> visits),
              paths: [
                %Day6.Path{direction: :right, start: state.guard, end: last_position}
                | state.paths
              ]
            })

          _ ->
            nil
        end
    end
  end

  defp move(%Day6.State{pointing: :down, guard: {gx, gy}} = state) do
    collision = Day6.Objects.collide(:down, state.objects, state.guard)

    case collision do
      nil ->
        %{
          state
          | paths: [
              %Day6.Path{direction: :down, start: state.guard, end: {gx, Const.rowsize() - 1}}
              | state.paths
            ]
        }

      {collisionx, collisiony} ->
        last_position = {collisionx, collisiony - 1}
        visits = Map.get(state.history, last_position, "")
        IO.puts("#{inspect(last_position)}: V #{visits}")

        move(%Day6.State{
          pointing: :left,
          guard: last_position,
          objects: state.objects,
          history: Map.put(state.history, last_position, "+" <> visits),
          paths: [
            %Day6.Path{direction: :down, start: state.guard, end: last_position} | state.paths
          ]
        })
    end
  end

  defp move(%Day6.State{pointing: :left, guard: {gx, gy}} = state) do
    collision = Day6.Objects.collide(:left, state.objects, state.guard)

    case collision do
      nil ->
        %{
          state
          | paths: [%Day6.Path{direction: :left, start: state.guard, end: {0, gy}} | state.paths]
        }

      {collisionx, collisiony} ->
        last_position = {collisionx + 1, collisiony}
        visits = Map.get(state.history, last_position, "")
        IO.puts("#{inspect(last_position)}: < #{visits}")

        move(%Day6.State{
          pointing: :up,
          guard: last_position,
          objects: state.objects,
          history: Map.put(state.history, last_position, "+" <> visits),
          paths: [
            %Day6.Path{direction: :left, start: state.guard, end: last_position} | state.paths
          ]
        })
    end
  end

  def patrol(state) do
    move(state)
  end
end

defmodule Day6.Part1.Score do
  @spec expand_path(%Day6.Path{}) :: [Day6.T.coord()]
  defp expand_path(%Day6.Path{direction: :up, start: {x1, y1}, end: {_, y2}}) do
    for y <- y1..y2, do: {x1, y}
  end

  defp expand_path(%Day6.Path{direction: :down, start: {x1, y1}, end: {_, y2}}) do
    for y <- y1..y2, do: {x1, y}
  end

  defp expand_path(%Day6.Path{direction: :left, start: {x1, y1}, end: {x2, _}}) do
    for x <- x1..x2, do: {x, y1}
  end

  defp expand_path(%Day6.Path{direction: :right, start: {x1, y1}, end: {x2, _}}) do
    for x <- x1..x2, do: {x, y1}
  end

  def score(paths) do
    paths
    |> Enum.flat_map(&expand_path/1)
    |> MapSet.new()
    |> Enum.count()
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
    |> Enum.reduce(fn
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
    |> Enum.reduce(fn
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
    |> Enum.reduce(fn
      {x, _} = obj, {xx, _} when x > xx -> obj
      _, acc -> acc
    end)
  end
end
