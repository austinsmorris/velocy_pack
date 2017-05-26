defimpl VelocyPack.Encoder, for: Atom do
  def encode(nil, _), do: 0x18
  def encode(false, _), do: 0x19
  def encode(true, _), do: 0x1a

  def encode_with_size(nil, _), do: {0x18, 1}
  def encode_with_size(false, _), do: {0x19, 1}
  def encode_with_size(true, _), do: {0x1a, 1}
end
