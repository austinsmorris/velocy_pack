defimpl VelocyPack.Encoder, for: Atom do
  @moduledoc """
  Implementation of the VelocyPack.Encoder protocol for Atom.
  """

  alias VelocyPack.Encoder

  def encode(value, opts \\ [])

  def encode(nil, _), do: [0x18]

  def encode(false, _), do: [0x19]

  def encode(true, _), do: [0x1A]

  def encode(value, opts) do
    value
    |> Atom.to_string()
    |> Encoder.encode(opts)
  end

  def encode_with_size(value, opts \\ [])

  def encode_with_size(nil, _), do: {0x18, 1}

  def encode_with_size(false, _), do: {0x19, 1}

  def encode_with_size(true, _), do: {0x1A, 1}

  def encode_with_size(value, opts) do
    value
    |> Atom.to_string()
    |> Encoder.encode_with_size(opts)
  end
end
