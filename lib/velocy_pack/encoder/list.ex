defimpl VelocyPack.Encoder, for: List do
  def encode([], _), do: 0x01
end
