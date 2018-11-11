defmodule VelocyPack.EncodeTest do
  use ExUnit.Case, async: true

  alias VelocyPack.Encode

  describe "encode/2" do
    test "encodes an empty list" do
      {:ok, encoded} = Encode.encode([])
      assert encoded == 0x01
    end

    test "encodes an empty map" do
      {:ok, encoded} = Encode.encode(%{})
      assert encoded == 0x0A
    end
  end

  describe "encode_list/1" do
    test "encodes an empty list" do
      encoded = Encode.encode_list([])
      assert encoded == 0x01
    end
  end

  describe "encode_list_with_size/1" do
    test "encodes an empty list" do
      encoded = Encode.encode_list_with_size([])
      assert encoded == {0x01, 1}
    end
  end

  describe "encode_map/1" do
    test "encodes an empty map" do
      encoded = Encode.encode_map(%{})
      assert encoded == 0x0A
    end
  end

  describe "encode_map_with_size/1" do
    test "encodes an empty map" do
      encoded = Encode.encode_map_with_size(%{})
      assert encoded == {0x0A, 1}
    end
  end
end
