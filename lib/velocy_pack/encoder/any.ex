defimpl VelocyPack.Encoder, for: Any do
  @moduledoc """
  Implementation of the VelocyPack.Encoder protocol for Any.
  """

  # todo - implement for Any
  def encode(_value, _opts), do: <<>>

  # todo - implement for Any
  def encode_with_size(_value, _opts), do: <<>>
end
