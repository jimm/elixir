defmodule CryptoPals.Set1 do

  use Bitwise
  alias CryptoPals.{Englishness, Hamming}
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
      iex> CryptoPals.Set1.single_byte_xor_cipher(
      ...>   "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
      ...> )
      "Cooking MC's like a pound of bacon"
  """
  def single_byte_xor_cipher(s) do
    b = hex_to_bytes(s)
    (0..255)
    |> Enum.map(&(single_byte_xor_cipher(b, &1)))
    |> Enum.max_by(&Englishness.englishness/1)
  end

  # Apply byte as XOR key to hex encoded string s and return string.
  defp single_byte_xor_cipher(s, byte) do
    byte
    |> byte_duped_for_xor(byte_size(s))
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
    n |> Integer.to_string(16) |> leading_zero_if_odd_length
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
    if Integer.is_even(String.length(s)) do
      s
    else
      "0#{s}"
    end
  end

  # ================ 4 ================

  @doc """
  Find which string has been XOR-ed with a single byte in a file.

  ## Examples

      iex> CryptoPals.Set1.find_xored_in_file("data/4.txt")
      "Now that the party is jumping"

  """
  def find_xored_in_file(path) do
    File.stream!(path)
    |> Stream.map(&best_xored/1)
    |> Enum.max_by(&Englishness.englishness/1)
    |> String.trim_trailing
  end

  defp best_xored(line) do
    line |> String.trim_trailing |> single_byte_xor_cipher
  end

  # ================ 5 ================

  @doc """
  XORs a string with a key, which may be shorter than the string.

  ## Examples

      iex> CryptoPals.Set1.repeating_key_xor(
      ...>   String.to_charlist("Burning 'em, if you ain't quick and nimble\\nI go crazy when I hear a cymbal"),
      ...>   String.to_charlist("ICE")
      ...> ) |> Enum.map(&CryptoPals.Set1.even_len_hex_str/1) |> Enum.join
      "0B3637272A2B2E63622C2E69692A23693A2A3C6324202D623D63343C2A26226324272765272A282B2F20430A652E2C652A3124333A653E2B2027630C692B20283165286326302E27282F"
  """
  @spec repeating_key_xor(String.t(), String.t()) :: String.t()
  def repeating_key_xor(plaintext, key) do
    Stream.zip(to_charlist(plaintext), Stream.cycle(to_charlist(key)))
    |> Enum.map(fn({b0, b1}) -> b0 ^^^ b1 end)
  end

  # ================ 6 ================

  @doc """
  Break repeating-key XOR in a file, i.e. Vigenere.

  ## Examples

      iex> CryptoPals.Set1.break_repeating_key_xor_from_file("data/6.txt")
      ...>   |> String.split("\\n") |> hd
      "I'm back and I'm ringin' the bell "
  """
  @spec break_repeating_key_xor_from_file(String.t()) :: String.t()
  def break_repeating_key_xor_from_file(path) do
    data = binary_from_ascii_lines(path)
    |> to_string
    |> Base.decode64!
    likely_keysizes(data, 2, 40, 4)
      |> Enum.map(fn(keysize) -> keysize |> break_repeating_key_xor(data) |> to_string end)
      |> Enum.max_by(&Englishness.englishness/1)
  end

  @spec break_repeating_key_xor(integer, binary) :: String.t()
  defp break_repeating_key_xor(keysize, data) do
    byte_list = :binary.bin_to_list(data) 
    key =
      byte_list
      |> Enum.chunk_every(keysize)
      |> rotate_blocks
      |> Enum.map(fn(block) -> {b, _, _} = single_byte_xor_cipher_byte(block); b end)
      |> to_string

    data
    |> to_string
    |> repeating_key_xor(to_string(key))
  end

  @doc """
  Finds best (most "English") match for byte list that has been XOR-ed with
  a mystery byte and returns a tuple containing the byte, englishness
  (fitness) value, and the best match string.

  ## Examples
      iex> CryptoPals.Set1.single_byte_xor_cipher_byte(
      ...>   "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
      ...>   |> CryptoPals.Hex.hex_to_bytes
      ...>   |> String.to_charlist
      ...> )
      {88, 201/34, "Cooking MC's like a pound of bacon"}
  """
  def single_byte_xor_cipher_byte(s) do
    (0..255)
    |> Enum.reduce({0, 0, ""}, fn(byte, {_, e_englishness, _} = acc) ->
      xored = s |> Enum.map(fn(c) -> c ^^^ byte end)
    e = Englishness.englishness(to_string(xored))
      if e > e_englishness do
        {byte, e, to_string(xored)}
      else
        acc
      end
    end)
  end

  @doc """
  Return a list of the likely keysizes of `data`. Try key sizes between
  `min_keylen` and `max_keylen` inclusive. For each size, take the first
  `num_blocks` blocks and compute the Hamming distance between all of them.
  Smaller minimum distances are likely keysizes.

  ## Examples
      iex> CryptoPals.Set1.likely_keysizes(:binary.list_to_bin('abcdabcdefghefghijklijkl')) |> hd
      4
  """
  def likely_keysizes(data, min_keylen \\ 2, max_keylen \\ 40, num_blocks \\ 2) do
    max_keylen = min(max_keylen, div(byte_size(data), 2))
    (min_keylen..max_keylen)
    |> Enum.sort_by(fn(keylen) ->
        blocks = num_blocks_of_size(data, keylen, num_blocks)
        blocks
          |> pairs
          |> Enum.map(fn([b0, b1]) -> div(Hamming.distance(b0, b1), keylen) end)
          |> Enum.sum
      end)
    |> Enum.take(4)
  end

  @doc """
  Make a block that is the first byte of every block, and a block that is
  the second byte of every block, and so on.

  ## Examples

      iex> CryptoPals.Set1.rotate_blocks([[1, 2, 3], [4, 5, 6], [7, 8]])
      [[1, 4, 7], [2, 5, 8], [3, 6]]
      iex> CryptoPals.Set1.rotate_blocks([[1, 4, 7], [2, 5, 8], [3, 6]])
      [[1, 2, 3], [4, 5, 6], [7, 8]]
      
  """ 
  def rotate_blocks(blocks), do: rotate_blocks(Enum.reverse(blocks), [])

  defp rotate_blocks([], rotated) do
    Enum.reverse(rotated |> Enum.map(&Enum.reverse/1))
  end
  defp rotate_blocks([[]|t], rotated) do
    rotate_blocks(t, rotated)
  end
  defp rotate_blocks(lists, rotated) do
    # inefficient (goes through lists twice)
    heads = lists |> Enum.map(fn(l) -> hd(l) end)
    tails = lists |> Enum.map(fn(l) -> tl(l) end)
    rotate_blocks(tails, [heads | rotated])
  end

  @doc """
  Return a list of num_blocks chunks of data, each of the specified size.

  ## Examples

      iex> CryptoPals.Set1.num_blocks_of_size([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 3, 2)
      [[1, 2, 3], [4, 5, 6]]
      iex> CryptoPals.Set1.num_blocks_of_size(<<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12>>, 3, 2)
      [<<1, 2, 3>>, <<4, 5, 6>>]
  """
  def num_blocks_of_size(data, size, num_blocks) when is_binary(data) do
    data
    |> :binary.bin_to_list
    |> num_blocks_of_size(size, num_blocks)
    |> Enum.map(&:binary.list_to_bin/1)
  end

  def num_blocks_of_size(data, size, num_blocks) do
    data
    |> Stream.chunk_every(size)
    |> Enum.take(num_blocks)
  end

  @doc """
  Returns all combinations of pairs of items in a list.

  ## Examples

      iex> CryptoPals.Set1.pairs([1, 2, 3, 4])
      [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
  """
  def pairs(list), do: pairs(list, [])

  defp pairs([], acc), do: Enum.reverse(acc)
  defp pairs([_], acc), do: Enum.reverse(acc)
  defp pairs([h|t], acc) when is_list(t) do
    pairwise = Enum.map(t, &([h, &1]))
    pairs(t, Enum.reverse(pairwise) ++ acc)
  end
  defp pairs([h|t], acc) do
    pairs(t, [[h,t]|acc])
  end

  # ================ 7 ================

  @doc """
  ## Examples

      iex> CryptoPals.Set1.aes_in_ecb_mode_from_file("data/7.txt")
      ...>   String.split("\\n") |> hd
      "I'm back and I'm ringin' the bell "
  """
  def aes_in_ecb_mode_from_file(path) do
    data = binary_from_ascii_lines(path)
    key = "YELLOW SUBMARINE"
    aes_in_ecb_mode(data, key, :decrypt)
  end

  def aes_in_ecb_mode(data, key, :decrypt) do
    iv = <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>
    :crypto.crypto_one_time(:aes_128_ecb, key, iv, data, false)
  end

  # ================ helpers ================

  @spec binary_from_ascii_lines(String.t()) :: binary
  defp binary_from_ascii_lines(path) do
    File.read!(path)
    |> String.replace("\n", "")
  end
end
