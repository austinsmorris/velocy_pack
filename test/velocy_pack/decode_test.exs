defmodule VelocyPack.DecodeTest do
  use ExUnit.Case, async: true

  alias VelocyPack.Decode

  describe "decode/2" do
    test "decodes nil" do
      assert Decode.decode(<<0x18>>) == {:ok, nil}
    end

    test "decodes false" do
      assert Decode.decode(<<0x19>>) == {:ok, false}
    end

    test "decodes true" do
      assert Decode.decode(<<0x1A>>) == {:ok, true}
    end

    test "decodes small positive integers" do
      assert Decode.decode(<<0x30>>) == {:ok, 0}
      assert Decode.decode(<<0x31>>) == {:ok, 1}
      assert Decode.decode(<<0x32>>) == {:ok, 2}
      assert Decode.decode(<<0x33>>) == {:ok, 3}
      assert Decode.decode(<<0x34>>) == {:ok, 4}
      assert Decode.decode(<<0x35>>) == {:ok, 5}
      assert Decode.decode(<<0x36>>) == {:ok, 6}
      assert Decode.decode(<<0x37>>) == {:ok, 7}
      assert Decode.decode(<<0x38>>) == {:ok, 8}
      assert Decode.decode(<<0x39>>) == {:ok, 9}
    end

    test "decodes small negative integers" do
      assert Decode.decode(<<0x3A>>) == {:ok, -6}
      assert Decode.decode(<<0x3B>>) == {:ok, -5}
      assert Decode.decode(<<0x3C>>) == {:ok, -4}
      assert Decode.decode(<<0x3D>>) == {:ok, -3}
      assert Decode.decode(<<0x3E>>) == {:ok, -2}
      assert Decode.decode(<<0x3F>>) == {:ok, -1}
    end

    test "decodes signed integers" do
      assert Decode.decode(<<0x20, 249>>) == {:ok, -7}
      assert Decode.decode(<<0x20, 128>>) == {:ok, -128}

      assert Decode.decode(<<0x21, 127, 255>>) == {:ok, -129}
      assert Decode.decode(<<0x21, 0, 128>>) == {:ok, -32_768}

      assert Decode.decode(<<0x22, 255, 127, 255>>) == {:ok, -32_769}
      assert Decode.decode(<<0x22, 0, 0, 128>>) == {:ok, -8_388_608}

      assert Decode.decode(<<0x23, 255, 255, 127, 255>>) == {:ok, -8_388_609}
      assert Decode.decode(<<0x23, 0, 0, 0, 128>>) == {:ok, -2_147_483_648}

      assert Decode.decode(<<0x24, 255, 255, 255, 127, 255>>) == {:ok, -2_147_483_649}
      assert Decode.decode(<<0x24, 0, 0, 0, 0, 128>>) == {:ok, -549_755_813_888}

      assert Decode.decode(<<0x25, 255, 255, 255, 255, 127, 255>>) == {:ok, -549_755_813_889}
      assert Decode.decode(<<0x25, 0, 0, 0, 0, 0, 128>>) == {:ok, -140_737_488_355_328}

      assert Decode.decode(<<0x26, 255, 255, 255, 255, 255, 127, 255>>) == {:ok, -140_737_488_355_329}
      assert Decode.decode(<<0x26, 0, 0, 0, 0, 0, 0, 128>>) == {:ok, -36_028_797_018_963_968}

      assert Decode.decode(<<0x27, 255, 255, 255, 255, 255, 255, 127, 255>>) == {:ok, -36_028_797_018_963_969}
      assert Decode.decode(<<0x27, 0, 0, 0, 0, 0, 0, 0, 128>>) == {:ok, -9_223_372_036_854_775_808}
    end

    test "decodes unsigned integers" do
      assert Decode.decode(<<0x28, 10>>) == {:ok, 10}
      assert Decode.decode(<<0x28, 255>>) == {:ok, 255}

      assert Decode.decode(<<0x29, 0, 1>>) == {:ok, 256}
      assert Decode.decode(<<0x29, 255, 255>>) == {:ok, 65_535}

      assert Decode.decode(<<0x2A, 0, 0, 1>>) == {:ok, 65_536}
      assert Decode.decode(<<0x2A, 255, 255, 255>>) == {:ok, 16_777_215}

      assert Decode.decode(<<0x2B, 0, 0, 0, 1>>) == {:ok, 16_777_216}
      assert Decode.decode(<<0x2B, 255, 255, 255, 255>>) == {:ok, 4_294_967_295}

      assert Decode.decode(<<0x2C, 0, 0, 0, 0, 1>>) == {:ok, 4_294_967_296}
      assert Decode.decode(<<0x2C, 255, 255, 255, 255, 255>>) == {:ok, 1_099_511_627_775}

      assert Decode.decode(<<0x2D, 0, 0, 0, 0, 0, 1>>) == {:ok, 1_099_511_627_776}
      assert Decode.decode(<<0x2D, 255, 255, 255, 255, 255, 255>>) == {:ok, 281_474_976_710_655}

      assert Decode.decode(<<0x2E, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, 281_474_976_710_656}
      assert Decode.decode(<<0x2E, 255, 255, 255, 255, 255, 255, 255>>) == {:ok, 72_057_594_037_927_935}

      assert Decode.decode(<<0x2F, 0, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, 72_057_594_037_927_936}
      assert Decode.decode(<<0x2F, 255, 255, 255, 255, 255, 255, 255, 255>>) == {:ok, 18_446_744_073_709_551_615}
    end

    test "decodes empty string" do
      assert Decode.decode(<<0x40>>) == {:ok, ""}
    end

    test "decodes short string" do
      assert Decode.decode(<<0x41, "a">>) == {:ok, "a"}
      assert Decode.decode(<<0x43, "foo">>) == {:ok, "foo"}

      string =
        "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdfasdflkajsdflkj" <>
          "asdfasdfasdfasdfasdfalka"

      assert Decode.decode(<<0xBE, string::binary>>) == {:ok, string}
    end

    test "decodes long string" do
      string =
        "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasd" <>
          "flkjasdflkajsdflkjasdflkjasdlksjadflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdf" <>
          "lkjasd"

      binary = <<0xBF, byte_size(string)::little-unsigned-size(64), string::binary>>
      assert Decode.decode(binary) == {:ok, string}
    end

    test "decodes empty list" do
      assert Decode.decode(<<0x01>>) == {:ok, []}
    end

    # todo - test decoding lists

    test "decodes empty map" do
      assert Decode.decode(<<0x0A>>) == {:ok, %{}}
    end

    # todo - test decoding maps

    # todo - test decoding multiple values (error)
  end
end
