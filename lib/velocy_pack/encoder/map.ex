defimpl VelocyPack.Encoder, for: Map do
  def encode(%{}, _), do: 0x0a
end
