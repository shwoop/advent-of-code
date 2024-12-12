defmodule Day6 do
  @spec main(any()) :: any()
  def main(_args) do
    state = Day6.LoadObjects.load("./input.txt")

    # IO.inspect objects
    Day6.PrintScene.print(state.objects)
    # Day6.PrintScene.tensor(state.objects)

    final_state = Day6.Patrol.patrol(state)
    score = Day6.Score.score(final_state.paths)
    # IO.inspect(final_state)
    IO.puts "final score #{Integer.to_string(score)}"
  end
end
