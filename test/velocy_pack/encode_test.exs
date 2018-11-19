defmodule VelocyPack.EncodeTest do
  use ExUnit.Case, async: true

  alias VelocyPack.Encode

  describe "encode/2" do
    test "encodes an empty list" do
      {:ok, encoded} = Encode.encode([])
      assert encoded === 0x01
    end

    test "encodes list when items are variable size" do
      {:ok, encoded} = Encode.encode([1, "a", 10])
      assert encoded === [0x06, <<0x0B>>, <<0x03>>, [0x31, <<0x41, 0x61>>, <<0x28, 0x0A>>], [0x03, 0x04, 0x06]]
    end

    test "encodes an empty map" do
      {:ok, encoded} = Encode.encode(%{})
      assert encoded === 0x0A
    end

    test "encodes nil" do
      {:ok, encoded} = Encode.encode(nil)
      assert encoded === 0x18
    end

    test "encodes false" do
      {:ok, encoded} = Encode.encode(false)
      assert encoded === 0x19
    end

    test "encodes true" do
      {:ok, encoded} = Encode.encode(true)
      assert encoded === 0x1A
    end

    test "encodes small positive integers" do
      assert Encode.encode(0) === {:ok, 0x30}
      assert Encode.encode(1) === {:ok, 0x31}
      assert Encode.encode(2) === {:ok, 0x32}
      assert Encode.encode(3) === {:ok, 0x33}
      assert Encode.encode(4) === {:ok, 0x34}
      assert Encode.encode(5) === {:ok, 0x35}
      assert Encode.encode(6) === {:ok, 0x36}
      assert Encode.encode(7) === {:ok, 0x37}
      assert Encode.encode(8) === {:ok, 0x38}
      assert Encode.encode(9) === {:ok, 0x39}
    end

    test "encodes small negative integers" do
      assert Encode.encode(-6) === {:ok, 0x3A}
      assert Encode.encode(-5) === {:ok, 0x3B}
      assert Encode.encode(-4) === {:ok, 0x3C}
      assert Encode.encode(-3) === {:ok, 0x3D}
      assert Encode.encode(-2) === {:ok, 0x3E}
      assert Encode.encode(-1) === {:ok, 0x3F}
    end

    test "encodes signed integers" do
      assert Encode.encode(-7) === {:ok, <<0x20, 249>>}
      assert Encode.encode(-128) === {:ok, <<0x20, 128>>}

      assert Encode.encode(-129) === {:ok, <<0x21, 127, 255>>}
      assert Encode.encode(-32_768) === {:ok, <<0x21, 0, 128>>}

      assert Encode.encode(-32_769) === {:ok, <<0x22, 255, 127, 255>>}
      assert Encode.encode(-8_388_608) === {:ok, <<0x22, 0, 0, 128>>}

      assert Encode.encode(-8_388_609) === {:ok, <<0x23, 255, 255, 127, 255>>}
      assert Encode.encode(-2_147_483_648) === {:ok, <<0x23, 0, 0, 0, 128>>}

      assert Encode.encode(-2_147_483_649) === {:ok, <<0x24, 255, 255, 255, 127, 255>>}
      assert Encode.encode(-549_755_813_888) === {:ok, <<0x24, 0, 0, 0, 0, 128>>}

      assert Encode.encode(-549_755_813_889) === {:ok, <<0x25, 255, 255, 255, 255, 127, 255>>}
      assert Encode.encode(-140_737_488_355_328) === {:ok, <<0x25, 0, 0, 0, 0, 0, 128>>}

      assert Encode.encode(-140_737_488_355_329) === {:ok, <<0x26, 255, 255, 255, 255, 255, 127, 255>>}
      assert Encode.encode(-36_028_797_018_963_968) === {:ok, <<0x26, 0, 0, 0, 0, 0, 0, 128>>}

      assert Encode.encode(-36_028_797_018_963_969) === {:ok, <<0x27, 255, 255, 255, 255, 255, 255, 127, 255>>}
      assert Encode.encode(-9_223_372_036_854_775_808) === {:ok, <<0x27, 0, 0, 0, 0, 0, 0, 0, 128>>}

      assert_raise(RuntimeError, "Cannot encode integers less than -9_223_372_036_854_775_808.", fn ->
        Encode.encode(-9_223_372_036_854_775_809)
      end)
    end

    test "encodes unsigned integers" do
      assert Encode.encode(10) === {:ok, <<0x28, 10>>}
      assert Encode.encode(255) === {:ok, <<0x28, 255>>}

      assert Encode.encode(256) === {:ok, <<0x29, 0, 1>>}
      assert Encode.encode(65_535) === {:ok, <<0x29, 255, 255>>}

      assert Encode.encode(65_536) === {:ok, <<0x2A, 0, 0, 1>>}
      assert Encode.encode(16_777_215) === {:ok, <<0x2A, 255, 255, 255>>}

      assert Encode.encode(16_777_216) === {:ok, <<0x2B, 0, 0, 0, 1>>}
      assert Encode.encode(4_294_967_295) === {:ok, <<0x2B, 255, 255, 255, 255>>}

      assert Encode.encode(4_294_967_296) === {:ok, <<0x2C, 0, 0, 0, 0, 1>>}
      assert Encode.encode(1_099_511_627_775) === {:ok, <<0x2C, 255, 255, 255, 255, 255>>}

      assert Encode.encode(1_099_511_627_776) === {:ok, <<0x2D, 0, 0, 0, 0, 0, 1>>}
      assert Encode.encode(281_474_976_710_655) === {:ok, <<0x2D, 255, 255, 255, 255, 255, 255>>}

      assert Encode.encode(281_474_976_710_656) === {:ok, <<0x2E, 0, 0, 0, 0, 0, 0, 1>>}
      assert Encode.encode(72_057_594_037_927_935) === {:ok, <<0x2E, 255, 255, 255, 255, 255, 255, 255>>}

      assert Encode.encode(72_057_594_037_927_936) === {:ok, <<0x2F, 0, 0, 0, 0, 0, 0, 0, 1>>}
      assert Encode.encode(18_446_744_073_709_551_615) === {:ok, <<0x2F, 255, 255, 255, 255, 255, 255, 255, 255>>}

      assert_raise(RuntimeError, "Cannot encode integers greater than 18_446_744_073_709_551_615.", fn ->
        Encode.encode(18_446_744_073_709_551_616)
      end)
    end

    test "encodes empty bit string" do
      assert Encode.encode(<<>>) === {:ok, 0x40}
    end

    test "encodes empty string" do
      assert Encode.encode("") === {:ok, 0x40}
    end

    test "encodes a short string" do
      assert Encode.encode("a") === {:ok, <<0x41, "a">>}
      assert Encode.encode("foo") === {:ok, <<0x43, "foo">>}

      string =
        "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdfasdflkajsdflkjas" <>
          "dfasdfasdfasdfasdfalka"

      assert Encode.encode(string) === {:ok, <<0xBE, string::binary>>}
    end

    test "encodes a long string" do
      value =
        "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkj" <>
          "asdflkajsdflkjasdflkjasdlksjadflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasd"

      {:ok, <<indicator, size::little-unsigned-size(64), string::binary>>} = Encode.encode(value)

      assert indicator === 0xBF
      assert size === byte_size(value)
      assert string === value
    end
  end

  describe "encode_atom/1" do
    test "encodes nil" do
      encoded = Encode.encode_atom(nil)
      assert encoded === 0x18
    end

    test "encodes false" do
      encoded = Encode.encode_atom(false)
      assert encoded === 0x19
    end

    test "encodes true" do
      encoded = Encode.encode_atom(true)
      assert encoded === 0x1A
    end

    test "encodes atom nil" do
      encoded = Encode.encode_atom(nil)
      assert encoded === 0x18
    end

    test "encodes atom false" do
      encoded = Encode.encode_atom(false)
      assert encoded === 0x19
    end

    test "encodes atom true" do
      encoded = Encode.encode_atom(true)
      assert encoded === 0x1A
    end
  end

  describe "encode_atom_with_size/1" do
    test "encodes nil" do
      encoded = Encode.encode_atom_with_size(nil)
      assert encoded === {0x18, 1}
    end

    test "encodes false" do
      encoded = Encode.encode_atom_with_size(false)
      assert encoded === {0x19, 1}
    end

    test "encodes true" do
      encoded = Encode.encode_atom_with_size(true)
      assert encoded === {0x1A, 1}
    end

    test "encodes atom nil" do
      encoded = Encode.encode_atom_with_size(nil)
      assert encoded === {0x18, 1}
    end

    test "encodes atom false" do
      encoded = Encode.encode_atom_with_size(false)
      assert encoded === {0x19, 1}
    end

    test "encodes atom true" do
      encoded = Encode.encode_atom_with_size(true)
      assert encoded === {0x1A, 1}
    end
  end

  describe "encode_integer/1" do
    test "encodes small positive integers" do
      assert Encode.encode_integer(0) === 0x30
      assert Encode.encode_integer(1) === 0x31
      assert Encode.encode_integer(2) === 0x32
      assert Encode.encode_integer(3) === 0x33
      assert Encode.encode_integer(4) === 0x34
      assert Encode.encode_integer(5) === 0x35
      assert Encode.encode_integer(6) === 0x36
      assert Encode.encode_integer(7) === 0x37
      assert Encode.encode_integer(8) === 0x38
      assert Encode.encode_integer(9) === 0x39
    end

    test "encodes small negative integers" do
      assert Encode.encode_integer(-6) === 0x3A
      assert Encode.encode_integer(-5) === 0x3B
      assert Encode.encode_integer(-4) === 0x3C
      assert Encode.encode_integer(-3) === 0x3D
      assert Encode.encode_integer(-2) === 0x3E
      assert Encode.encode_integer(-1) === 0x3F
    end

    test "encodes signed integers" do
      assert Encode.encode_integer(-7) === <<0x20, 249>>
      assert Encode.encode_integer(-128) === <<0x20, 128>>

      assert Encode.encode_integer(-129) === <<0x21, 127, 255>>
      assert Encode.encode_integer(-32_768) === <<0x21, 0, 128>>

      assert Encode.encode_integer(-32_769) === <<0x22, 255, 127, 255>>
      assert Encode.encode_integer(-8_388_608) === <<0x22, 0, 0, 128>>

      assert Encode.encode_integer(-8_388_609) === <<0x23, 255, 255, 127, 255>>
      assert Encode.encode_integer(-2_147_483_648) === <<0x23, 0, 0, 0, 128>>

      assert Encode.encode_integer(-2_147_483_649) === <<0x24, 255, 255, 255, 127, 255>>
      assert Encode.encode_integer(-549_755_813_888) === <<0x24, 0, 0, 0, 0, 128>>

      assert Encode.encode_integer(-549_755_813_889) === <<0x25, 255, 255, 255, 255, 127, 255>>
      assert Encode.encode_integer(-140_737_488_355_328) === <<0x25, 0, 0, 0, 0, 0, 128>>

      assert Encode.encode_integer(-140_737_488_355_329) === <<0x26, 255, 255, 255, 255, 255, 127, 255>>
      assert Encode.encode_integer(-36_028_797_018_963_968) === <<0x26, 0, 0, 0, 0, 0, 0, 128>>

      assert Encode.encode_integer(-36_028_797_018_963_969) === <<0x27, 255, 255, 255, 255, 255, 255, 127, 255>>
      assert Encode.encode_integer(-9_223_372_036_854_775_808) === <<0x27, 0, 0, 0, 0, 0, 0, 0, 128>>

      assert_raise(RuntimeError, "Cannot encode integers less than -9_223_372_036_854_775_808.", fn ->
        Encode.encode_integer(-9_223_372_036_854_775_809)
      end)
    end

    test "encodes unsigned integers" do
      assert Encode.encode_integer(10) === <<0x28, 10>>
      assert Encode.encode_integer(255) === <<0x28, 255>>

      assert Encode.encode_integer(256) === <<0x29, 0, 1>>
      assert Encode.encode_integer(65_535) === <<0x29, 255, 255>>

      assert Encode.encode_integer(65_536) === <<0x2A, 0, 0, 1>>
      assert Encode.encode_integer(16_777_215) === <<0x2A, 255, 255, 255>>

      assert Encode.encode_integer(16_777_216) === <<0x2B, 0, 0, 0, 1>>
      assert Encode.encode_integer(4_294_967_295) === <<0x2B, 255, 255, 255, 255>>

      assert Encode.encode_integer(4_294_967_296) === <<0x2C, 0, 0, 0, 0, 1>>
      assert Encode.encode_integer(1_099_511_627_775) === <<0x2C, 255, 255, 255, 255, 255>>

      assert Encode.encode_integer(1_099_511_627_776) === <<0x2D, 0, 0, 0, 0, 0, 1>>
      assert Encode.encode_integer(281_474_976_710_655) === <<0x2D, 255, 255, 255, 255, 255, 255>>

      assert Encode.encode_integer(281_474_976_710_656) === <<0x2E, 0, 0, 0, 0, 0, 0, 1>>
      assert Encode.encode_integer(72_057_594_037_927_935) === <<0x2E, 255, 255, 255, 255, 255, 255, 255>>

      assert Encode.encode_integer(72_057_594_037_927_936) === <<0x2F, 0, 0, 0, 0, 0, 0, 0, 1>>
      assert Encode.encode_integer(18_446_744_073_709_551_615) === <<0x2F, 255, 255, 255, 255, 255, 255, 255, 255>>

      assert_raise(RuntimeError, "Cannot encode integers greater than 18_446_744_073_709_551_615.", fn ->
        Encode.encode_integer(18_446_744_073_709_551_616)
      end)
    end
  end

  describe "encode_integer_with_size/1" do
    test "encodes small positive integers" do
      assert Encode.encode_integer_with_size(0) === {0x30, 1}
      assert Encode.encode_integer_with_size(1) === {0x31, 1}
      assert Encode.encode_integer_with_size(2) === {0x32, 1}
      assert Encode.encode_integer_with_size(3) === {0x33, 1}
      assert Encode.encode_integer_with_size(4) === {0x34, 1}
      assert Encode.encode_integer_with_size(5) === {0x35, 1}
      assert Encode.encode_integer_with_size(6) === {0x36, 1}
      assert Encode.encode_integer_with_size(7) === {0x37, 1}
      assert Encode.encode_integer_with_size(8) === {0x38, 1}
      assert Encode.encode_integer_with_size(9) === {0x39, 1}
    end

    test "encodes small negative integers" do
      assert Encode.encode_integer_with_size(-6) === {0x3A, 1}
      assert Encode.encode_integer_with_size(-5) === {0x3B, 1}
      assert Encode.encode_integer_with_size(-4) === {0x3C, 1}
      assert Encode.encode_integer_with_size(-3) === {0x3D, 1}
      assert Encode.encode_integer_with_size(-2) === {0x3E, 1}
      assert Encode.encode_integer_with_size(-1) === {0x3F, 1}
    end

    test "encodes signed integers" do
      assert Encode.encode_integer_with_size(-7) === {<<0x20, 249>>, 2}
      assert Encode.encode_integer_with_size(-128) === {<<0x20, 128>>, 2}

      assert Encode.encode_integer_with_size(-129) === {<<0x21, 127, 255>>, 3}
      assert Encode.encode_integer_with_size(-32_768) === {<<0x21, 0, 128>>, 3}

      assert Encode.encode_integer_with_size(-32_769) === {<<0x22, 255, 127, 255>>, 4}
      assert Encode.encode_integer_with_size(-8_388_608) === {<<0x22, 0, 0, 128>>, 4}

      assert Encode.encode_integer_with_size(-8_388_609) === {<<0x23, 255, 255, 127, 255>>, 5}
      assert Encode.encode_integer_with_size(-2_147_483_648) === {<<0x23, 0, 0, 0, 128>>, 5}

      assert Encode.encode_integer_with_size(-2_147_483_649) === {<<0x24, 255, 255, 255, 127, 255>>, 6}
      assert Encode.encode_integer_with_size(-549_755_813_888) === {<<0x24, 0, 0, 0, 0, 128>>, 6}

      assert Encode.encode_integer_with_size(-549_755_813_889) === {<<0x25, 255, 255, 255, 255, 127, 255>>, 7}
      assert Encode.encode_integer_with_size(-140_737_488_355_328) === {<<0x25, 0, 0, 0, 0, 0, 128>>, 7}

      assert Encode.encode_integer_with_size(-140_737_488_355_329) === {<<0x26, 255, 255, 255, 255, 255, 127, 255>>, 8}
      assert Encode.encode_integer_with_size(-36_028_797_018_963_968) === {<<0x26, 0, 0, 0, 0, 0, 0, 128>>, 8}

      assert Encode.encode_integer_with_size(-36_028_797_018_963_969) ===
               {<<0x27, 255, 255, 255, 255, 255, 255, 127, 255>>, 9}

      assert Encode.encode_integer_with_size(-9_223_372_036_854_775_808) === {<<0x27, 0, 0, 0, 0, 0, 0, 0, 128>>, 9}

      assert_raise(RuntimeError, "Cannot encode integers less than -9_223_372_036_854_775_808.", fn ->
        Encode.encode_integer_with_size(-9_223_372_036_854_775_809)
      end)
    end

    test "encodes unsigned integers" do
      assert Encode.encode_integer_with_size(10) === {<<0x28, 10>>, 2}
      assert Encode.encode_integer_with_size(255) === {<<0x28, 255>>, 2}

      assert Encode.encode_integer_with_size(256) === {<<0x29, 0, 1>>, 3}
      assert Encode.encode_integer_with_size(65_535) === {<<0x29, 255, 255>>, 3}

      assert Encode.encode_integer_with_size(65_536) === {<<0x2A, 0, 0, 1>>, 4}
      assert Encode.encode_integer_with_size(16_777_215) === {<<0x2A, 255, 255, 255>>, 4}

      assert Encode.encode_integer_with_size(16_777_216) === {<<0x2B, 0, 0, 0, 1>>, 5}
      assert Encode.encode_integer_with_size(4_294_967_295) === {<<0x2B, 255, 255, 255, 255>>, 5}

      assert Encode.encode_integer_with_size(4_294_967_296) === {<<0x2C, 0, 0, 0, 0, 1>>, 6}
      assert Encode.encode_integer_with_size(1_099_511_627_775) === {<<0x2C, 255, 255, 255, 255, 255>>, 6}

      assert Encode.encode_integer_with_size(1_099_511_627_776) === {<<0x2D, 0, 0, 0, 0, 0, 1>>, 7}
      assert Encode.encode_integer_with_size(281_474_976_710_655) === {<<0x2D, 255, 255, 255, 255, 255, 255>>, 7}

      assert Encode.encode_integer_with_size(281_474_976_710_656) === {<<0x2E, 0, 0, 0, 0, 0, 0, 1>>, 8}

      assert Encode.encode_integer_with_size(72_057_594_037_927_935) ===
               {<<0x2E, 255, 255, 255, 255, 255, 255, 255>>, 8}

      assert Encode.encode_integer_with_size(72_057_594_037_927_936) === {<<0x2F, 0, 0, 0, 0, 0, 0, 0, 1>>, 9}

      assert Encode.encode_integer_with_size(18_446_744_073_709_551_615) ===
               {<<0x2F, 255, 255, 255, 255, 255, 255, 255, 255>>, 9}

      assert_raise(RuntimeError, "Cannot encode integers greater than 18_446_744_073_709_551_615.", fn ->
        Encode.encode_integer_with_size(18_446_744_073_709_551_616)
      end)
    end
  end

  describe "encode_string/1" do
    test "encodes empty bit string" do
      assert Encode.encode_string(<<>>) === 0x40
    end

    test "encodes empty string" do
      assert Encode.encode_string("") === 0x40
    end

    test "encodes a short string" do
      assert Encode.encode_string("a") === <<0x41, "a">>
      assert Encode.encode_string("foo") === <<0x43, "foo">>

      string =
        "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdfasdflkajsdflkjas" <>
          "dfasdfasdfasdfasdfalka"

      assert Encode.encode_string(string) === <<0xBE, string::binary>>
    end

    test "encodes a long string" do
      value =
        "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkj" <>
          "asdflkajsdflkjasdflkjasdlksjadflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasd"

      <<indicator, size::little-unsigned-size(64), string::binary>> = Encode.encode_string(value)

      assert indicator === 0xBF
      assert size === byte_size(value)
      assert string === value
    end
  end

  describe "encode_string_with_size/1" do
    test "encodes empty bit string" do
      assert Encode.encode_string_with_size(<<>>) === {0x40, 1}
    end

    test "encodes empty string" do
      assert Encode.encode_string_with_size("") === {0x40, 1}
    end

    test "encodes a short string" do
      assert Encode.encode_string_with_size("a") === {<<0x41, "a">>, 2}
      assert Encode.encode_string_with_size("foo") === {<<0x43, "foo">>, 4}

      string =
        "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdfasdflkajsdflkjas" <>
          "dfasdfasdfasdfasdfalka"

      assert Encode.encode_string_with_size(string) === {<<0xBE, string::binary>>, 127}
    end

    test "encodes a long string" do
      value =
        "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkj" <>
          "asdflkajsdflkjasdflkjasdlksjadflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasd"

      {<<indicator, size::little-unsigned-size(64), string::binary>>, encode_size} =
        Encode.encode_string_with_size(value)

      assert indicator === 0xBF
      assert size === byte_size(value)
      assert string === value
      assert encode_size === 221
    end
  end

  describe "encode_list/1" do
    test "encodes an empty list" do
      encoded = Encode.encode_list([])
      assert encoded === 0x01
    end

    test "encodes list when items are variable size" do
      encoded = Encode.encode_list([1, "a", 10])
      assert encoded === [0x06, <<0x0B>>, <<0x03>>, [0x31, <<0x41, 0x61>>, <<0x28, 0x0A>>], [0x03, 0x04, 0x06]]
    end
  end

  describe "encode_list_with_size/1" do
    test "encodes an empty list" do
      encoded = Encode.encode_list_with_size([])
      assert encoded === {0x01, 1}
    end

    test "encodes list when items are variable size" do
      encoded = Encode.encode_list_with_size([1, "a", 10])
      assert encoded === {[0x06, <<0x0B>>, <<0x03>>, [0x31, <<0x41, 0x61>>, <<0x28, 0x0A>>], [0x03, 0x04, 0x06]], 11}
    end
  end

  describe "encode_map/1" do
    test "encodes an empty map" do
      encoded = Encode.encode_map(%{})
      assert encoded === 0x0A
    end
  end

  describe "encode_map_with_size/1" do
    test "encodes an empty map" do
      encoded = Encode.encode_map_with_size(%{})
      assert encoded === {0x0A, 1}
    end
  end
end
