defmodule Day6 do
  @spec main(any()) :: any()
  def main(_args) do
    state = Day6.LoadObjects.load("./input.txt")

    # IO.inspect objects
    # Day6.PrintScene.print(state.objects)
    # Day6.PrintScene.tensor(state.objects)

    final_state = Day6.Patrol.patrol(state)
    IO.inspect(final_state)
  end
end
