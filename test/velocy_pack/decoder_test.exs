defmodule VelocyPack.DecoderTest do
  use ExUnit.Case, async: true

  alias VelocyPack.Decoder

  describe "decode/2" do
    test "decodes nil" do
      assert Decoder.decode(<<0x18>>) == {:ok, nil}
    end

    test "decodes false" do
      assert Decoder.decode(<<0x19>>) == {:ok, false}
    end

    test "decodes true" do
      assert Decoder.decode(<<0x1A>>) == {:ok, true}
    end

    # todo - test decoding multiple values (error)
  end
end
