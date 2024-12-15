defmodule Day6 do
  @spec main(any()) :: any()
  def main(_args) do
    scene = Day6.Scene.load("./input.txt")

    # Day6.PrintScene.print(scene.objects)

    # # Part1
    final_state =
      Day6.Part1.Patrol.patrol(%Day6.State{guard: scene.guard, objects: scene.objects})
    IO.inspect Day6.Part1.Score.score(final_state.paths), label: "score"

    # Part2
    # final_state = Day6.Part2.Patrol.patrol(%Day6.State{guard: scene.guard, objects: scene.objects})
    # IO.inspect final_state.looping_forks, label: "final forks"
  end
end
