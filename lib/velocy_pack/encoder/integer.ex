defimpl VelocyPack.Encoder, for: Integer do
  def encode(0, _), do: 0x30
  def encode(1, _), do: 0x31
  def encode(2, _), do: 0x32
  def encode(3, _), do: 0x33
  def encode(4, _), do: 0x34
  def encode(5, _), do: 0x35
  def encode(6, _), do: 0x36
  def encode(7, _), do: 0x37
  def encode(8, _), do: 0x38
  def encode(9, _), do: 0x39

  def encode(-6, _), do: 0x3a
  def encode(-5, _), do: 0x3b
  def encode(-4, _), do: 0x3c
  def encode(-3, _), do: 0x3d
  def encode(-2, _), do: 0x3e
  def encode(-1, _), do: 0x3f
end
