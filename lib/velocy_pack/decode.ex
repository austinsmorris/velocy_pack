defmodule VelocyPack.Decode do
  @moduledoc false

  use Bitwise, skip_operators: true

  # todo - document and make a high level option
  @translate_arango_key Application.get_env(:velocy_pack, :translate_arango_key, true)

  def decode(data, _opts \\ []) when is_binary(data) do
    try do
      do_decode(data)
    catch
      e -> {:error, e}
    else
      # todo - because Vpack is a steam of binary data, it should always return a valid value with tailing data
      {value, tail} -> {:ok, value, tail}
      # todo - is it even possible to get here?
      x -> {:error, x}
    end
  end

  # atom
  defp do_decode(<<0x18, tail::binary>>), do: {nil, tail}
  defp do_decode(<<0x19, tail::binary>>), do: {false, tail}
  defp do_decode(<<0x1A, tail::binary>>), do: {true, tail}

  # integer
  defp do_decode(<<0x30, tail::binary>>), do: {0, tail}
  defp do_decode(<<0x31, tail::binary>>), do: {1, tail}
  defp do_decode(<<0x32, tail::binary>>), do: {2, tail}
  defp do_decode(<<0x33, tail::binary>>), do: {3, tail}
  defp do_decode(<<0x34, tail::binary>>), do: {4, tail}
  defp do_decode(<<0x35, tail::binary>>), do: {5, tail}
  defp do_decode(<<0x36, tail::binary>>), do: {6, tail}
  defp do_decode(<<0x37, tail::binary>>), do: {7, tail}
  defp do_decode(<<0x38, tail::binary>>), do: {8, tail}
  defp do_decode(<<0x39, tail::binary>>), do: {9, tail}

  defp do_decode(<<0x3A, tail::binary>>), do: {-6, tail}
  defp do_decode(<<0x3B, tail::binary>>), do: {-5, tail}
  defp do_decode(<<0x3C, tail::binary>>), do: {-4, tail}
  defp do_decode(<<0x3D, tail::binary>>), do: {-3, tail}
  defp do_decode(<<0x3E, tail::binary>>), do: {-2, tail}
  defp do_decode(<<0x3F, tail::binary>>), do: {-1, tail}

  defp do_decode(<<0x20, value::little-signed-size(8), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x21, value::little-signed-size(16), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x22, value::little-signed-size(24), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x23, value::little-signed-size(32), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x24, value::little-signed-size(40), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x25, value::little-signed-size(48), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x26, value::little-signed-size(56), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x27, value::little-signed-size(64), tail::binary>>), do: {value, tail}

  defp do_decode(<<0x28, value::little-unsigned-size(8), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x29, value::little-unsigned-size(16), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x2A, value::little-unsigned-size(24), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x2B, value::little-unsigned-size(32), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x2C, value::little-unsigned-size(40), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x2D, value::little-unsigned-size(48), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x2E, value::little-unsigned-size(56), tail::binary>>), do: {value, tail}
  defp do_decode(<<0x2F, value::little-unsigned-size(64), tail::binary>>), do: {value, tail}

  # string
  defp do_decode(<<0x40, tail::binary>>), do: {"", tail}

  defp do_decode(<<x, rest::binary>>) when x > 0x40 and x < 0xBF do
    value_size = (x - 0x40) * 8
    <<value::size(value_size), tail::binary>> = rest
    {<<value::size(value_size)>>, tail}
  end

  defp do_decode(<<0xBF, size::little-unsigned-size(64), rest::binary>>) do
    value_size = size * 8
    <<value::size(value_size), tail::binary>> = rest
    {<<value::size(value_size)>>, tail}
  end

  # list
  defp do_decode(<<0x01, tail::binary>>), do: {[], tail}

  # todo - ensure decoded list has the indicated number of items
  defp do_decode(<<0x02, length::little-unsigned-size(8), rest::binary>>) do
    list_length = (length - 2) * 8
    <<list::size(list_length), tail::binary>> = rest
    {decode_list(<<list::size(list_length)>>), tail}
  end

  defp do_decode(<<0x06, l::little-unsigned-size(8), n::little-unsigned-size(8), 0::size(48), r::binary>>) do
    do_decode(<<0x06, l - 6::little-unsigned-size(8), n::little-unsigned-size(8), r::binary>>)
  end

  defp do_decode(<<0x06, length::little-unsigned-size(8), number::little-unsigned-size(8), rest::binary>>) do
    list_length = (length - 3 - number) * 8
    index_length = number * 8
    <<list::size(list_length), _index::size(index_length), tail::binary>> = rest
    {decode_list(<<list::size(list_length)>>), tail}
  end

  defp do_decode(<<0x07, l::little-unsigned-size(16), n::little-unsigned-size(16), 0::size(32), r::binary>>) do
    do_decode(<<0x07, l - 4::little-unsigned-size(16), n::little-unsigned-size(16), r::binary>>)
  end

  defp do_decode(<<0x07, length::little-unsigned-size(16), number::little-unsigned-size(16), rest::binary>>) do
    list_length = (length - 5 - number * 2) * 8
    index_length = number * 2 * 8
    <<list::size(list_length), _index::size(index_length), tail::binary>> = rest
    {decode_list(<<list::size(list_length)>>), tail}
  end

  defp do_decode(<<0x13, rest::binary>>) do
    {full_list_byte_size, list_size_byte_size} = get_compact_list_sizes(rest)
    list_bit_size = (full_list_byte_size - list_size_byte_size - 1) * 8
    list_size_bit_size = list_size_byte_size * 8
    <<_::size(list_size_bit_size), list::size(list_bit_size), tail::binary>> = rest
    {decode_list(<<list::size(list_bit_size)>>, list_bit_size), tail}
  end

  # map
  defp do_decode(<<0x0A, tail::binary>>), do: {%{}, tail}

  # todo - ensure decoded map has the indicated number of items
  defp do_decode(<<0x0B, length::little-unsigned-size(8), number::little-unsigned-size(8), rest::binary>>) do
    map_length = (length - 3) * 8
    <<map::size(map_length), tail::binary>> = rest
    {decode_map(<<map::size(map_length)>>, length - 3, number, 8, 0), tail}
  end

  defp do_decode(
         <<0x0C, length::little-unsigned-size(16), number::little-unsigned-size(16), 0::size(32), rest::binary>>
       ) do
    map_length = (length - 9) * 8
    <<map::size(map_length), tail::binary>> = rest
    {decode_map(<<map::size(map_length)>>, length - 9, number, 16, 4), tail}
  end

  defp do_decode(<<0x0C, length::little-unsigned-size(16), number::little-unsigned-size(16), rest::binary>>) do
    map_length = (length - 5) * 8
    <<map::size(map_length), tail::binary>> = rest
    {decode_map(<<map::size(map_length)>>, length - 5, number, 16, 0), tail}
  end

  defp do_decode(<<0x14, rest::binary>>) do
    {full_map_byte_size, map_size_byte_size} = get_compact_map_sizes(rest)
    map_bit_size = (full_map_byte_size - map_size_byte_size - 1) * 8
    map_size_bit_size = map_size_byte_size * 8
    <<_::size(map_size_bit_size), map::size(map_bit_size), tail::binary>> = rest
    {decode_map(<<map::size(map_bit_size)>>, map_bit_size), tail}
  end

  # helpers
  defp decode_list(list), do: do_decode_list(list, [])

  defp decode_list(list, list_bit_size), do: do_decode_compact_list(list, list_bit_size)

  defp decode_compact_map(map, map_bit_size) do
    new_map_bit_size = map_bit_size - 8
    <<pairs::size(new_map_bit_size), number>> = map
    {num_items, tail} = get_compact_map_number(<<pairs::size(new_map_bit_size)>>, new_map_bit_size, <<number>>, 0, 0)
    do_decode_compact_map(tail, num_items, [], [])
  end

  defp decode_map(map, map_bit_size), do: decode_compact_map(map, map_bit_size)

  defp decode_map(map, byte_length, number, offset_size, padding) do
    do_decode_map(map, byte_length, number, offset_size, padding, [], [])
  end

  defp get_compact_list_sizes(list), do: do_get_compact_list_sizes(list, 0, {0, 0})

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

  defp get_compact_map_sizes(map), do: do_get_compact_map_sizes(map, 0, {0, 0})

  # helper helpers
  defp do_build_map(map, [], []), do: map

  defp do_build_map(map, [key | keys], [value | values]) do
    map
    |> Map.put(key, value)
    |> do_build_map(keys, values)
  end

  defp do_decode_compact_list(list, list_bit_size) do
    new_list_bit_size = list_bit_size - 8
    <<items::size(new_list_bit_size), number>> = list

    case <<number>> do
      <<0::1, _value::7>> -> decode_list(<<items::size(new_list_bit_size)>>)
      <<1::1, _value::7>> -> do_decode_compact_list(<<items::size(new_list_bit_size)>>, new_list_bit_size)
    end
  end

  defp do_decode_compact_map(_map, 0, keys, values) do
    do_build_map(%{}, Enum.reverse(keys), Enum.reverse(values))
  end

  defp do_decode_compact_map(map, number, keys, values) do
    {key, value_tail} = do_decode(map)
    {value, tail} = do_decode(value_tail)

    do_decode_compact_map(tail, number - 1, [key | keys], [value | values])
  end

  defp do_decode_list(list, values) do
    case do_decode(list) do
      {value, ""} -> [value | values] |> Enum.reverse()
      {value, tail} -> do_decode_list(tail, [value | values])
    end
  end

  defp do_decode_map(_map, _byte_length, 0, _offset_size, _padding, keys, values), do: do_build_map(%{}, keys, values)

  defp do_decode_map(map, byte_length, number, offset_size, padding, keys, values) do
    prefix_length = (byte_length - div(offset_size, 8)) * 8
    <<next_map::size(prefix_length), offset::little-unsigned-size(offset_size)>> = map

    pair_offset_size = (offset - 1 - 2 * div(offset_size, 8) - padding) * 8
    <<_::size(pair_offset_size), pair::binary>> = map

    {vpack_key, tail} = do_decode(pair)
    {value, _} = do_decode(tail)
    key = translate_arango_key(vpack_key, @translate_arango_key)

    do_decode_map(
      <<next_map::size(prefix_length)>>,
      byte_length - div(offset_size, 8),
      number - 1,
      offset_size,
      padding,
      [key | keys],
      [value | values]
    )
  end

  defp do_get_compact_list_sizes(<<0::1, value::7, _tail::binary>>, shift, {list_bytes_acc, size_bytes_acc}) do
    {Bitwise.bsl(value, shift) + list_bytes_acc, size_bytes_acc + 1}
  end

  defp do_get_compact_list_sizes(<<1::1, value::7, tail::binary>>, shift, {list_bytes_acc, size_bytes_acc}) do
    do_get_compact_list_sizes(tail, shift + 7, {Bitwise.bsl(value, shift) + list_bytes_acc, size_bytes_acc + 1})
  end

  defp do_get_compact_map_sizes(<<0::1, value::7, _tail::binary>>, shift, {map_bytes_acc, size_bytes_acc}) do
    {Bitwise.bsl(value, shift) + map_bytes_acc, size_bytes_acc + 1}
  end

  defp do_get_compact_map_sizes(<<1::1, value::7, tail::binary>>, shift, {map_bytes_acc, size_bytes_acc}) do
    do_get_compact_map_sizes(tail, shift + 7, {Bitwise.bsl(value, shift) + map_bytes_acc, size_bytes_acc + 1})
  end

  defp translate_arango_key(1, true), do: "_key"
  defp translate_arango_key(2, true), do: "_rev"
  defp translate_arango_key(3, true), do: "_id"
  defp translate_arango_key(4, true), do: "_from"
  defp translate_arango_key(5, true), do: "_to"
  defp translate_arango_key(key, _), do: key
end
