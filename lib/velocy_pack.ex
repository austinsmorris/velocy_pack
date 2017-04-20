defmodule VelocyPack do
  @moduledoc """
  Documentation for VelocyPack.
  """

  alias VelocyPack.Encoder

  def encode(value, options \\ []) do
    Encoder.encode(value, options)
  end
end
