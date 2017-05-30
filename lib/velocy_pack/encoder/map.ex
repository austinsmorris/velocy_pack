defimpl VelocyPack.Encoder, for: Map do
  def encode(%{}, _), do: [0x0a]

  def encode_with_size(%{}, _), do: {0x0a, 1}
end
