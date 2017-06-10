defmodule VelocyPack.DecoderTest do
  alias VelocyPack.Decoder

  use ExUnit.Case, async: true

  test "decode() nil with tail" do
    assert Decoder.decode(<<0x18, 0>>) == {:ok, nil, <<0>>}
  end

  test "decode() nil without tail" do
    assert Decoder.decode(<<0x18>>) == {:ok, nil, ""}
  end

  test "decode() false with tail" do
    assert Decoder.decode(<<0x19, 0>>) == {:ok, false, <<0>>}
  end

  test "decode() false without tail" do
    assert Decoder.decode(<<0x19>>) == {:ok, false, ""}
  end

  test "decode() true with tail" do
    assert Decoder.decode(<<0x1a, 0>>) == {:ok, true, <<0>>}
  end

  test "decode() true without tail" do
    assert Decoder.decode(<<0x1a>>) == {:ok, true, ""}
  end

  test "decode() empty string with tail" do
    assert Decoder.decode(<<0x40, 0>>) == {:ok, "", <<0>>}
  end

  test "decode() empty string without tail" do
    assert Decoder.decode(<<0x40>>) == {:ok, "", ""}
  end

  test "decode() short string with tail" do
    assert Decoder.decode(<<0x41, "a", 0>>) == {:ok, "a", <<0>>}
    assert Decoder.decode(<<0x43, "foo", 0>>) == {:ok, "foo", <<0>>}

    string = "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdfasdflkajsdflkjas"
      <> "dfasdfasdfasdfasdfalka"
    assert Decoder.decode(<<0xbe, string::binary, 0>>) == {:ok, string, <<0>>}
  end

  test "decode() short string without tail" do
    assert Decoder.decode(<<0x41, "a">>) == {:ok, "a", ""}
    assert Decoder.decode(<<0x43, "foo">>) == {:ok, "foo", ""}

    string = "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdfasdflkajsdflkjas"
      <> "dfasdfasdfasdfasdfalka"
    assert Decoder.decode(<<0xbe, string::binary>>) == {:ok, string, ""}
  end

  test "decode() long string with tail" do
    string = "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkj"
      <> "asdflkajsdflkjasdflkjasdlksjadflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasd"
    binary = <<0xbf, byte_size(string)::little-unsigned-size(64), string::binary, 0>>
    assert Decoder.decode(binary) == {:ok, string, <<0>>}
  end

  test "decode() long string without tail" do
    string = "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkj"
      <> "asdflkajsdflkjasdflkjasdlksjadflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasd"
    binary = <<0xbf, byte_size(string)::little-unsigned-size(64), string::binary>>
    assert Decoder.decode(binary) == {:ok, string, ""}
  end

  test "decode() small positive integers with tail" do
    assert Decoder.decode(<<0x30, 0>>) == {:ok, 0, <<0>>}
    assert Decoder.decode(<<0x31, 0>>) == {:ok, 1, <<0>>}
    assert Decoder.decode(<<0x32, 0>>) == {:ok, 2, <<0>>}
    assert Decoder.decode(<<0x33, 0>>) == {:ok, 3, <<0>>}
    assert Decoder.decode(<<0x34, 0>>) == {:ok, 4, <<0>>}
    assert Decoder.decode(<<0x35, 0>>) == {:ok, 5, <<0>>}
    assert Decoder.decode(<<0x36, 0>>) == {:ok, 6, <<0>>}
    assert Decoder.decode(<<0x37, 0>>) == {:ok, 7, <<0>>}
    assert Decoder.decode(<<0x38, 0>>) == {:ok, 8, <<0>>}
    assert Decoder.decode(<<0x39, 0>>) == {:ok, 9, <<0>>}
  end

  test "decode() small negative integers with tail" do
    assert Decoder.decode(<<0x3a, 0>>) == {:ok, -6, <<0>>}
    assert Decoder.decode(<<0x3b, 0>>) == {:ok, -5, <<0>>}
    assert Decoder.decode(<<0x3c, 0>>) == {:ok, -4, <<0>>}
    assert Decoder.decode(<<0x3d, 0>>) == {:ok, -3, <<0>>}
    assert Decoder.decode(<<0x3e, 0>>) == {:ok, -2, <<0>>}
    assert Decoder.decode(<<0x3f, 0>>) == {:ok, -1, <<0>>}
  end

  test "decode() signed integers with tail" do
    assert Decoder.decode(<<0x20, 249, 0>>) == {:ok, -7, <<0>>}
    assert Decoder.decode(<<0x20, 128, 0>>) == {:ok, -128, <<0>>}

    assert Decoder.decode(<<0x21, 127, 255, 0>>) == {:ok, -129, <<0>>}
    assert Decoder.decode(<<0x21, 0, 128, 0>>) == {:ok, -32_768, <<0>>}

    assert Decoder.decode(<<0x22, 255, 127, 255, 0>>) == {:ok, -32_769, <<0>>}
    assert Decoder.decode(<<0x22, 0, 0, 128, 0>>) == {:ok, -8_388_608, <<0>>}

    assert Decoder.decode(<<0x23, 255, 255, 127, 255, 0>>) == {:ok, -8_388_609, <<0>>}
    assert Decoder.decode(<<0x23, 0, 0, 0, 128, 0>>) == {:ok, -2_147_483_648, <<0>>}

    assert Decoder.decode(<<0x24, 255, 255, 255, 127, 255, 0>>) == {:ok, -2_147_483_649, <<0>>}
    assert Decoder.decode(<<0x24, 0, 0, 0, 0, 128, 0>>) == {:ok, -549_755_813_888, <<0>>}

    assert Decoder.decode(<<0x25, 255, 255, 255, 255, 127, 255, 0>>) == {:ok, -549_755_813_889, <<0>>}
    assert Decoder.decode(<<0x25, 0, 0, 0, 0, 0, 128, 0>>) == {:ok, -140_737_488_355_328, <<0>>}

    assert Decoder.decode(<<0x26, 255, 255, 255, 255, 255, 127, 255, 0>>) == {:ok, -140_737_488_355_329, <<0>>}
    assert Decoder.decode(<<0x26, 0, 0, 0, 0, 0, 0, 128, 0>>) == {:ok, -36_028_797_018_963_968, <<0>>}

    assert Decoder.decode(<<0x27, 255, 255, 255, 255, 255, 255, 127, 255, 0>>) == {:ok, -36_028_797_018_963_969, <<0>>}
    assert Decoder.decode(<<0x27, 0, 0, 0, 0, 0, 0, 0, 128, 0>>) == {:ok, -9_223_372_036_854_775_808, <<0>>}
  end

  test "decode() unsigned integers with tail" do
    assert Decoder.decode(<<0x28, 10, 0>>) == {:ok, 10, <<0>>}
    assert Decoder.decode(<<0x28, 255, 0>>) == {:ok, 255, <<0>>}

    assert Decoder.decode(<<0x29, 0, 1, 0>>) == {:ok, 256, <<0>>}
    assert Decoder.decode(<<0x29, 255, 255, 0>>) == {:ok, 65_535, <<0>>}

    assert Decoder.decode(<<0x2a, 0, 0, 1, 0>>) == {:ok, 65_536, <<0>>}
    assert Decoder.decode(<<0x2a, 255, 255, 255, 0>>) == {:ok, 16_777_215, <<0>>}

    assert Decoder.decode(<<0x2b, 0, 0, 0, 1, 0>>) == {:ok, 16_777_216, <<0>>}
    assert Decoder.decode(<<0x2b, 255, 255, 255, 255, 0>>) == {:ok, 4_294_967_295, <<0>>}

    assert Decoder.decode(<<0x2c, 0, 0, 0, 0, 1, 0>>) == {:ok, 4_294_967_296, <<0>>}
    assert Decoder.decode(<<0x2c, 255, 255, 255, 255, 255, 0>>) == {:ok, 1_099_511_627_775, <<0>>}

    assert Decoder.decode(<<0x2d, 0, 0, 0, 0, 0, 1, 0>>) == {:ok, 1_099_511_627_776, <<0>>}
    assert Decoder.decode(<<0x2d, 255, 255, 255, 255, 255, 255, 0>>) == {:ok, 281_474_976_710_655, <<0>>}

    assert Decoder.decode(<<0x2e, 0, 0, 0, 0, 0, 0, 1, 0>>) == {:ok, 281_474_976_710_656, <<0>>}
    assert Decoder.decode(<<0x2e, 255, 255, 255, 255, 255, 255, 255, 0>>) == {:ok, 72_057_594_037_927_935, <<0>>}

    assert Decoder.decode(<<0x2f, 0, 0, 0, 0, 0, 0, 0, 1, 0>>) == {:ok, 72_057_594_037_927_936, <<0>>}
    assert Decoder.decode(<<0x2f, 255, 255, 255, 255, 255, 255, 255, 255, 0>>) ==
      {:ok, 18_446_744_073_709_551_615, <<0>>}
  end

  test "decode() small positive integers without tail" do
    assert Decoder.decode(<<0x30>>) == {:ok, 0, ""}
    assert Decoder.decode(<<0x31>>) == {:ok, 1, ""}
    assert Decoder.decode(<<0x32>>) == {:ok, 2, ""}
    assert Decoder.decode(<<0x33>>) == {:ok, 3, ""}
    assert Decoder.decode(<<0x34>>) == {:ok, 4, ""}
    assert Decoder.decode(<<0x35>>) == {:ok, 5, ""}
    assert Decoder.decode(<<0x36>>) == {:ok, 6, ""}
    assert Decoder.decode(<<0x37>>) == {:ok, 7, ""}
    assert Decoder.decode(<<0x38>>) == {:ok, 8, ""}
    assert Decoder.decode(<<0x39>>) == {:ok, 9, ""}
  end

  test "decode() small negative integers without tail" do
    assert Decoder.decode(<<0x3a>>) == {:ok, -6, ""}
    assert Decoder.decode(<<0x3b>>) == {:ok, -5, ""}
    assert Decoder.decode(<<0x3c>>) == {:ok, -4, ""}
    assert Decoder.decode(<<0x3d>>) == {:ok, -3, ""}
    assert Decoder.decode(<<0x3e>>) == {:ok, -2, ""}
    assert Decoder.decode(<<0x3f>>) == {:ok, -1, ""}
  end

  test "decode() signed integers without tail" do
    assert Decoder.decode(<<0x20, 249>>) == {:ok, -7, ""}
    assert Decoder.decode(<<0x20, 128>>) == {:ok, -128, ""}

    assert Decoder.decode(<<0x21, 127, 255>>) == {:ok, -129, ""}
    assert Decoder.decode(<<0x21, 0, 128>>) == {:ok, -32_768, ""}

    assert Decoder.decode(<<0x22, 255, 127, 255>>) == {:ok, -32_769, ""}
    assert Decoder.decode(<<0x22, 0, 0, 128>>) == {:ok, -8_388_608, ""}

    assert Decoder.decode(<<0x23, 255, 255, 127, 255>>) == {:ok, -8_388_609, ""}
    assert Decoder.decode(<<0x23, 0, 0, 0, 128>>) == {:ok, -2_147_483_648, ""}

    assert Decoder.decode(<<0x24, 255, 255, 255, 127, 255>>) == {:ok, -2_147_483_649, ""}
    assert Decoder.decode(<<0x24, 0, 0, 0, 0, 128>>) == {:ok, -549_755_813_888, ""}

    assert Decoder.decode(<<0x25, 255, 255, 255, 255, 127, 255>>) == {:ok, -549_755_813_889, ""}
    assert Decoder.decode(<<0x25, 0, 0, 0, 0, 0, 128>>) == {:ok, -140_737_488_355_328, ""}

    assert Decoder.decode(<<0x26, 255, 255, 255, 255, 255, 127, 255>>) == {:ok, -140_737_488_355_329, ""}
    assert Decoder.decode(<<0x26, 0, 0, 0, 0, 0, 0, 128>>) == {:ok, -36_028_797_018_963_968, ""}

    assert Decoder.decode(<<0x27, 255, 255, 255, 255, 255, 255, 127, 255>>) == {:ok, -36_028_797_018_963_969, ""}
    assert Decoder.decode(<<0x27, 0, 0, 0, 0, 0, 0, 0, 128>>) == {:ok, -9_223_372_036_854_775_808, ""}
  end

  test "decode() unsigned integers without tail" do
    assert Decoder.decode(<<0x28, 10>>) == {:ok, 10, ""}
    assert Decoder.decode(<<0x28, 255>>) == {:ok, 255, ""}

    assert Decoder.decode(<<0x29, 0, 1>>) == {:ok, 256, ""}
    assert Decoder.decode(<<0x29, 255, 255>>) == {:ok, 65_535, ""}

    assert Decoder.decode(<<0x2a, 0, 0, 1>>) == {:ok, 65_536, ""}
    assert Decoder.decode(<<0x2a, 255, 255, 255>>) == {:ok, 16_777_215, ""}

    assert Decoder.decode(<<0x2b, 0, 0, 0, 1>>) == {:ok, 16_777_216, ""}
    assert Decoder.decode(<<0x2b, 255, 255, 255, 255>>) == {:ok, 4_294_967_295, ""}

    assert Decoder.decode(<<0x2c, 0, 0, 0, 0, 1>>) == {:ok, 4_294_967_296, ""}
    assert Decoder.decode(<<0x2c, 255, 255, 255, 255, 255>>) == {:ok, 1_099_511_627_775, ""}

    assert Decoder.decode(<<0x2d, 0, 0, 0, 0, 0, 1>>) == {:ok, 1_099_511_627_776, ""}
    assert Decoder.decode(<<0x2d, 255, 255, 255, 255, 255, 255>>) == {:ok, 281_474_976_710_655, ""}

    assert Decoder.decode(<<0x2e, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, 281_474_976_710_656, ""}
    assert Decoder.decode(<<0x2e, 255, 255, 255, 255, 255, 255, 255>>) == {:ok, 72_057_594_037_927_935, ""}

    assert Decoder.decode(<<0x2f, 0, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, 72_057_594_037_927_936, ""}
    assert Decoder.decode(<<0x2f, 255, 255, 255, 255, 255, 255, 255, 255>>) ==
      {:ok, 18_446_744_073_709_551_615, ""}
  end

  test "decode() empty list with tail" do
    assert Decoder.decode(<<0x01, 0>>) == {:ok, [], <<0>>}
  end

  test "decode() empty list without tail" do
    assert Decoder.decode(<<0x01>>) == {:ok, [], ""}
  end

  # todo - test decoding lists

  test "decode() empty map with tail" do
    assert Decoder.decode(<<0x0a, 0>>) == {:ok, %{}, <<0>>}
  end

  test "decode() empty map without tail" do
    assert Decoder.decode(<<0x0a>>) == {:ok, %{}, ""}
  end

  # todo - test decoding maps
end
