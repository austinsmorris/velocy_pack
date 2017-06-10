defmodule VelocyPack.Decoder.Map do
  @moduledoc false

  def decode(map, byte_length, number, offset_size), do: do_decode(map, byte_length, number, offset_size, [], [])

  defp do_build_map(map, [], []), do: map
  defp do_build_map(map, [key | keys], [value | values]) do
    map
      |> Map.put(key, value)
      |> do_build_map(keys, values)
  end

  defp do_decode(_map, _byte_length, 0, _offset_size, keys, values), do: do_build_map(%{}, keys, values)
  defp do_decode(map, byte_length, number, offset_size, keys, values) do
    prefix_length = (byte_length - div(offset_size, 8)) * 8
    <<next_map::size(prefix_length), offset::little-unsigned-size(offset_size)>> = map

    pair_offset_size = (offset - 1 - (2 * div(offset_size, 8))) * 8
    <<_::size(pair_offset_size), pair::binary>> = map

    # todo - error handling
    {:ok, key, tail} = VelocyPack.decode(pair)
    {:ok, value, _} = VelocyPack.decode(tail)

    do_decode(
      <<next_map::size(prefix_length)>>,
      byte_length - div(offset_size, 8),
      number - 1,
      offset_size,
      [key | keys],
      [value | values]
    )
  end
end
