defmodule VelocyPack.EncodeTest do
  use ExUnit.Case, async: true

  alias VelocyPack.Encode

  describe "encode/2" do
    test "encodes an empty list" do
      {:ok, encoded} = Encode.encode([])
      assert encoded === 0x01
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
      encoded = Encode.encode_atom(:nil)
      assert encoded === 0x18
    end

    test "encodes atom false" do
      encoded = Encode.encode_atom(:false)
      assert encoded === 0x19
    end

    test "encodes atom true" do
      encoded = Encode.encode_atom(:true)
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
      encoded = Encode.encode_atom_with_size(:nil)
      assert encoded === {0x18, 1}
    end

    test "encodes atom false" do
      encoded = Encode.encode_atom_with_size(:false)
      assert encoded === {0x19, 1}
    end

    test "encodes atom true" do
      encoded = Encode.encode_atom_with_size(:true)
      assert encoded === {0x1A, 1}
    end
  end

  describe "encode_list/1" do
    test "encodes an empty list" do
      encoded = Encode.encode_list([])
      assert encoded === 0x01
    end
  end

  describe "encode_list_with_size/1" do
    test "encodes an empty list" do
      encoded = Encode.encode_list_with_size([])
      assert encoded === {0x01, 1}
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
