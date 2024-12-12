defmodule Day6 do
  @spec main(any()) :: any()
  def main(_args) do
    scene = Day6.Scene.load("./input.txt")

    # Day6.PrintScene.print(scene.objects)

    final_state = Day6.Day1.Patrol.patrol(%Day6.State{guard: scene.guard, objects: scene.objects})
    IO.puts("final score #{Integer.to_string(Day6.Part1.Score.score(final_state.paths))}")
  end
end
