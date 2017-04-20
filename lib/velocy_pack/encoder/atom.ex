defimpl VelocyPack.Encoder, for: Atom do
  def encode(nil, _),   do: 0x18
  def encode(false, _), do: 0x19
  def encode(true, _),  do: 0x1a
end
