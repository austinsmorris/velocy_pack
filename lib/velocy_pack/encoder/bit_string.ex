defimpl VelocyPack.Encoder, for: BitString do
  @moduledoc """
  Implementation of the VelocyPack.Encoder protocol for BitString.
  """

  alias VelocyPack.Encode

  def encode(value, _opts), do: Encode.encode_string(value)

  def encode_with_size(value, _opts), do: Encode.encode_string_with_size(value)
end
