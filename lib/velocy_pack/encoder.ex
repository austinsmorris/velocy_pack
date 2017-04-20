defprotocol VelocyPack.Encoder do
  def encode(value, options \\ [])
end
