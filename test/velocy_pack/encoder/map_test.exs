defmodule VelocyPack.Encoder.MapTest do
  alias VelocyPack.Encoder

  use ExUnit.Case, async: true

  test "encode() with empty map" do
    assert Encoder.encode(%{}) == [0x0a]
  end

  test "encode() with non-empty map" do
    assert Encoder.encode(%{b: true, a: 12, c: "xyz"}) ==
      [11, <<19>>, <<3>>, [["Aa", "(\f"], ["Ab", 26], ["Ac", "Cxyz"]], [3, 7, 10]]
  end

  test "encode_with_size() with empty map" do
    assert Encoder.encode_with_size(%{}) == {0x0a, 1}
  end
end
