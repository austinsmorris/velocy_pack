defmodule VelocyPack.Decoder do
  @moduledoc false

  alias VelocyPack.Decoder.List, as: DList
  alias VelocyPack.Decoder.Map, as: DMap

  def decode(data, options \\ [])

  # atom
  def decode(<<0x18, tail::binary>>, _options), do: {:ok, nil, tail}
  def decode(<<0x19, tail::binary>>, _options), do: {:ok, false, tail}
  def decode(<<0x1a, tail::binary>>, _options), do: {:ok, true, tail}

  # bit string
  def decode(<<0x40, tail::binary>>, _options), do: {:ok, "", tail}

  # todo - incomplete short bit strings
  def decode(<<x, rest::binary>>, _options) when x > 0x40 and x < 0xbf do
    value_size = ((x - 0x40) * 8)
    <<value::size(value_size), tail::binary>> = rest
    {:ok, <<value::size(value_size)>>, tail}
  end

  # todo - incomplete long bit strings
  def decode(<<0xbf, size::little-unsigned-size(64), rest::binary>>, _options) do
    value_size = size * 8
    <<value::size(value_size), tail::binary>> = rest
    {:ok, <<value::size(value_size)>>, tail}
  end

  # integer
  def decode(<<0x30, tail::binary>>, _options), do: {:ok, 0, tail}
  def decode(<<0x31, tail::binary>>, _options), do: {:ok, 1, tail}
  def decode(<<0x32, tail::binary>>, _options), do: {:ok, 2, tail}
  def decode(<<0x33, tail::binary>>, _options), do: {:ok, 3, tail}
  def decode(<<0x34, tail::binary>>, _options), do: {:ok, 4, tail}
  def decode(<<0x35, tail::binary>>, _options), do: {:ok, 5, tail}
  def decode(<<0x36, tail::binary>>, _options), do: {:ok, 6, tail}
  def decode(<<0x37, tail::binary>>, _options), do: {:ok, 7, tail}
  def decode(<<0x38, tail::binary>>, _options), do: {:ok, 8, tail}
  def decode(<<0x39, tail::binary>>, _options), do: {:ok, 9, tail}

  def decode(<<0x3a, tail::binary>>, _options), do: {:ok, -6, tail}
  def decode(<<0x3b, tail::binary>>, _options), do: {:ok, -5, tail}
  def decode(<<0x3c, tail::binary>>, _options), do: {:ok, -4, tail}
  def decode(<<0x3d, tail::binary>>, _options), do: {:ok, -3, tail}
  def decode(<<0x3e, tail::binary>>, _options), do: {:ok, -2, tail}
  def decode(<<0x3f, tail::binary>>, _options), do: {:ok, -1, tail}

  # todo - incomplete signed integers
  def decode(<<0x20, value::little-signed-size(8), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x21, value::little-signed-size(16), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x22, value::little-signed-size(24), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x23, value::little-signed-size(32), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x24, value::little-signed-size(40), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x25, value::little-signed-size(48), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x26, value::little-signed-size(56), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x27, value::little-signed-size(64), tail::binary>>, _options), do: {:ok, value, tail}

  # todo - incomplete unsigned integers
  def decode(<<0x28, value::little-unsigned-size(8), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x29, value::little-unsigned-size(16), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x2a, value::little-unsigned-size(24), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x2b, value::little-unsigned-size(32), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x2c, value::little-unsigned-size(40), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x2d, value::little-unsigned-size(48), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x2e, value::little-unsigned-size(56), tail::binary>>, _options), do: {:ok, value, tail}
  def decode(<<0x2f, value::little-unsigned-size(64), tail::binary>>, _options), do: {:ok, value, tail}

  # list
  # todo - incomplete list
  # todo - ensure decoded list has the indicated number of items
  def decode(<<0x01, tail::binary>>, _options), do: {:ok, [], tail}

  def decode(<<0x02, length::little-unsigned-size(8), rest::binary>>, _options) do
    list_length = (length - 2) * 8
    <<list::size(list_length), tail::binary>> = rest
    {:ok, DList.decode(<<list::size(list_length)>>), tail}
  end

  def decode(<<0x06, l::little-unsigned-size(8), n::little-unsigned-size(8), 0::size(48), r::binary>>, options) do
    decode(<<0x06, (l - 6)::little-unsigned-size(8), n::little-unsigned-size(8), r::binary>>, options)
  end
  def decode(<<0x06, length::little-unsigned-size(8), number::little-unsigned-size(8), rest::binary>>, _options) do
    list_length = (length - 3 - number) * 8
    index_length = number * 8
    <<list::size(list_length), _index::size(index_length), tail::binary>> = rest
    {:ok, DList.decode(<<list::size(list_length)>>), tail}
  end

  def decode(<<0x07, l::little-unsigned-size(16), n::little-unsigned-size(16), 0::size(32), r::binary>>, options) do
    decode(<<0x07, (l - 4)::little-unsigned-size(16), n::little-unsigned-size(16), r::binary>>, options)
  end
  def decode(<<0x07, length::little-unsigned-size(16), number::little-unsigned-size(16), rest::binary>>, _options) do
    list_length = (length - 5 - (number * 2)) * 8
    index_length = (number * 2) * 8
    <<list::size(list_length), _index::size(index_length), tail::binary>> = rest
    {:ok, DList.decode(<<list::size(list_length)>>), tail}
  end

  # map
  # todo - incomplete map
  # todo - ensure decoded map has the indicated number of itesm
  def decode(<<0x0a, tail:: binary>>, _options), do: {:ok, %{}, tail}

  def decode(<<0x0b, length::little-unsigned-size(8), number::little-unsigned-size(8), rest::binary>>, _options) do
    map_length = (length - 3) * 8
    <<map::size(map_length), tail::binary>> = rest
    {:ok, DMap.decode(<<map::size(map_length)>>, length - 3, number, 8, 0), tail}
  end

  def decode(<<0x0c, length::little-unsigned-size(16), number::little-unsigned-size(16), 0::size(32), rest::binary>>, _options) do
    # credo:disable-for-previous-line Credo.Check.Readability.MaxLineLength
    map_length = (length - 9) * 8
    <<map::size(map_length), tail::binary>> = rest
    {:ok, DMap.decode(<<map::size(map_length)>>, length - 9, number, 16, 4), tail}
  end
  def decode(<<0x0c, length::little-unsigned-size(16), number::little-unsigned-size(16), rest::binary>>, _options) do
    map_length = (length - 5) * 8
    <<map::size(map_length), tail::binary>> = rest
    {:ok, DMap.decode(<<map::size(map_length)>>, length - 5, number, 16, 0), tail}
  end
end
