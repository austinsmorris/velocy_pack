defmodule VelocyPack.Encode do
  @moduledoc false

  alias VelocyPack.Encoder

  def encode(value, _opts \\ []) do
    {:ok, do_encode(value)}
  end

  def encode_with_size(value, _opts \\ []) do
    {:ok, do_encode_with_size(value)}
  end

  def encode_atom(value) when is_atom(value), do: do_encode_atom(value)

  def encode_atom_with_size(value) when is_atom(value), do: do_encode_atom_with_size(value)

  def encode_integer(value) when is_integer(value), do: do_encode_integer(value)

  def encode_integer_with_size(value) when is_integer(value), do: do_encode_integer_with_size(value)

  def encode_string(value) when is_binary(value), do: do_encode_string(value)

  def encode_string_with_size(value) when is_binary(value), do: do_encode_string_with_size(value)

  def encode_float(value) when is_float(value), do: do_encode_float(value)

  def encode_float_with_size(value) when is_float(value), do: do_encode_float_with_size(value)

  def encode_list(value) when is_list(value), do: do_encode_list(value)

  def encode_list_with_size(value) when is_list(value), do: do_encode_list_with_size(value)

  def encode_map(value) when is_map(value), do: do_encode_map(value)

  def encode_map_with_size(value) when is_map(value), do: do_encode_map_with_size(value)

  defp do_encode(value) when is_atom(value), do: do_encode_atom(value)
  defp do_encode(value) when is_integer(value), do: do_encode_integer(value)
  defp do_encode(value) when is_binary(value), do: do_encode_string(value)
  defp do_encode(value) when is_float(value), do: do_encode_float(value)
  defp do_encode(value) when is_list(value), do: do_encode_list(value)
  # defp do_encode(%{__struct__: module} = value), do: do_encode_struct(value, module)
  defp do_encode(value) when is_map(value), do: do_encode_map(value)
  # defp do_encode(value) when is_map(value), do: encode_map.(value, escape, encode_map)
  defp do_encode(value), do: Encoder.encode(value)

  defp do_encode_with_size(value) when is_atom(value), do: do_encode_atom_with_size(value)
  defp do_encode_with_size(value) when is_integer(value), do: do_encode_integer_with_size(value)
  defp do_encode_with_size(value) when is_binary(value), do: do_encode_string_with_size(value)
  defp do_encode_with_size(value) when is_float(value), do: do_encode_float_with_size(value)
  defp do_encode_with_size(value) when is_list(value), do: do_encode_list_with_size(value)
  # defp do_encode(%{__struct__: module} = value), do: do_encode_struct(value, module)
  defp do_encode_with_size(value) when is_map(value), do: do_encode_map_with_size(value)
  # defp do_encode(value) when is_map(value), do: encode_map.(value, escape, encode_map)
  defp do_encode_with_size(value), do: Encoder.encode(value)

  defp do_encode_atom(nil), do: 0x18
  defp do_encode_atom(false), do: 0x19
  defp do_encode_atom(true), do: 0x1A
  defp do_encode_atom(value), do: value |> Atom.to_string() |> do_encode_string()

  defp do_encode_atom_with_size(nil), do: {0x18, 1}
  defp do_encode_atom_with_size(false), do: {0x19, 1}
  defp do_encode_atom_with_size(true), do: {0x1A, 1}
  defp do_encode_atom_with_size(value), do: value |> Atom.to_string() |> do_encode_string_with_size()

  defp do_encode_integer(0), do: 0x30
  defp do_encode_integer(1), do: 0x31
  defp do_encode_integer(2), do: 0x32
  defp do_encode_integer(3), do: 0x33
  defp do_encode_integer(4), do: 0x34
  defp do_encode_integer(5), do: 0x35
  defp do_encode_integer(6), do: 0x36
  defp do_encode_integer(7), do: 0x37
  defp do_encode_integer(8), do: 0x38
  defp do_encode_integer(9), do: 0x39
  defp do_encode_integer(-6), do: 0x3A
  defp do_encode_integer(-5), do: 0x3B
  defp do_encode_integer(-4), do: 0x3C
  defp do_encode_integer(-3), do: 0x3D
  defp do_encode_integer(-2), do: 0x3E
  defp do_encode_integer(-1), do: 0x3F

  defp do_encode_integer(value) when value < -9_223_372_036_854_775_808 do
    # todo - use a proper error type
    raise "Cannot encode integers less than -9_223_372_036_854_775_808."
  end

  defp do_encode_integer(value) when value < -36_028_797_018_963_968, do: <<0x27, value::little-signed-size(64)>>
  defp do_encode_integer(value) when value < -140_737_488_355_328, do: <<0x26, value::little-signed-size(56)>>
  defp do_encode_integer(value) when value < -549_755_813_888, do: <<0x25, value::little-signed-size(48)>>
  defp do_encode_integer(value) when value < -2_147_483_648, do: <<0x24, value::little-signed-size(40)>>
  defp do_encode_integer(value) when value < -8_388_608, do: <<0x23, value::little-signed-size(32)>>
  defp do_encode_integer(value) when value < -32_768, do: <<0x22, value::little-signed-size(24)>>
  defp do_encode_integer(value) when value < -128, do: <<0x21, value::little-signed-size(16)>>
  defp do_encode_integer(value) when value < 0, do: <<0x20, value::little-signed-size(8)>>
  defp do_encode_integer(value) when value <= 255, do: <<0x28, value::little-unsigned-size(8)>>
  defp do_encode_integer(value) when value <= 65_535, do: <<0x29, value::little-unsigned-size(16)>>
  defp do_encode_integer(value) when value <= 16_777_215, do: <<0x2A, value::little-unsigned-size(24)>>
  defp do_encode_integer(value) when value <= 4_294_967_295, do: <<0x2B, value::little-unsigned-size(32)>>
  defp do_encode_integer(value) when value <= 1_099_511_627_775, do: <<0x2C, value::little-unsigned-size(40)>>
  defp do_encode_integer(value) when value <= 281_474_976_710_655, do: <<0x2D, value::little-unsigned-size(48)>>
  defp do_encode_integer(value) when value <= 72_057_594_037_927_935, do: <<0x2E, value::little-unsigned-size(56)>>
  defp do_encode_integer(value) when value <= 18_446_744_073_709_551_615, do: <<0x2F, value::little-unsigned-size(64)>>

  defp do_encode_integer(_) do
    # todo - use a proper error type
    raise "Cannot encode integers greater than 18_446_744_073_709_551_615."
  end

  defp do_encode_integer_with_size(0), do: {0x30, 1}
  defp do_encode_integer_with_size(1), do: {0x31, 1}
  defp do_encode_integer_with_size(2), do: {0x32, 1}
  defp do_encode_integer_with_size(3), do: {0x33, 1}
  defp do_encode_integer_with_size(4), do: {0x34, 1}
  defp do_encode_integer_with_size(5), do: {0x35, 1}
  defp do_encode_integer_with_size(6), do: {0x36, 1}
  defp do_encode_integer_with_size(7), do: {0x37, 1}
  defp do_encode_integer_with_size(8), do: {0x38, 1}
  defp do_encode_integer_with_size(9), do: {0x39, 1}
  defp do_encode_integer_with_size(-6), do: {0x3A, 1}
  defp do_encode_integer_with_size(-5), do: {0x3B, 1}
  defp do_encode_integer_with_size(-4), do: {0x3C, 1}
  defp do_encode_integer_with_size(-3), do: {0x3D, 1}
  defp do_encode_integer_with_size(-2), do: {0x3E, 1}
  defp do_encode_integer_with_size(-1), do: {0x3F, 1}

  defp do_encode_integer_with_size(value) when value < -9_223_372_036_854_775_808 do
    # todo - use a proper error type
    raise "Cannot encode integers less than -9_223_372_036_854_775_808."
  end

  defp do_encode_integer_with_size(value) when value < -36_028_797_018_963_968 do
    {<<0x27, value::little-signed-size(64)>>, 9}
  end

  defp do_encode_integer_with_size(value) when value < -140_737_488_355_328 do
    {<<0x26, value::little-signed-size(56)>>, 8}
  end

  defp do_encode_integer_with_size(value) when value < -549_755_813_888 do
    {<<0x25, value::little-signed-size(48)>>, 7}
  end

  defp do_encode_integer_with_size(value) when value < -2_147_483_648, do: {<<0x24, value::little-signed-size(40)>>, 6}
  defp do_encode_integer_with_size(value) when value < -8_388_608, do: {<<0x23, value::little-signed-size(32)>>, 5}
  defp do_encode_integer_with_size(value) when value < -32_768, do: {<<0x22, value::little-signed-size(24)>>, 4}
  defp do_encode_integer_with_size(value) when value < -128, do: {<<0x21, value::little-signed-size(16)>>, 3}
  defp do_encode_integer_with_size(value) when value < 0, do: {<<0x20, value::little-signed-size(8)>>, 2}
  defp do_encode_integer_with_size(value) when value <= 255, do: {<<0x28, value::little-unsigned-size(8)>>, 2}
  defp do_encode_integer_with_size(value) when value <= 65_535, do: {<<0x29, value::little-unsigned-size(16)>>, 3}
  defp do_encode_integer_with_size(value) when value <= 16_777_215, do: {<<0x2A, value::little-unsigned-size(24)>>, 4}

  defp do_encode_integer_with_size(value) when value <= 4_294_967_295 do
    {<<0x2B, value::little-unsigned-size(32)>>, 5}
  end

  defp do_encode_integer_with_size(value) when value <= 1_099_511_627_775 do
    {<<0x2C, value::little-unsigned-size(40)>>, 6}
  end

  defp do_encode_integer_with_size(value) when value <= 281_474_976_710_655 do
    {<<0x2D, value::little-unsigned-size(48)>>, 7}
  end

  defp do_encode_integer_with_size(value) when value <= 72_057_594_037_927_935 do
    {<<0x2E, value::little-unsigned-size(56)>>, 8}
  end

  defp do_encode_integer_with_size(value) when value <= 18_446_744_073_709_551_615 do
    {<<0x2F, value::little-unsigned-size(64)>>, 9}
  end

  defp do_encode_integer_with_size(_) do
    # todo - use a proper error type
    raise "Cannot encode integers greater than 18_446_744_073_709_551_615."
  end

  defp do_encode_string(<<>>), do: 0x40

  defp do_encode_string(value) when is_binary(value) and byte_size(value) <= 126 do
    <<byte_size(value) + 0x40, value::binary>>
  end

  defp do_encode_string(value) when is_binary(value) do
    <<0xBF, byte_size(value)::little-unsigned-size(64), value::binary>>
  end

  defp do_encode_string_with_size(<<>>), do: {0x40, 1}

  defp do_encode_string_with_size(value) when is_binary(value) and byte_size(value) <= 126 do
    size = byte_size(value)
    {<<size + 0x40, value::binary>>, size + 1}
  end

  defp do_encode_string_with_size(value) when is_binary(value) do
    size = byte_size(value)
    {<<0xBF, size::little-unsigned-size(64), value::binary>>, size + 8 + 1}
  end

  defp do_encode_float(_value) do
  end

  defp do_encode_float_with_size(_value) do
  end

  defp do_encode_list([]), do: 0x01

  defp do_encode_list(value) do
    {list_size, nritems, reversed_list_with_sizes} =
      Enum.reduce(value, {0, 0, []}, fn v, {ls, n, rlws} ->
        {item, size} = Encoder.encode_with_size(v)
        {ls + size, n + 1, [{item, size} | rlws]}
      end)

    create_list_with_index_table({list_size, nritems, reversed_list_with_sizes})
  end

  defp do_encode_list_with_size([]), do: {0x01, 1}

  defp do_encode_list_with_size(value) do
    encoded = Encoder.encode(value)
    {encoded, get_encoded_size(encoded)}
  end

  defp do_encode_map(%{} = map) when map === %{}, do: 0x0A

  defp do_encode_map(value) do
    {total_size, nr_items, reversed_list_with_sizes} =
      Enum.reduce(value, {0, 0, []}, fn {k, v}, {ls, n, rlws} ->
        {key, key_size} = Encoder.encode_with_size(k)
        {value, value_size} = Encoder.encode_with_size(v)
        {ls + key_size + value_size, n + 1, [{{key, key_size}, {value, value_size}} | rlws]}
      end)

    create_map_with_index_table(total_size, nr_items, reversed_list_with_sizes)
  end

  defp do_encode_map_with_size(%{}), do: {0x0A, 1}

  defp do_encode_map_with_size(value) do
    encoded = Encoder.encode(value)
    {encoded, get_encoded_size(encoded)}
  end

  # helpers
  # todo - when nritems/list_size? - other list types
  defp create_list_with_index_table({list_size, nritems, reversed_list_with_sizes}) do
    {list, index_table, _} =
      Enum.reduce(
        reversed_list_with_sizes,
        {[], [], list_size + 3},
        fn {item, size}, {l, it, acc} ->
          {[item | l], [acc - size | it], acc - size}
        end
      )

    [
      0x06,
      <<list_size + nritems + 3::little-unsigned-size(8)>>,
      <<nritems::little-unsigned-size(8)>>,
      list,
      index_table
    ]
  end

  # todo - when nritems/list_size? - other map types
  defp create_map_with_index_table(total_size, nritems, reversed_list_with_sizes) do
    {map, index_table, _} =
      Enum.reduce(
        reversed_list_with_sizes,
        {[], [], total_size + 3},
        fn {{key, key_size}, {value, value_size}}, {iodata, it, acc} ->
          {[[key, value] | iodata], [acc - key_size - value_size | it], acc - key_size - value_size}
        end
      )

    # todo = sort the index table by key
    [
      0x0B,
      <<total_size + nritems + 3::little-unsigned-size(8)>>,
      <<nritems::little-unsigned-size(8)>>,
      map,
      index_table
    ]
  end

  defp get_encoded_size([0x06, <<size::little-unsigned-size(8)>> | _]), do: size
  defp get_encoded_size([0x0B, <<size::little-unsigned-size(8)>> | _]), do: size
end
