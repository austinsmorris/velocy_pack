defprotocol VelocyPack.Encoder do
  def encode(value, options \\ [])

  def encode_with_size(value, options \\ [])
end
