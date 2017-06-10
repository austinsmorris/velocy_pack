defmodule VelocyPack.Decoder.List do
  @moduledoc false

  alias VelocyPack.Decoder

  def decode(data), do: do_decode(data, [])

  defp do_decode(data, list) do
    case Decoder.decode(data) do
      {:ok, value, ""} -> list ++ [value]
      {:ok, value, tail} -> do_decode(tail, list ++ [value])
    end
  end
end
