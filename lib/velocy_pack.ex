defmodule VelocyPack do
  @moduledoc """
  Documentation for VelocyPack.
  """

  alias VelocyPack.Decode
  alias VelocyPack.Encode

  def decode(data, opts \\ []) do
    data
    |> IO.iodata_to_binary()
    |> Decode.decode(opts)
  end

  def decode!(data, opts \\ []) do
    case decode(data, opts) do
      {:ok, value} -> value
      {:ok, value, tail} -> {value, tail}
      {:error, error} -> raise error
    end
  end

  def encode(value, opts \\ []) do
    case Encode.encode(value, opts) do
      {:ok, encoding} -> {:ok, IO.iodata_to_binary(encoding)}
      {:error, error} -> {:error, error}
    end
  end

  def encode!(value, opts \\ []) do
    case Encode.encode(value, opts) do
      {:ok, encoding} -> IO.iodata_to_binary(encoding)
      {:error, error} -> raise error
    end
  end

  def encode_to_iodata(value, opts \\ []) do
    Encode.encode(value, opts)
  end

  def encode_to_iodata!(value, opts \\ []) do
    case Encode.encode(value, opts) do
      {:ok, encoding} -> encoding
      {:error, error} -> raise error
    end
  end
end
