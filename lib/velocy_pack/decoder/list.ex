defmodule VelocyPack.Decoder.List do
  @moduledoc false

  use Bitwise, skip_operators: true

  def decode(list), do: do_decode(list, [])

  def decode(list, list_bit_size), do: do_decode_compact_list(list, list_bit_size)

  def get_compact_list_sizes(list), do: do_get_compact_list_sizes(list, 0, {0, 0})

  defp do_decode(list, values) do
    case VelocyPack.decode(list) do
      {:ok, value, ""} -> [value | values] |> Enum.reverse
      {:ok, value, tail} -> do_decode(tail, [value | values])
    end
  end

  defp do_decode_compact_list(list, list_bit_size) do
    new_list_bit_size = list_bit_size - 8
    <<items::size(new_list_bit_size), number>> = list
    case <<number>> do
      <<0::1, _value::7>> -> decode(<<items::size(new_list_bit_size)>>)
      <<1::1, _value::7>> -> do_decode_compact_list(<<items::size(new_list_bit_size)>>, new_list_bit_size)
    end
  end

  defp do_get_compact_list_sizes(<<0::1, value::7, _tail::binary>>, shift, {list_bytes_acc, size_bytes_acc}) do
    {Bitwise.bsl(value, shift) + list_bytes_acc, size_bytes_acc + 1}
  end
  defp do_get_compact_list_sizes(<<1::1, value::7, tail::binary>>, shift, {list_bytes_acc, size_bytes_acc}) do
    do_get_compact_list_sizes(tail, shift + 7, {Bitwise.bsl(value, shift) + list_bytes_acc, size_bytes_acc + 1})
  end
end
