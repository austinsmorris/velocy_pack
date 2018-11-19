defmodule VelocyPack.Decoder do
  @moduledoc false

  def decode(data, _opts \\ []) when is_binary(data) do
    try do
      do_decode(data)
    catch
      e -> {:error, e}
    else
      {value, ""} -> {:ok, value}
      # todo - what to do if multiple values are returned?  tuple?
      _ -> {:error, "what do i do?"}
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

  # map
  defp do_decode(<<0x0A, tail::binary>>), do: {%{}, tail}
end
