defimpl VelocyPack.Encoder, for: Atom do
  @moduledoc """
  Implementation of the VelocyPack.Encoder protocol for Atom.
  """

  alias VelocyPack.Encode

  def encode(value, _opts), do: Encode.encode_atom(value)

  def encode_with_size(value, _opts), do: Encode.encode_atom_with_size(value)
end
