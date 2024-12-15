defmodule Day6.Part2.Patrol do
  @spec move(%Day6.State{}) :: [Day6.T.coord()]
  defp move(%Day6.State{pointing: :up, guard: {gx, _}} = state) do
    collision = Day6.Objects.collide(:up, state.objects, state.guard)
    # IO.inspect({state.pointing, state.guard, state.forked, collision}, label: "{pointing, guard, forked, collision}")

    {last_position, result} =
      case collision do
        nil ->
          {{gx, 0}, state}

        {collisionx, collisiony} ->
          last_position = {collisionx, collisiony + 1}

          case Map.get(state.history, last_position) do
            nil ->
              n = Day6.State.next(state, last_position)
              n = n
              {last_position, move(n)}

            _ ->
              {last_position,
               %Day6.State{
                 state
                 | forked: nil,
                   looping_forks: state.looping_forks ++ [state.forked]
               }}
          end
      end

    if state.forked == nil do
      looping_forks =
        Day6.Part2.Score.expand_path(%Day6.Path{
          direction: :up,
          start: state.guard,
          end: last_position
        })
        |> Enum.map(fn position ->
          move(%Day6.State{Day6.State.next(state, position) | forked: position})
        end)
        |> Enum.map(fn state -> state.looping_forks end)
        |> Enum.filter(&(&1 != []))

      # IO.inspect(looping_forks, label: "looping forks: ")
      %Day6.State{result | forked: nil, looping_forks: result.looping_forks ++ looping_forks}
    else
      result
    end
  end

  defp move(%Day6.State{pointing: :right, guard: {_, gy}} = state) do
    collision = Day6.Objects.collide(:right, state.objects, state.guard)
    # IO.inspect({state.pointing, state.guard, state.forked, collision}, label: "{pointing, guard, forked, collision}")

    {last_position, result} =
      case collision do
        nil ->
          {{Const.rowsize() - 1, gy}, state}

        {collisionx, collisiony} ->
          last_position = {collisionx - 1, collisiony}

          case Map.get(state.history, last_position) do
            nil ->
              n = Day6.State.next(state, last_position)
              n = n
              {last_position, move(n)}

            _ ->
              {last_position,
               %Day6.State{
                 state
                 | forked: nil,
                   looping_forks: state.looping_forks ++ [state.forked]
               }}
          end
      end

    if state.forked == nil do
      looping_forks =
        Day6.Part2.Score.expand_path(%Day6.Path{
          direction: :right,
          start: state.guard,
          end: last_position
        })
        |> Enum.map(fn position ->
          move(%Day6.State{Day6.State.next(state, position) | forked: position})
        end)
        |> Enum.map(fn state -> state.looping_forks end)
        |> Enum.filter(&(&1 != []))

      IO.inspect(looping_forks, label: "looping forks: ")
      %Day6.State{result | forked: nil, looping_forks: result.looping_forks ++ looping_forks}
    else
      result
    end
  end

  defp move(%Day6.State{pointing: :down, guard: {gx, _}} = state) do
    collision = Day6.Objects.collide(:down, state.objects, state.guard)
    # IO.inspect({state.pointing, state.guard, state.forked, collision}, label: "{pointing, guard, forked, collision}")

    {last_position, result} =
      case collision do
        nil ->
          {{gx, Const.rowsize() - 1}, state}

        {collisionx, collisiony} ->
          last_position = {collisionx, collisiony - 1}

          case Map.get(state.history, last_position) do
            nil ->
              {last_position, move(Day6.State.next(state, last_position))}

            _ ->
              {last_position,
               %Day6.State{
                 state
                 | forked: nil,
                   looping_forks: state.looping_forks ++ [state.forked]
               }}
          end
      end

    if state.forked == nil do
      looping_forks =
        Day6.Part2.Score.expand_path(%Day6.Path{
          direction: :down,
          start: state.guard,
          end: last_position
        })
        |> Enum.map(fn position ->
          move(%Day6.State{Day6.State.next(state, position) | forked: position})
        end)
        |> Enum.map(fn state -> state.looping_forks end)
        |> Enum.filter(&(&1 != []))

      IO.inspect(looping_forks, label: "looping forks: ")
      %Day6.State{result | forked: nil, looping_forks: result.looping_forks ++ looping_forks}
    else
      result
    end
  end

  defp move(%Day6.State{pointing: :left, guard: {_, gy}} = state) do
    collision = Day6.Objects.collide(:left, state.objects, state.guard)
    # IO.inspect({state.pointing, state.guard, state.forked, collision}, label: "{pointing, guard, forked, collision}")

    # todo: refactor the rest to be like this
    {last_position, result} =
      case collision do
        nil ->
          {{0, gy}, state}

        {collisionx, collisiony} ->
          last_position = {collisionx + 1, collisiony}

          case Map.get(state.history, last_position) do
            nil ->
              {last_position, move(Day6.State.next(state, last_position))}

            _ ->
              {last_position,
               %Day6.State{state | looping_forks: state.looping_forks ++ [state.forked]}}
          end
      end

    if state.forked == nil do
      looping_forks =
        Day6.Part2.Score.expand_path(%Day6.Path{
          direction: :left,
          start: state.guard,
          end: last_position
        })
        |> Enum.map(fn position ->
          move(%Day6.State{Day6.State.next(state, position) | forked: position})
        end)
        |> Enum.map(fn state -> state.looping_forks end)
        |> Enum.filter(&(&1 != []))

      IO.inspect(looping_forks, label: "looping forks: ")
      %Day6.State{result | forked: nil, looping_forks: result.looping_forks ++ looping_forks}
    else
      result
    end
  end

  def patrol(state) do
    move(state)
  end
end

defmodule Day6.Part2.Score do
  @spec expand_path(%Day6.Path{}) :: [Day6.T.coord()]
  def expand_path(%Day6.Path{direction: :up, start: {x1, y1}, end: {_, y2}}) do
    for y <- y1..y2, do: {x1, y}
  end

  def expand_path(%Day6.Path{direction: :down, start: {x1, y1}, end: {_, y2}}) do
    for y <- y1..y2, do: {x1, y}
  end

  def expand_path(%Day6.Path{direction: :left, start: {x1, y1}, end: {x2, _}}) do
    for x <- x1..x2, do: {x, y1}
  end

  def expand_path(%Day6.Path{direction: :right, start: {x1, y1}, end: {x2, _}}) do
    for x <- x1..x2, do: {x, y1}
  end

  def score(paths) do
    paths
    |> Enum.flat_map(&expand_path/1)
    |> MapSet.new()
    |> Enum.count()
  end
end
