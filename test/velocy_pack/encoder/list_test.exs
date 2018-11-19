defmodule VelocyPack.Encoder.ListTest do
  use ExUnit.Case, async: true

  alias VelocyPack.Encoder

  test "encode/2 with empty list" do
    assert Encoder.encode([]) === 0x01
  end

  test "encode_with_size/2 with empty list" do
    assert Encoder.encode_with_size([]) === {0x01, 1}
  end
end
