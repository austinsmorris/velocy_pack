defmodule VelocyPack do
  @moduledoc """
  Documentation for VelocyPack.
  """

  alias VelocyPack.Encoder

  def encode(value, options \\ []) do
    try do
      {:ok, encode_to_iodata!(value, options) |> IO.iodata_to_binary()}
    rescue
      error -> {:error, error}
    end
  end

  def encode!(value, options \\ []) do
    encode_to_iodata!(value, options) |> IO.iodata_to_binary()
  end

  def encode_to_iodata(value, options \\ []) do
    try do
      {:ok, encode_to_iodata!(value, options)}
    rescue
      error -> {:error, error}
    end
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
