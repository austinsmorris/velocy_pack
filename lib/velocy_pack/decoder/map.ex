defmodule VelocyPack.Decoder.Map do
  @moduledoc false

  use Bitwise, skip_operators: true

  def decode(map, map_bit_size), do: decode_compact_map(map, map_bit_size)

  def decode(map, byte_length, number, offset_size, padding) do
    do_decode(map, byte_length, number, offset_size, padding, [], [])
  end

  def get_compact_map_sizes(map), do: do_get_compact_map_sizes(map, 0, {0, 0})

  defp decode_compact_map(map, map_bit_size) do
    new_map_bit_size = map_bit_size - 8
    <<pairs::size(new_map_bit_size), number>> = map
    {num_items, tail} = get_compact_map_number(<<pairs::size(new_map_bit_size)>>, new_map_bit_size, <<number>>, 0, 0)
    do_decode_compact_map(tail, num_items, [], [])
  end

  defp do_build_map(map, [], []), do: map
  defp do_build_map(map, [key | keys], [value | values]) do
    map
      |> Map.put(key, value)
      |> do_build_map(keys, values)
  end

  # credo:disable-for-next-line Credo.Check.Refactor.FunctionArity
  defp do_decode(_map, _byte_length, 0, _offset_size, _padding, keys, values), do: do_build_map(%{}, keys, values)
  defp do_decode(map, byte_length, number, offset_size, padding, keys, values) do
    # credo:disable-for-previous-line Credo.Check.Refactor.FunctionArity
    prefix_length = (byte_length - div(offset_size, 8)) * 8
    <<next_map::size(prefix_length), offset::little-unsigned-size(offset_size)>> = map

    pair_offset_size = (offset - 1 - (2 * div(offset_size, 8)) - padding) * 8
    <<_::size(pair_offset_size), pair::binary>> = map

    # todo - error handling
    {:ok, key, tail} = VelocyPack.decode(pair)
    {:ok, value, _} = VelocyPack.decode(tail)

    do_decode(
      <<next_map::size(prefix_length)>>,
      byte_length - div(offset_size, 8),
      number - 1,
      offset_size,
      padding,
      [key | keys],
      [value | values]
    )
  end

  defp do_decode_compact_map(_map, 0, keys, values), do: do_build_map(%{}, Enum.reverse(keys), Enum.reverse(values))
  defp do_decode_compact_map(map, number, keys, values) do
    # todo - error handling
    {:ok, key, value_tail} = VelocyPack.decode(map)
    {:ok, value, tail} = VelocyPack.decode(value_tail)

    do_decode_compact_map(tail, number - 1, [key | keys], [value | values])
  end

  defp do_get_compact_map_sizes(<<0::1, value::7, _tail::binary>>, shift, {map_bytes_acc, size_bytes_acc}) do
    {Bitwise.bsl(value, shift) + map_bytes_acc, size_bytes_acc + 1}
  end
  defp do_get_compact_map_sizes(<<1::1, value::7, tail::binary>>, shift, {map_bytes_acc, size_bytes_acc}) do
    do_get_compact_map_sizes(tail, shift + 7, {Bitwise.bsl(value, shift) + map_bytes_acc, size_bytes_acc + 1})
  end

  defp get_compact_map_number(map, _map_bit_size, <<0::1, value::7>>, shift, acc) do
    {Bitwise.bsl(value, shift) + acc, map}
  end
  defp get_compact_map_number(map, map_bit_size, <<1::1, value::7>>, shift, acc) do
    new_map_bit_size = map_bit_size - 8
    <<pairs::size(new_map_bit_size), number>> = map
    get_compact_map_number(
      <<pairs::size(new_map_bit_size)>>,
      new_map_bit_size,
      <<number>>,
      shift + 7,
      Bitwise.bsl(value, shift) + acc
    )
  end
end
