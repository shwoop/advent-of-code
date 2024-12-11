defmodule Day6 do
  @spec main(any()) :: any()
  def main(_args) do
    objects = Day6.LoadObjects.load("./input.txt")

    # IO.inspect objects
    Day6.PrintScene.print(objects.objects)
    Day6.PrintScene.tensor(objects.objects)

  end
end
