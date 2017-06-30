defimpl VelocyPack.Encoder, for: Map do
  alias VelocyPack.Encoder

  def encode(%{} = map, _) when map === %{}, do: [0x0a]
  def encode(value, options) do
    {total_size, nritems, reversed_list_with_sizes} = Enum.reduce(value, {0, 0, []}, fn({k, v}, {ls, n, rlws}) ->
      {key, key_size} = Encoder.encode_with_size(k, options)
      {value, value_size} = Encoder.encode_with_size(v, options)
      {ls + key_size + value_size, n + 1, [{{key, key_size}, {value, value_size}} | rlws]}
    end)

    create_map_with_index_table(total_size, nritems, reversed_list_with_sizes)
  end

  def encode_with_size(%{} = map, _) when map === %{}, do: {0x0a, 1}
  def encode_with_size(value, options) do
    encoded = Encoder.encode(value, options)
    {encoded, get_encoded_size(encoded)}
  end

  defp create_map_with_index_table(total_size, nritems, reversed_list_with_sizes) do # todo - when nritems/list_size?
    {map, index_table, _} = Enum.reduce(
      reversed_list_with_sizes,
      {[], [], total_size + 3},
      fn({{key, key_size}, {value, value_size}}, {iodata, it, acc}) ->
        {[[key, value] | iodata], [acc - key_size - value_size | it], acc - key_size - value_size}
      end
    )

    # todo = sort the index table by key
    [
      0x0b,
      <<(total_size + nritems + 3)::little-unsigned-size(8)>>,
      <<nritems::little-unsigned-size(8)>>,
      map,
      index_table
    ]
  end

  defp get_encoded_size([0x0b, <<size::little-unsigned-size(8)>> | _]), do: size
end
