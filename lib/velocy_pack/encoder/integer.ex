defimpl VelocyPack.Encoder, for: Integer do
  @moduledoc """
  Implementation of the VelocyPack.Encoder protocol for Integer.
  """

  alias VelocyPack.Encode

  def encode(value, _opts), do: Encode.encode_integer(value)

  def encode_with_size(value, _opts), do: Encode.encode_integer_with_size(value)
end
