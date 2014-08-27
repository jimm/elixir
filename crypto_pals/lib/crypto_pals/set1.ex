defmodule CryptoPals.Set1 do

  use Bitwise
  use CryptoPals.Englishness
  use CryptoPals.Hamming
  use CryptoPals.Hex
  require Integer

  # ================ 1 ================

  # See CryptoPals.Hex

  # ================ 2 ================

  # Use :crypto.exor(iodata(), iodata())

  # ================ 3 ================

  @doc """
  Finds best (most "English") match for string s that has been XOR-ed with a
  mystery byte and returns the string.

  ## Examples
      iex> CryptoPals.Set1.single_byte_xor_cipher("1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736")
      "Cooking MC's like a pound of bacon"
  """ # ' <= workaround for Emacs Elixir font lock bug
  def single_byte_xor_cipher(s) do
    b = hex_to_bytes(s)
    (0..255)
      |> Enum.map(&(single_byte_xor_cipher(b, &1)))
      |> Enum.max_by(&englishness/1)
  end

  # Apply byte as XOR key to hex encoded string s and return string.
  defp single_byte_xor_cipher(s, byte) do
    byte
      |> byte_duped_for_xor(String.length(s))
      |> :crypto.exor(s)
  end

  @doc """
  Returns a hex encoded byte string with byte repeated num_bytes times.

  ## Example

      iex> CryptoPals.Set1.byte_duped_for_xor(0, 3)
      <<0, 0, 0>>
      iex> CryptoPals.Set1.byte_duped_for_xor(0xfa, 3)
      <<0xFA, 0xFA, 0xFA>>
  """
  def byte_duped_for_xor(byte, num_bytes) do
    :binary.copy(<<byte>>, num_bytes)
  end

  @doc """
  Turn an int into an even-length base 16 string. A zero is prepended if
  needed to make the string length even.

  ## Examples

      iex> CryptoPals.Set1.even_len_hex_str(0)
      "00"
      iex> CryptoPals.Set1.even_len_hex_str(15)
      "0F"
      iex> CryptoPals.Set1.even_len_hex_str(127)
      "7F"
      iex> CryptoPals.Set1.even_len_hex_str(128)
      "80"
      iex> CryptoPals.Set1.even_len_hex_str(0xdeadbeef)
      "DEADBEEF"
  """
  def even_len_hex_str(n) do
    n
      |> Integer.to_string(16)
      |> leading_zero_if_odd_length
  end
    
  @doc """
  If s has odd length, a new string is returned by prepending a zero to s.

  ## Examples

      iex> CryptoPals.Set1.leading_zero_if_odd_length(    "")
      ""
      iex> CryptoPals.Set1.leading_zero_if_odd_length(   "d")
      "0d"
      iex> CryptoPals.Set1.leading_zero_if_odd_length(  "cd")
      "cd"
      iex> CryptoPals.Set1.leading_zero_if_odd_length( "bcd")
      "0bcd"
      iex> CryptoPals.Set1.leading_zero_if_odd_length("abcd")
      "abcd"
  """
  def leading_zero_if_odd_length(s) do
    if Integer.even?(String.length(s)) do
      s
    else
      "0#{s}"
    end
  end

  # ================ 4 ================

  @doc """
  Find which string has been XOR-ed with a single byte in a file.

  ## Examples

      Commented out, because this takes around 10 seconds to run. It works,
      though.

      # iex> CryptoPals.Set1.find_xored_in_file("data/4.txt")
      # "Now that the party is jumping"

  """
  def find_xored_in_file(path) do
    File.stream!(path)
      |> Stream.map(&best_xored/1)
      |> Enum.max_by(&englishness/1)
      |> String.rstrip
  end

  defp best_xored(line) do
    line
      |> String.rstrip
      |> single_byte_xor_cipher
  end

  # ================ 5 ================

  @doc """
  XORs a string with a key, which may be shorter than the string.

  ## Examples

      iex> CryptoPals.Set1.repeating_key_xor("Burning 'em, if you ain't quick and nimble\\nI go crazy when I hear a cymbal", "ICE")
      "0B3637272A2B2E63622C2E69692A23693A2A3C6324202D623D63343C2A26226324272765272A282B2F20430A652E2C652A3124333A653E2B2027630C692B20283165286326302E27282F"
  """
  def repeating_key_xor(plaintext, key) do
    key = String.duplicate(key, div(String.length(plaintext), String.length(key)) + 1)
    Stream.zip(String.to_char_list(plaintext), String.to_char_list(key))
      |> Stream.map(fn({b0, b1}) -> byte_xor_16(b0, b1) end)
      |> Enum.join
  end

  # Takes two bytes, XORs them, and turns the result into a two-character
  # hex string.
  defp byte_xor_16(b0, b1) do
      b0 ^^^ b1
        |> even_len_hex_str
  end

  # ================ 6 ================

  def break_repeating_key_xor, do: break_repeating_key_xor("data/6.txt")

  @doc """
  Break repeating-key XOR in a file.

  ## Examples

      # iex> CryptoPals.Set1.break_repeating_key_xor("data/6.txt")
      # "???"

  """
  def break_repeating_key_xor(path) do
    data = File.read!(path)
      |> String.replace("\n", "")
      |> Base.decode64!
      |> String.to_char_list
    keysize = likely_keysize(data)
    translated_blocks = data |> Enum.chunk(keysize) |> translate_blocks
    key_bytes = translated_blocks
      |> Enum.map(&single_byte_xor_cipher_byte/1)
      |> Enum.map(fn({cipher_byte, _englishness, _s}) ->
                    IO.puts _englishness
                    IO.puts _s
                    cipher_byte
                  end)
    key = to_string(key_bytes)

    to_string(data)
      |> repeating_key_xor(key)
      |> hex_to_bytes
  end

  @doc """
  Finds best (most "English") match for byte list that has been XOR-ed with
  a mystery byte and returns a tuple containing the byte, englishness
  (fitness) value, and the best match string.

  ## Examples
      iex> CryptoPals.Set1.single_byte_xor_cipher_byte(
      ...>   "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
      ...>     |> CryptoPals.Hex.hex_to_bytes
      ...>     |> String.to_char_list)
      {88, 201/34, "Cooking MC's like a pound of bacon"}
  """ # ' <= work around Emacs font lock bug
  def single_byte_xor_cipher_byte(s) do
    (0..255)
      |> Enum.reduce({0, 0, ""}, fn(byte, {_, e_englishness, _} = acc) ->
                                xored = s |> Enum.map(fn(c) -> c ^^^ byte end)
                                e = englishness(to_string(xored))
                                if e > e_englishness do
                                  {byte, e, to_string(xored)}
                                else
                                  acc
                                end
                     end)
  end

  @doc """
  Return the likely keysize of data. Try various key sizes. For each size,
  take the first two blocks and compute the Hamming distance between. The
  size that has the minimum distance is the likely keysize.
  """
  def likely_keysize(data) do
    (2..40)
      |> Enum.map(&(num_blocks_of_size(data, &1, 2)))
      |> Enum.min_by(fn([block0, block1]) ->
                       div(hamming_distance(block0, block1), length(block0))
                     end)
      |> hd
      |> length
  end

  @doc """
  Make a block that is the first byte of every block, and a block that is
  the second byte of every block, and so on.

  ## Examples

      iex> CryptoPals.Set1.translate_blocks([[1, 2, 3], [4, 5, 6]])
      [[1, 4], [2, 5], [3, 6]]
  """ 
  def translate_blocks(blocks), do: translate_blocks(blocks, [])

  defp translate_blocks([], translated), do: Enum.reverse(translated)
  defp translate_blocks([[]|_], translated), do: Enum.reverse(translated)
  defp translate_blocks(lists, translated) do
    # inefficient (goes through lists twice)
    heads = lists |> Enum.map(fn(l) -> hd(l) end)
    tails = lists |> Enum.map(fn(l) -> tl(l) end)
    translate_blocks(tails, [heads | translated])
  end

  @doc """
  Return a list of num_blocks chunks of data, each of the specified size.

  ## Examples

      iex> CryptoPals.Set1.num_blocks_of_size([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 3, 2)
      [[1, 2, 3], [4, 5, 6]]
  """
  def num_blocks_of_size(data, size, num_blocks) do
    data
      |> Enum.chunk(size)
      |> Enum.take(num_blocks)
  end

  # ================ 7 ================

  # def aes_in_ecb_mode(data, key, mode) do
  #   c = 
  # end

  # ================ helpers ================

  # defp debug(val) when is_binary(val) do
  #   if String.printable?(val) do
  #     IO.puts "** #{val} **"
  #   else
  #     IO.puts "** #{inspect(val)} **"
  #   end
  #   val
  # end

  # defp debug(val) do
  #   IO.puts "** #{inspect(val)} **"
  #   val
  # end

end
