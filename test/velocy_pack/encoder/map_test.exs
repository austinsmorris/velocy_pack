defmodule VelocyPack.Encoder.MapTest do
  use ExUnit.Case, async: true

  test "encode an empty map" do
    assert VelocyPack.encode(%{}) == 0x0a
  end
end
