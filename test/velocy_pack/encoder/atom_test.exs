defmodule VelocyPack.Encoder.AtomTest do
  alias VelocyPack.Encoder

  use ExUnit.Case, async: true

  test "encode() nil" do
    assert Encoder.encode(nil) == [0x18]
    assert Encoder.encode(:nil) == [0x18]
  end

  test "encode() false" do
    assert Encoder.encode(false) == [0x19]
    assert Encoder.encode(:false) == [0x19]
  end

  test "encode() true" do
    assert Encoder.encode(true) == [0x1a]
    assert Encoder.encode(:true) == [0x1a]
  end

  test "encode_with_size() nil" do
    assert Encoder.encode_with_size(nil) == {0x18, 1}
    assert Encoder.encode_with_size(:nil) == {0x18, 1}
  end

  test "encode_with_size() false" do
    assert Encoder.encode_with_size(false) == {0x19, 1}
    assert Encoder.encode_with_size(:false) == {0x19, 1}
  end

  test "encode_with_size() true" do
    assert Encoder.encode_with_size(true) == {0x1a, 1}
    assert Encoder.encode_with_size(:true) == {0x1a, 1}
  end
end
