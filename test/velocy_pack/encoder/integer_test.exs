defmodule VelocyPack.Encoder.IntegerTest do
  use ExUnit.Case, async: true

  test "encode small positive integers" do
    assert VelocyPack.encode(0) == 0x30
    assert VelocyPack.encode(1) == 0x31
    assert VelocyPack.encode(2) == 0x32
    assert VelocyPack.encode(3) == 0x33
    assert VelocyPack.encode(4) == 0x34
    assert VelocyPack.encode(5) == 0x35
    assert VelocyPack.encode(6) == 0x36
    assert VelocyPack.encode(7) == 0x37
    assert VelocyPack.encode(8) == 0x38
    assert VelocyPack.encode(9) == 0x39
  end

  test "encode small negative integers" do
    assert VelocyPack.encode(-6) == 0x3a
    assert VelocyPack.encode(-5) == 0x3b
    assert VelocyPack.encode(-4) == 0x3c
    assert VelocyPack.encode(-3) == 0x3d
    assert VelocyPack.encode(-2) == 0x3e
    assert VelocyPack.encode(-1) == 0x3f
  end
end
