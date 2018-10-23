defprotocol VelocyPack.Encoder do
  @moduledoc false

  @fallback_to_any true

  @spec encode(term, Keyword.t()) :: iodata
  def encode(value, opts \\ [])

  @spec encode_with_size(term, Keyword.t()) :: {iodata, integer}
  def encode_with_size(value, opts \\ [])
end
