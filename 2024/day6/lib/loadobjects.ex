defmodule Day6.T do
  @type coord :: {integer, integer}
end

maxwidth = 10
maxdepth = 10

defmodule Day6.LoadObjects do
  defstruct guard: nil, objects: []

  # @type t :: %__MODULE__{
  #   guard: coord,
  #   objects: [coord],
  # }

  @spec load(String.t()) :: %__MODULE__{}
  def load(filepath) do
    filepath
    |> File.stream!
    |> Enum.map(&String.trim/1)
    |> Enum.with_index
    |> Enum.reduce(%__MODULE__{}, &identify_objects/2)

  end

  @spec identify_objects({String.t(), integer}, %__MODULE__{}) :: %__MODULE__{}
  def identify_objects({line, y}, state) do
    rowstate = line
    |> String.graphemes
    |> Enum.with_index
    |> Enum.reduce(%__MODULE__{}, fn
      {".", _}, acc -> acc
      {"^", x}, acc -> %__MODULE__{
        guard: {x, y},
        objects: acc.objects,
      }
      {"#", x}, acc -> %__MODULE__{
        guard: acc.guard,
        objects: [{x, y} | acc.objects]
      }
    end)

    %__MODULE__{
      guard: if rowstate.guard != nil do
        rowstate.guard
      else
        state.guard
      end,
      objects: state.objects ++ rowstate.objects
    }
  end

end

defmodule Day6.PrintScene do
  @spec print([Day6.T.coord]) :: nil
  def print(objects) do
    0..99
    |> Enum.reduce("", fn n, acc ->
      y = n/10 |> trunc
      x = rem(n, 10)
      nl = if x == 0 and n != 0 do
        "\n"
      else
        ""
      end
      icon = if {x,y} in objects do
        "#"
      else
        "."
      end
      acc <> nl <> icon
    end)
    |> IO.puts
    nil
  end

  @spec print([Day6.T.coord]) :: nil
  def print(objects) do
    0..99
    |> Enum.reduce("", fn n, acc ->
      y = n/10 |> trunc
      x = rem(n, 10)
      nl = if x == 0 and n != 0 do
        "\n"
      else
        ""
      end
      icon = if {x,y} in objects do
        "#"
      else
        "."
      end
      acc <> nl <> icon
    end)
    |> IO.puts
    nil
  end

  @spec print([Day6.T.coord]) :: Nx.Tensor.t()
  def tensor(objects) do
    data = 0..99
    |> Enum.reduce([], fn n, acc ->
      y = n/10 |> trunc
      x = rem(n, 10)
      if {x,y} in objects do
        acc ++ [1]
      else
        acc ++ [0]
      end
    end)

    t = Nx.tensor(data) |> Nx.reshape({10,10}, names: [:x, :y])
    IO.inspect t
    t
  end
end
