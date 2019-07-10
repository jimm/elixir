defmodule CryptoPals.Hex do

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc """
  Converts a hex encoded byte string into a base64 string.

  ## Examples

      iex> CryptoPals.Set1.hex_to_base64("deadbeef")
      "w57CrcK+w68="
      iex> CryptoPals.Set1.hex_to_base64("49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d")
      "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
  """
  def hex_to_base64(s) do
    s |> hex_to_bytes |> Base.encode64
  end

  @doc """
  Converts a hex encoded byte string into a string where each character is
  the eight-bit character corresponding to the two-digit hex number.

  ## Examples

      iex> CryptoPals.Set1.hex_to_bytes("deadbeef")
      <<0xde, 0xad, 0xbe, 0xef>>
  """
  def hex_to_bytes(s), do: hex_to_bytes(s, [])

  defp hex_to_bytes(<<>>, out) do
    out |> Enum.reverse |> to_string
  end

  defp hex_to_bytes(<<b0, b1>> <> rest, out) do
    n = String.to_integer(<<b0, b1>>, 16)
    hex_to_bytes(rest, [n | out])
  end

  def base64_to_bytes(s) do
    s |> Base.decode64!
  end
end       
