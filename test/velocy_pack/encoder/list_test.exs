defmodule VelocyPack.Encoder.ListTest do
  alias VelocyPack.Encoder

  use ExUnit.Case, async: true

  test "encode() with empty list" do
    assert Encoder.encode([]) == [0x01]
  end

  test "encode() with list when items are variable size" do
    assert Encoder.encode([1, "a", 10]) ==
      [0x06, <<0x0b>>, <<0x03>>, [0x31, <<0x41, 0x61>>, <<0x28, 0x0a>>], [0x03, 0x04, 0x06]]
  end

  test "encode_with_size() with empty list" do
    assert Encoder.encode_with_size([]) == {0x01, 1}
  end

  test "encode_with_size() with list when items are variable size" do
    assert Encoder.encode_with_size([1, "a", 10]) ==
      {[0x06, <<0x0b>>, <<0x03>>, [0x31, <<0x41, 0x61>>, <<0x28, 0x0a>>], [0x03, 0x04, 0x06]], 11}
  end
end
