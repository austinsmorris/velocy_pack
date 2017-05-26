defimpl VelocyPack.Encoder, for: BitString do
  def encode(<<>>, _), do: 0x40
  def encode(value, _) when is_binary(value) and byte_size(value) <= 126 do
    <<(byte_size(value) + 0x40), value::binary>>
  end
  def encode(value, _) when is_binary(value) do
    <<0xbf, byte_size(value)::little-unsigned-size(64), value::binary>>
  end

  def encode_with_size(<<>>, _), do: {0x40, 1}
end
