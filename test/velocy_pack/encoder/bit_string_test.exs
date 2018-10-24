defmodule VelocyPack.Encoder.BitStringTest do
  use ExUnit.Case, async: true

  alias VelocyPack.Encoder

  test "encode() an empty bit string" do
    assert Encoder.encode(<<>>) == 0x40
  end

  test "encode() an empty string" do
    assert Encoder.encode("") == 0x40
  end

  test "encode() a short string" do
    assert Encoder.encode("a") == <<0x41, "a">>
    assert Encoder.encode("foo") == <<0x43, "foo">>

    string = "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdfasdflkajsdflkjas"
      <> "dfasdfasdfasdfasdfalka"
    assert Encoder.encode(string) == <<0xbe, string::binary>>
  end

  test "encode() a long string" do
    value = "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkj"
      <> "asdflkajsdflkjasdflkjasdlksjadflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasd"
    <<indicator, size::little-unsigned-size(64), string::binary>> = Encoder.encode(value)

    assert indicator == 0xbf
    assert size == byte_size(value)
    assert string == value
  end

  test "encode_with_size() an empty bit string" do
    assert Encoder.encode_with_size(<<>>) == {0x40, 1}
  end

  test "encode_with_size() an empty string" do
    assert Encoder.encode_with_size("") == {0x40, 1}
  end

  test "encode_with_size() a short string" do
    assert Encoder.encode_with_size("a") == {<<0x41, "a">>, 2}
    assert Encoder.encode_with_size("foo") == {<<0x43, "foo">>, 4}

    string = "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdfasdflkajsdflkjas"
      <> "dfasdfasdfasdfasdfalka"
    assert Encoder.encode_with_size(string) == {<<0xbe, string::binary>>, 127}
  end

  test "encode_with_size() a long string" do
    value = "asdlfkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkj"
      <> "asdflkajsdflkjasdflkjasdlksjadflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasdflkjasd"
    {<<indicator, size::little-unsigned-size(64), string::binary>>, encode_size} = Encoder.encode_with_size(value)

    assert indicator == 0xbf
    assert size == byte_size(value)
    assert string == value
    assert encode_size == 221
  end
end
