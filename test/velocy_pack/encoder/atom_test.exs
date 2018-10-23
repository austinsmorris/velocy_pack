defmodule VelocyPack.Encoder.AtomTest do
  use ExUnit.Case, async: true

  alias VelocyPack.Encoder

  test "encode() nil" do
    assert Encoder.encode(nil) === 0x18
  end

  test "encode() false" do
    assert Encoder.encode(false) === 0x19
  end

  test "encode() true" do
    assert Encoder.encode(true) === 0x1A
  end

  test "encode() an atom" do
    assert Encoder.encode(:foo) === Encoder.encode("foo")
  end

  test "encode_with_size() nil" do
    assert Encoder.encode_with_size(nil) === {0x18, 1}
  end

  test "encode_with_size() false" do
    assert Encoder.encode_with_size(false) === {0x19, 1}
  end

  test "encode_with_size() true" do
    assert Encoder.encode_with_size(true) === {0x1A, 1}
  end

  test "encode_with_size() an atom" do
    assert Encoder.encode_with_size(:foo) === Encoder.encode_with_size("foo")
  end
end
