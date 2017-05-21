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

  test "encode signed integers" do
    assert VelocyPack.encode(-7) == <<0x20, 249>>
    assert VelocyPack.encode(-128) == <<0x20, 128>>

    assert VelocyPack.encode(-129) == <<0x21, 127, 255>>
    assert VelocyPack.encode(-32_768) == <<0x21, 0, 128>>

    assert VelocyPack.encode(-32_769) == <<0x22, 255, 127, 255>>
    assert VelocyPack.encode(-8_388_608) == <<0x22, 0, 0, 128>>

    assert VelocyPack.encode(-8_388_609) == <<0x23, 255, 255, 127, 255>>
    assert VelocyPack.encode(-2_147_483_648) == <<0x23, 0, 0, 0, 128>>

    assert VelocyPack.encode(-2_147_483_649) == <<0x24, 255, 255, 255, 127, 255>>
    assert VelocyPack.encode(-549_755_813_888) == <<0x24, 0, 0, 0, 0, 128>>

    assert VelocyPack.encode(-549_755_813_889) == <<0x25, 255, 255, 255, 255, 127, 255>>
    assert VelocyPack.encode(-140_737_488_355_328) == <<0x25, 0, 0, 0, 0, 0, 128>>

    assert VelocyPack.encode(-140_737_488_355_329) == <<0x26, 255, 255, 255, 255, 255, 127, 255>>
    assert VelocyPack.encode(-36_028_797_018_963_968) == <<0x26, 0, 0, 0, 0, 0, 0, 128>>

    assert VelocyPack.encode(-36_028_797_018_963_969) == <<0x27, 255, 255, 255, 255, 255, 255, 127, 255>>
    assert VelocyPack.encode(-9_223_372_036_854_775_808) == <<0x27, 0, 0, 0, 0, 0, 0, 0, 128>>

    assert_raise(RuntimeError, "Cannot encode integers less than -9_223_372_036_854_775_808.", fn ->
      VelocyPack.encode(-9_223_372_036_854_775_809)
    end)
  end

  test "encode unsigned integers" do
    assert VelocyPack.encode(10) == <<0x28, 10>>
    assert VelocyPack.encode(255) == <<0x28, 255>>

    assert VelocyPack.encode(256) == <<0x29, 0, 1>>
    assert VelocyPack.encode(65_535) == <<0x29, 255, 255>>

    assert VelocyPack.encode(65_536) == <<0x2a, 0, 0, 1>>
    assert VelocyPack.encode(16_777_215) == <<0x2a, 255, 255, 255>>

    assert VelocyPack.encode(16_777_216) == <<0x2b, 0, 0, 0, 1>>
    assert VelocyPack.encode(4_294_967_295) == <<0x2b, 255, 255, 255, 255>>

    assert VelocyPack.encode(4_294_967_296) == <<0x2c, 0, 0, 0, 0, 1>>
    assert VelocyPack.encode(1_099_511_627_775) == <<0x2c, 255, 255, 255, 255, 255>>

    assert VelocyPack.encode(1_099_511_627_776) == <<0x2d, 0, 0, 0, 0, 0, 1>>
    assert VelocyPack.encode(281_474_976_710_655) == <<0x2d, 255, 255, 255, 255, 255, 255>>

    assert VelocyPack.encode(281_474_976_710_656) == <<0x2e, 0, 0, 0, 0, 0, 0, 1>>
    assert VelocyPack.encode(72_057_594_037_927_935) == <<0x2e, 255, 255, 255, 255, 255, 255, 255>>

    assert VelocyPack.encode(72_057_594_037_927_936) == <<0x2f, 0, 0, 0, 0, 0, 0, 0, 1>>
    assert VelocyPack.encode(18_446_744_073_709_551_615) == <<0x2f, 255, 255, 255, 255, 255, 255, 255, 255>>

    assert_raise(RuntimeError, "Cannot encode integers greater than 18_446_744_073_709_551_615.", fn ->
      VelocyPack.encode(18_446_744_073_709_551_616)
    end)
  end
end
