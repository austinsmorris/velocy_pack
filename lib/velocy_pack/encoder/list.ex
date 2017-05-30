defimpl VelocyPack.Encoder, for: List do
  alias VelocyPack.Encoder

  def encode([], _), do: [0x01]
  def encode(value, options) do
    {list_size, nritems, reversed_list_with_sizes} = Enum.reduce(value, {0, 0, []}, fn(v, {ls, n, rlws}) ->
      {item, size} = Encoder.encode_with_size(v, options)
      {ls + size, n + 1, [{item, size} | rlws]}
    end)

    create_list_with_index_table({list_size, nritems, reversed_list_with_sizes})
  end

  def encode_with_size([], _), do: {0x01, 1}
  def encode_with_size(value, options) do
    encoded = Encoder.encode(value, options)
    {encoded, get_encoded_size(encoded)}
  end

  defp create_list_with_index_table({list_size, nritems, reversed_list_with_sizes}) do # todo - when nritems/list_size?
    {list, index_table, _} = Enum.reduce(reversed_list_with_sizes, {[], [], list_size + 3}, fn({item, size}, {l, it, acc}) ->
      {[item | l], [acc - size | it], acc - size}
    end)
    [0x06, <<(list_size + nritems + 3)::little-unsigned-size(8)>>, <<nritems::little-unsigned-size(8)>>, list, index_table]
  end

  defp get_encoded_size([0x06, <<size::little-unsigned-size(8)>> | _]), do: size
end
