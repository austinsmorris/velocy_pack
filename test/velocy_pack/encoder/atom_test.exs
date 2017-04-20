defmodule VelocyPack.Encoder.AtomTest do
  use ExUnit.Case, async: true

  test "encode nil" do
    assert VelocyPack.encode(nil) == 0x18
    assert VelocyPack.encode(:nil) == 0x18
  end

  test "encode false" do
    assert VelocyPack.encode(false) == 0x19
    assert VelocyPack.encode(:false) == 0x19
  end

  test "encode true" do
    assert VelocyPack.encode(true) == 0x1a
    assert VelocyPack.encode(:true) == 0x1a
  end
end
