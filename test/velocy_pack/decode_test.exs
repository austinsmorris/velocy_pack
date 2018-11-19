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

    test "decodes compact list" do
      data =
        <<0x13, 0xC1, 0x01, 0x14, 0xBD, 0x01, 0x44, 0x6E, 0x61, 0x6D, 0x65, 0x43, 0x66, 0x6F, 0x6F, 0x49, 0x70, 0x61,
          0x72, 0x61, 0x6D, 0x65, 0x74, 0x65, 0x72, 0x0A, 0x45, 0x76, 0x61, 0x6C, 0x75, 0x65, 0xBF, 0x96, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x46, 0x4F, 0x52, 0x20, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x62,
          0x6C, 0x61, 0x68, 0x20, 0x49, 0x4E, 0x20, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61,
          0x68, 0x73, 0x0A, 0x20, 0x20, 0x20, 0x20, 0x46, 0x4F, 0x52, 0x20, 0x79, 0x61, 0x64, 0x64, 0x61, 0x79, 0x61,
          0x64, 0x64, 0x61, 0x79, 0x61, 0x64, 0x64, 0x61, 0x20, 0x49, 0x4E, 0x20, 0x4F, 0x55, 0x54, 0x42, 0x4F, 0x55,
          0x4E, 0x44, 0x20, 0x79, 0x61, 0x64, 0x64, 0x61, 0x79, 0x61, 0x64, 0x64, 0x61, 0x79, 0x61, 0x64, 0x64, 0x61,
          0x73, 0x20, 0x69, 0x6E, 0x5F, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x73,
          0x0A, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x52, 0x45, 0x54, 0x55, 0x52, 0x4E, 0x20, 0x7B, 0x79,
          0x61, 0x64, 0x64, 0x61, 0x79, 0x61, 0x64, 0x64, 0x61, 0x79, 0x61, 0x64, 0x64, 0x61, 0x2C, 0x20, 0x62, 0x6C,
          0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x7D, 0x03, 0x01>>

      list = [
        %{
          "name" => "foo",
          "parameter" => %{},
          "value" =>
            "FOR blahblahblah IN blahblahblahs\n    FOR yaddayaddayadda IN OUTBOUND yaddayaddayaddas " <>
              "in_blahblahblahs\n        RETURN {yaddayaddayadda, blahblahblah}"
        }
      ]

      assert Decode.decode(data) == {:ok, list}
    end

    # todo - test decoding lists

    test "decodes empty map" do
      assert Decode.decode(<<0x0A>>) == {:ok, %{}}
    end

    test "decodes compact map" do
      data =
        <<0x14, 0xCD, 0x01, 0x47, 0x71, 0x75, 0x65, 0x72, 0x69, 0x65, 0x73, 0x13, 0xC1, 0x01, 0x14, 0xBD, 0x01, 0x44,
          0x6E, 0x61, 0x6D, 0x65, 0x43, 0x66, 0x6F, 0x6F, 0x49, 0x70, 0x61, 0x72, 0x61, 0x6D, 0x65, 0x74, 0x65, 0x72,
          0x0A, 0x45, 0x76, 0x61, 0x6C, 0x75, 0x65, 0xBF, 0x96, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46, 0x4F,
          0x52, 0x20, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x20, 0x49, 0x4E, 0x20,
          0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x73, 0x0A, 0x20, 0x20, 0x20, 0x20,
          0x46, 0x4F, 0x52, 0x20, 0x79, 0x61, 0x64, 0x64, 0x61, 0x79, 0x61, 0x64, 0x64, 0x61, 0x79, 0x61, 0x64, 0x64,
          0x61, 0x20, 0x49, 0x4E, 0x20, 0x4F, 0x55, 0x54, 0x42, 0x4F, 0x55, 0x4E, 0x44, 0x20, 0x79, 0x61, 0x64, 0x64,
          0x61, 0x79, 0x61, 0x64, 0x64, 0x61, 0x79, 0x61, 0x64, 0x64, 0x61, 0x73, 0x20, 0x69, 0x6E, 0x5F, 0x62, 0x6C,
          0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x73, 0x0A, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
          0x20, 0x20, 0x52, 0x45, 0x54, 0x55, 0x52, 0x4E, 0x20, 0x7B, 0x79, 0x61, 0x64, 0x64, 0x61, 0x79, 0x61, 0x64,
          0x64, 0x61, 0x79, 0x61, 0x64, 0x64, 0x61, 0x2C, 0x20, 0x62, 0x6C, 0x61, 0x68, 0x62, 0x6C, 0x61, 0x68, 0x62,
          0x6C, 0x61, 0x68, 0x7D, 0x03, 0x01, 0x01>>

      map = %{
        "queries" => [
          %{
            "name" => "foo",
            "parameter" => %{},
            "value" =>
              "FOR blahblahblah IN blahblahblahs\n    FOR yaddayaddayadda IN OUTBOUND yaddayaddayaddas " <>
                "in_blahblahblahs\n        RETURN {yaddayaddayadda, blahblahblah}"
          }
        ]
      }

      assert Decode.decode(data) == {:ok, map}
    end

    # todo - decode 1-byte offset with padding

    test "decodes map with 1-byte offset without padding" do
      data =
        <<11, 43, 3, 51, 76, 102, 111, 111, 47, 50, 49, 54, 50, 53, 49, 57, 53, 49, 72, 50, 49, 54, 50, 53, 49, 57, 53,
          50, 75, 95, 86, 107, 51, 70, 65, 112, 87, 45, 45, 45, 3, 17, 27>>

      map = %{"_id" => "foo/21625195", "_key" => "21625195", "_rev" => "_Vk3FApW---"}

      assert Decode.decode(data) === {:ok, map}
    end

    test "decode2 map with 2-byte offset and zero-byte padding" do
      data =
        <<12, 44, 1, 15, 0, 0, 0, 0, 0, 68, 117, 115, 101, 114, 24, 72, 100, 97, 116, 97, 98, 97, 115, 101, 71, 95, 115,
          121, 115, 116, 101, 109, 67, 117, 114, 108, 76, 47, 95, 97, 100, 109, 105, 110, 47, 101, 99, 104, 111, 72,
          112, 114, 111, 116, 111, 99, 111, 108, 67, 118, 115, 116, 70, 115, 101, 114, 118, 101, 114, 11, 31, 2, 71, 97,
          100, 100, 114, 101, 115, 115, 73, 49, 50, 55, 46, 48, 46, 48, 46, 49, 68, 112, 111, 114, 116, 41, 81, 33, 3,
          21, 70, 99, 108, 105, 101, 110, 116, 11, 51, 3, 71, 97, 100, 100, 114, 101, 115, 115, 73, 49, 50, 55, 46, 48,
          46, 48, 46, 49, 68, 112, 111, 114, 116, 41, 53, 201, 66, 105, 100, 79, 49, 52, 57, 55, 50, 49, 49, 57, 54, 48,
          53, 49, 54, 53, 48, 3, 29, 21, 73, 105, 110, 116, 101, 114, 110, 97, 108, 115, 10, 70, 112, 114, 101, 102,
          105, 120, 65, 47, 71, 104, 101, 97, 100, 101, 114, 115, 10, 75, 114, 101, 113, 117, 101, 115, 116, 84, 121,
          112, 101, 68, 80, 79, 83, 84, 75, 114, 101, 113, 117, 101, 115, 116, 66, 111, 100, 121, 67, 49, 50, 51, 74,
          112, 97, 114, 97, 109, 101, 116, 101, 114, 115, 10, 70, 115, 117, 102, 102, 105, 120, 1, 68, 112, 97, 116,
          104, 65, 47, 78, 114, 97, 119, 82, 101, 113, 117, 101, 115, 116, 66, 111, 100, 121, 2, 8, 40, 49, 40, 50, 40,
          51, 100, 0, 15, 0, 178, 0, 158, 0, 220, 0, 240, 0, 169, 0, 49, 0, 247, 0, 204, 0, 187, 0, 62, 0, 232, 0, 32,
          0, 9, 0>>

      map = %{
        "client" => %{"address" => "127.0.0.1", "id" => "149721196051650", "port" => 51509},
        "database" => "_system",
        "headers" => %{},
        "internals" => %{},
        "parameters" => %{},
        "path" => "/",
        "prefix" => "/",
        "protocol" => "vst",
        "rawRequestBody" => '123',
        "requestBody" => "123",
        "requestType" => "POST",
        "server" => %{"address" => "127.0.0.1", "port" => 8529},
        "suffix" => [],
        "url" => "/_admin/echo",
        "user" => nil
      }

      assert Decode.decode(data) === {:ok, map}
    end

    # todo - decode 2-byte offset without padding

    # todo - test decoding maps

    # todo - test translating arango keys???

    # todo - test decoding multiple values (error)
  end
end
