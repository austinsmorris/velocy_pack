defimpl VelocyPack.Encoder, for: Map do
  @moduledoc """
  Implementation of the VelocyPack.Encoder protocol for Map.
  """

  alias VelocyPack.Encode

  def encode(value, _opts), do: Encode.encode_map(value)

  def encode_with_size(value, _opts), do: Encode.encode_map_with_size(value)
end
