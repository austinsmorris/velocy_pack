defmodule VelocyPack.Encoder.AtomTest do
  use ExUnit.Case, async: true

  alias VelocyPack.Encoder

  test "encode/2 nil" do
    assert Encoder.encode(nil) === 0x18
  end

  test "encode/2 false" do
    assert Encoder.encode(false) === 0x19
  end

  test "encode/2 true" do
    assert Encoder.encode(true) === 0x1A
  end

  test "encode/2 atom nil" do
    assert Encoder.encode(:nil) === 0x18
  end

  test "encode/2 atom false" do
    assert Encoder.encode(:false) === 0x19
  end

  test "encode/2 atom true" do
    assert Encoder.encode(:true) === 0x1A
  end

  test "encode/2 an atom" do
    assert Encoder.encode(:foo) === Encoder.encode("foo")
  end

  test "encode_with_size/2 nil" do
    assert Encoder.encode_with_size(nil) === {0x18, 1}
  end

  test "encode_with_size/2 false" do
    assert Encoder.encode_with_size(false) === {0x19, 1}
  end

  test "encode_with_size/2 true" do
    assert Encoder.encode_with_size(true) === {0x1A, 1}
  end

  test "encode_with_size/2 atom nil" do
    assert Encoder.encode_with_size(:nil) === {0x18, 1}
  end

  test "encode_with_size/2 atom false" do
    assert Encoder.encode_with_size(:false) === {0x19, 1}
  end

  test "encode_with_size/2 atom true" do
    assert Encoder.encode_with_size(:true) === {0x1A, 1}
  end

  test "encode_with_size/2 an atom" do
    assert Encoder.encode_with_size(:foo) === Encoder.encode_with_size("foo")
  end
end
