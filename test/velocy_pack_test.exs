defmodule VelocyPackTest do
  alias VelocyPack

  use ExUnit.Case, async: true

  test "encode/2 encodes to VPack" do
    assert VelocyPack.encode(nil) == 0x18
  end
end
