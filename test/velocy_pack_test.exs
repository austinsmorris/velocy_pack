defmodule VelocyPackTest do
  alias VelocyPack

  use ExUnit.Case, async: true

  test "encode/2 encodes to binary VelocyPack" do
    assert VelocyPack.encode(nil) == {:ok, <<0x18>>}
  end

  test "encode/2 with error" do
    assert {:error, %Protocol.UndefinedError{} = error} = VelocyPack.encode(make_ref())
  end

  test "encode!/2 encodes to binary VelocyPack" do
    assert VelocyPack.encode!(nil) == <<0x18>>
  end

  test "encode!/2 will raise with error" do
    assert_raise(Protocol.UndefinedError, fn() -> VelocyPack.encode!(make_ref()) end)
  end

  test "encode_to_iodata/2 encodes to an iodata list of VelocyPack" do
    assert VelocyPack.encode_to_iodata(nil) == {:ok, [0x18]}
  end

  test "encode_to_iodata/2 with error" do
    assert {:error, %Protocol.UndefinedError{} = error} = VelocyPack.encode_to_iodata(make_ref())
  end

  test "encode_to_iodata!/2 encodes to an iodata list of VelocyPack" do
    assert VelocyPack.encode_to_iodata!(nil) == [0x18]
  end

  test "encode_to_iodata!/2 will raise with error" do
    assert_raise(Protocol.UndefinedError, fn() -> VelocyPack.encode_to_iodata!(make_ref()) end)
  end
end
