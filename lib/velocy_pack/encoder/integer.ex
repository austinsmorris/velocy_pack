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

  def encode(value, _) when value < -9_223_372_036_854_775_808 do
    raise "Cannot encode integers less than -9_223_372_036_854_775_808."
  end

  def encode(value, _) when value < -36_028_797_018_963_968, do: <<0x27, value::little-signed-size(64)>>
  def encode(value, _) when value < -140_737_488_355_328, do: <<0x26, value::little-signed-size(56)>>
  def encode(value, _) when value < -549_755_813_888, do: <<0x25, value::little-signed-size(48)>>
  def encode(value, _) when value < -2_147_483_648, do: <<0x24, value::little-signed-size(40)>>
  def encode(value, _) when value < -8_388_608, do: <<0x23, value::little-signed-size(32)>>
  def encode(value, _) when value < -32_768, do: <<0x22, value::little-signed-size(24)>>
  def encode(value, _) when value < -128, do: <<0x21, value::little-signed-size(16)>>
  def encode(value, _) when value < 0, do: <<0x20, value::little-signed-size(8)>>

  def encode(value, _) when value <= 255, do: <<0x28, value::little-unsigned-size(8)>>
  def encode(value, _) when value <= 65_535, do: <<0x29, value::little-unsigned-size(16)>>
  def encode(value, _) when value <= 16_777_215, do: <<0x2a, value::little-unsigned-size(24)>>
  def encode(value, _) when value <= 4_294_967_295, do: <<0x2b, value::little-unsigned-size(32)>>
  def encode(value, _) when value <= 1_099_511_627_775, do: <<0x2c, value::little-unsigned-size(40)>>
  def encode(value, _) when value <= 281_474_976_710_655, do: <<0x2d, value::little-unsigned-size(48)>>
  def encode(value, _) when value <= 72_057_594_037_927_935, do: <<0x2e, value::little-unsigned-size(56)>>
  def encode(value, _) when value <= 18_446_744_073_709_551_615, do: <<0x2f, value::little-unsigned-size(64)>>

  def encode(_, _) do
    raise "Cannot encode integers greater than 18_446_744_073_709_551_615."
  end
end
