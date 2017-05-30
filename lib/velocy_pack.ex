defmodule VelocyPack do
  @moduledoc """
  Documentation for VelocyPack.
  """

  alias VelocyPack.Encoder

  def encode(value, options \\ []) do
    {:ok, value |> encode_to_iodata!(options) |> IO.iodata_to_binary()}
  rescue
    error -> {:error, error}
  end

  def encode!(value, options \\ []) do
    value |> encode_to_iodata!(options) |> IO.iodata_to_binary()
  end

  def encode_to_iodata(value, options \\ []) do
    {:ok, encode_to_iodata!(value, options)}
  rescue
    error -> {:error, error}
  end

  def encode_to_iodata!(value, options \\ []) do
    Encoder.encode(value, options)
  end

  def decode(iodata, options \\ []) do
    # todo - implement
  end
  def decode!(iodata, options \\ []) do
    # todo - implement
  end
end
