defmodule VelocyPack.Decoder do
  @moduledoc false

  def decode(data, _opts \\ []) when is_binary(data) do
    try do
      do_decode(data)
    catch
      e -> {:error, e}
    else
      {value, <<>>} -> {:ok, value}
      # todo - what to do if multiple values are returned?  tuple?
      _ -> {:error, "what do i do?"}
    end
  end

  # atom
  defp do_decode(<<0x18, tail::binary>>), do: {nil, tail}
  defp do_decode(<<0x19, tail::binary>>), do: {false, tail}
  defp do_decode(<<0x1A, tail::binary>>), do: {true, tail}
end
