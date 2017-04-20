defmodule VelocyPack.Encoder.BitStringTest do
  use ExUnit.Case, async: true

  test "encode an empty bit string" do
    assert VelocyPack.encode(<<>>) == 0x40
  end

  test "encode an empty string" do
    assert VelocyPack.encode("") == 0x40
  end

  test "encode a short string" do
    assert VelocyPack.encode("foo") == <<0x43, 0x66, 0x6f, 0x6f>>
  end

  test "encode a long string" do
    value = "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkj"
      <> "asdflkajsdflkjasdflkjasdlksjadflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasd"
    <<indicator, size::little-unsigned-size(64), string::binary>> = VelocyPack.encode(value)

    assert indicator == 0xbf
    assert size == byte_size(value)
    assert string == value
  end
end
