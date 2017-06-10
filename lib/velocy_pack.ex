defmodule VelocyPack do
  @moduledoc """
  Documentation for VelocyPack.
  """

  alias VelocyPack.Decoder
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

  def decode(data, options \\ []) when is_binary(data)do
    Decoder.decode(data, options)
  rescue
    error -> {:error, error}
  end

  def decode!(data, options \\ []) when is_binary(data)do
    case Decoder.decode(data, options) do
      {:ok, value, ""} -> value
      {:ok, value, tail} ->
        # todo - raise because there are multiple values
        :foo
      error ->
        # todo - raise because something bad happened
        :foo
    end
  end
end
