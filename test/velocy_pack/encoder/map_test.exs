defmodule VelocyPack.Encoder.MapTest do
  use ExUnit.Case, async: true

  alias VelocyPack.Encoder

  test "encode() with empty map" do
    assert Encoder.encode(%{}) == 0x0A
  end

  test "encode_with_size() with empty map" do
    assert Encoder.encode_with_size(%{}) == {0x0A, 1}
  end
end
