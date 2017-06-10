defmodule VelocyPack.Utils.Hex do
  @moduledoc false

  def to_hex(data, path) when is_binary(data) do
    content = data
      |> :binary.bin_to_list()
      |> Enum.map(&hex_to_string/1)
      |> format_hex_list()

    File.write!(path, content)
  end

  defp format_hex_list(values) do
    {formatted_string, _} = values
      |> Enum.reduce({<<>>, 0}, fn(value, {string, acc}) ->
        case acc do
          15 -> {string <> value <> "\n", 0}
          _ ->
            {string <> value <> " ", acc + 1}
        end
      end)

    formatted_string
  end

  defp hex_to_string(value), do: "0x" <> Base.encode16(<<value>>, case: :lower)
end
