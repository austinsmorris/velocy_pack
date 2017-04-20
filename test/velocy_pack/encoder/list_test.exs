defmodule VelocyPack.Encoder.ListTest do
  use ExUnit.Case, async: true

  test "encode an empty list" do
    assert VelocyPack.encode([]) == 0x01
  end
end
