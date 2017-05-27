defmodule VelocyPack.Encoder.IntegerTest do
  alias VelocyPack.Encoder
  use ExUnit.Case, async: true

  test "encode() small positive integers" do
    assert Encoder.encode(0) == 0x30
    assert Encoder.encode(1) == 0x31
    assert Encoder.encode(2) == 0x32
    assert Encoder.encode(3) == 0x33
    assert Encoder.encode(4) == 0x34
    assert Encoder.encode(5) == 0x35
    assert Encoder.encode(6) == 0x36
    assert Encoder.encode(7) == 0x37
    assert Encoder.encode(8) == 0x38
    assert Encoder.encode(9) == 0x39
  end

  test "encode() small negative integers" do
    assert Encoder.encode(-6) == 0x3a
    assert Encoder.encode(-5) == 0x3b
    assert Encoder.encode(-4) == 0x3c
    assert Encoder.encode(-3) == 0x3d
    assert Encoder.encode(-2) == 0x3e
    assert Encoder.encode(-1) == 0x3f
  end

  test "encode() signed integers" do
    assert Encoder.encode(-7) == <<0x20, 249>>
    assert Encoder.encode(-128) == <<0x20, 128>>

    assert Encoder.encode(-129) == <<0x21, 127, 255>>
    assert Encoder.encode(-32_768) == <<0x21, 0, 128>>

    assert Encoder.encode(-32_769) == <<0x22, 255, 127, 255>>
    assert Encoder.encode(-8_388_608) == <<0x22, 0, 0, 128>>

    assert Encoder.encode(-8_388_609) == <<0x23, 255, 255, 127, 255>>
    assert Encoder.encode(-2_147_483_648) == <<0x23, 0, 0, 0, 128>>

    assert Encoder.encode(-2_147_483_649) == <<0x24, 255, 255, 255, 127, 255>>
    assert Encoder.encode(-549_755_813_888) == <<0x24, 0, 0, 0, 0, 128>>

    assert Encoder.encode(-549_755_813_889) == <<0x25, 255, 255, 255, 255, 127, 255>>
    assert Encoder.encode(-140_737_488_355_328) == <<0x25, 0, 0, 0, 0, 0, 128>>

    assert Encoder.encode(-140_737_488_355_329) == <<0x26, 255, 255, 255, 255, 255, 127, 255>>
    assert Encoder.encode(-36_028_797_018_963_968) == <<0x26, 0, 0, 0, 0, 0, 0, 128>>

    assert Encoder.encode(-36_028_797_018_963_969) == <<0x27, 255, 255, 255, 255, 255, 255, 127, 255>>
    assert Encoder.encode(-9_223_372_036_854_775_808) == <<0x27, 0, 0, 0, 0, 0, 0, 0, 128>>

    assert_raise(RuntimeError, "Cannot encode integers less than -9_223_372_036_854_775_808.", fn ->
      Encoder.encode(-9_223_372_036_854_775_809)
    end)
  end

  test "encode() unsigned integers" do
    assert Encoder.encode(10) == <<0x28, 10>>
    assert Encoder.encode(255) == <<0x28, 255>>

    assert Encoder.encode(256) == <<0x29, 0, 1>>
    assert Encoder.encode(65_535) == <<0x29, 255, 255>>

    assert Encoder.encode(65_536) == <<0x2a, 0, 0, 1>>
    assert Encoder.encode(16_777_215) == <<0x2a, 255, 255, 255>>

    assert Encoder.encode(16_777_216) == <<0x2b, 0, 0, 0, 1>>
    assert Encoder.encode(4_294_967_295) == <<0x2b, 255, 255, 255, 255>>

    assert Encoder.encode(4_294_967_296) == <<0x2c, 0, 0, 0, 0, 1>>
    assert Encoder.encode(1_099_511_627_775) == <<0x2c, 255, 255, 255, 255, 255>>

    assert Encoder.encode(1_099_511_627_776) == <<0x2d, 0, 0, 0, 0, 0, 1>>
    assert Encoder.encode(281_474_976_710_655) == <<0x2d, 255, 255, 255, 255, 255, 255>>

    assert Encoder.encode(281_474_976_710_656) == <<0x2e, 0, 0, 0, 0, 0, 0, 1>>
    assert Encoder.encode(72_057_594_037_927_935) == <<0x2e, 255, 255, 255, 255, 255, 255, 255>>

    assert Encoder.encode(72_057_594_037_927_936) == <<0x2f, 0, 0, 0, 0, 0, 0, 0, 1>>
    assert Encoder.encode(18_446_744_073_709_551_615) == <<0x2f, 255, 255, 255, 255, 255, 255, 255, 255>>

    assert_raise(RuntimeError, "Cannot encode integers greater than 18_446_744_073_709_551_615.", fn ->
      Encoder.encode(18_446_744_073_709_551_616)
    end)
  end

  test "encode_with_size() small positive integers" do
    assert Encoder.encode_with_size(0) == {0x30, 1}
    assert Encoder.encode_with_size(1) == {0x31, 1}
    assert Encoder.encode_with_size(2) == {0x32, 1}
    assert Encoder.encode_with_size(3) == {0x33, 1}
    assert Encoder.encode_with_size(4) == {0x34, 1}
    assert Encoder.encode_with_size(5) == {0x35, 1}
    assert Encoder.encode_with_size(6) == {0x36, 1}
    assert Encoder.encode_with_size(7) == {0x37, 1}
    assert Encoder.encode_with_size(8) == {0x38, 1}
    assert Encoder.encode_with_size(9) == {0x39, 1}
  end

  test "encode_with_size() small negative integers" do
    assert Encoder.encode_with_size(-6) == {0x3a, 1}
    assert Encoder.encode_with_size(-5) == {0x3b, 1}
    assert Encoder.encode_with_size(-4) == {0x3c, 1}
    assert Encoder.encode_with_size(-3) == {0x3d, 1}
    assert Encoder.encode_with_size(-2) == {0x3e, 1}
    assert Encoder.encode_with_size(-1) == {0x3f, 1}
  end

  test "encode_with_size() signed integers" do
    assert Encoder.encode_with_size(-7) == {<<0x20, 249>>, 2}
    assert Encoder.encode_with_size(-128) == {<<0x20, 128>>, 2}

    assert Encoder.encode_with_size(-129) == {<<0x21, 127, 255>>, 3}
    assert Encoder.encode_with_size(-32_768) == {<<0x21, 0, 128>>, 3}

    assert Encoder.encode_with_size(-32_769) == {<<0x22, 255, 127, 255>>, 4}
    assert Encoder.encode_with_size(-8_388_608) == {<<0x22, 0, 0, 128>>, 4}

    assert Encoder.encode_with_size(-8_388_609) == {<<0x23, 255, 255, 127, 255>>, 5}
    assert Encoder.encode_with_size(-2_147_483_648) == {<<0x23, 0, 0, 0, 128>>, 5}

    assert Encoder.encode_with_size(-2_147_483_649) == {<<0x24, 255, 255, 255, 127, 255>>, 6}
    assert Encoder.encode_with_size(-549_755_813_888) == {<<0x24, 0, 0, 0, 0, 128>>, 6}

    assert Encoder.encode_with_size(-549_755_813_889) == {<<0x25, 255, 255, 255, 255, 127, 255>>, 7}
    assert Encoder.encode_with_size(-140_737_488_355_328) == {<<0x25, 0, 0, 0, 0, 0, 128>>, 7}

    assert Encoder.encode_with_size(-140_737_488_355_329) == {<<0x26, 255, 255, 255, 255, 255, 127, 255>>, 8}
    assert Encoder.encode_with_size(-36_028_797_018_963_968) == {<<0x26, 0, 0, 0, 0, 0, 0, 128>>, 8}

    assert Encoder.encode_with_size(-36_028_797_018_963_969) == {<<0x27, 255, 255, 255, 255, 255, 255, 127, 255>>, 9}
    assert Encoder.encode_with_size(-9_223_372_036_854_775_808) == {<<0x27, 0, 0, 0, 0, 0, 0, 0, 128>>, 9}

    assert_raise(RuntimeError, "Cannot encode integers less than -9_223_372_036_854_775_808.", fn ->
      Encoder.encode_with_size(-9_223_372_036_854_775_809)
    end)
  end

  test "encode_with_size() unsigned integers" do
    assert Encoder.encode_with_size(10) == {<<0x28, 10>>, 2}
    assert Encoder.encode_with_size(255) == {<<0x28, 255>>, 2}

    assert Encoder.encode_with_size(256) == {<<0x29, 0, 1>>, 3}
    assert Encoder.encode_with_size(65_535) == {<<0x29, 255, 255>>, 3}

    assert Encoder.encode_with_size(65_536) == {<<0x2a, 0, 0, 1>>, 4}
    assert Encoder.encode_with_size(16_777_215) == {<<0x2a, 255, 255, 255>>, 4}

    assert Encoder.encode_with_size(16_777_216) == {<<0x2b, 0, 0, 0, 1>>, 5}
    assert Encoder.encode_with_size(4_294_967_295) == {<<0x2b, 255, 255, 255, 255>>, 5}

    assert Encoder.encode_with_size(4_294_967_296) == {<<0x2c, 0, 0, 0, 0, 1>>, 6}
    assert Encoder.encode_with_size(1_099_511_627_775) == {<<0x2c, 255, 255, 255, 255, 255>>, 6}

    assert Encoder.encode_with_size(1_099_511_627_776) == {<<0x2d, 0, 0, 0, 0, 0, 1>>, 7}
    assert Encoder.encode_with_size(281_474_976_710_655) == {<<0x2d, 255, 255, 255, 255, 255, 255>>, 7}

    assert Encoder.encode_with_size(281_474_976_710_656) == {<<0x2e, 0, 0, 0, 0, 0, 0, 1>>, 8}
    assert Encoder.encode_with_size(72_057_594_037_927_935) == {<<0x2e, 255, 255, 255, 255, 255, 255, 255>>, 8}

    assert Encoder.encode_with_size(72_057_594_037_927_936) == {<<0x2f, 0, 0, 0, 0, 0, 0, 0, 1>>, 9}
    assert Encoder.encode_with_size(18_446_744_073_709_551_615) == {<<0x2f, 255, 255, 255, 255, 255, 255, 255, 255>>, 9}

    assert_raise(RuntimeError, "Cannot encode integers greater than 18_446_744_073_709_551_615.", fn ->
      Encoder.encode_with_size(18_446_744_073_709_551_616)
    end)
  end
end
