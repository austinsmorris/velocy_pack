defmodule VelocyPack.Decoder.List do
  @moduledoc false

  alias VelocyPack.Decoder

  def decode(data), do: do_decode(data, [])

  defp do_decode(data, list) do
    case Decoder.decode(data) do
      {:ok, value, ""} -> [value | list] |> Enum.reverse
      {:ok, value, tail} -> do_decode(tail, [value | list])
    end
  end
end
