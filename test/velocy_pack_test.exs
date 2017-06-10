defmodule VelocyPackTest do
  alias VelocyPack

  use ExUnit.Case, async: true

  test "encode/2 encodes to binary VelocyPack" do
    assert VelocyPack.encode(nil) == {:ok, <<0x18>>}
  end

  test "encode/2 with error" do
    assert {:error, %Protocol.UndefinedError{}} = VelocyPack.encode(make_ref())
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
    assert {:error, %Protocol.UndefinedError{}} = VelocyPack.encode_to_iodata(make_ref())
  end

  test "encode_to_iodata!/2 encodes to an iodata list of VelocyPack" do
    assert VelocyPack.encode_to_iodata!(nil) == [0x18]
  end

  test "encode_to_iodata!/2 will raise with error" do
    assert_raise(Protocol.UndefinedError, fn() -> VelocyPack.encode_to_iodata!(make_ref()) end)
  end

  test "decode/2 decodes from binary VelocyPack" do
    assert VelocyPack.decode(<<0x18>>) == {:ok, nil, ""}
  end

  test "decode/2 decodes from binary VelocyPack with a tail" do
    assert VelocyPack.decode(<<0x18, 0>>) == {:ok, nil, <<0>>}
  end

  test "decode/2 with error" do
    assert {:error, %FunctionClauseError{}} = VelocyPack.decode(<<0x00>>)
  end

  test "decode!/2 decodes from binary VelocyPack" do
    assert VelocyPack.decode!(<<0x18>>) == nil
  end

  # todo - test decode!/2 when there are multiple values
  # todo = test decode!/2 with error
end
