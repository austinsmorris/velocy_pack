defimpl VelocyPack.Encoder, for: List do
  @moduledoc """
  Implementation of the VelocyPack.Encoder protocol for List.
  """

  alias VelocyPack.Encode

  def encode(value, _opts), do: Encode.encode_list(value)

  def encode_with_size(value, _opts), do: Encode.encode_list_with_size(value)
end
