require 'block'
require "base64"

class RawString
  attr_reader :value

  def initialize(obj)
    @value = str(obj)
  end

  def append(raw_string)
    RawString.new(@value + raw_string.value)
  end

  # XORs two raw strings. The shortest string acts as key.
  # Input 1, option 1: raw string: key: what to XOR against
  # Input 1, option 2: string: key: what to XOR against
  # Input 1, option 3: byte array: key: what to XOR against
  # Output: raw string: the XORed output
  def ^(obj)
    bytes1 = @value.bytes
    bytes2 = bytes(obj)

    bytes1, bytes2 = bytes2, bytes1 if bytes1.length < bytes2.length

    res = Array.new(bytes1.length) { |i| bytes1[i] ^ bytes2[i % bytes2.length] }
    res = bytes_to_chars(res)
    res.to_raw
  end
  alias :xor :^

  # Calculates the hamming distance between two strings.
  # The distance increases by 1 for every bit where the two strings differ.
  # Input 1, option 1: raw string: key: what to XOR against
  # Input 1, option 2: string: key: what to XOR against
  # Input 1, option 3: byte array: key: what to XOR against
  # Output: raw string: the XORed output
  def hamming_dist(obj)
    a_bits = @value.unpack("B*").join.chars
    b_bits = str(obj).unpack("B*").join.chars

    length_dist = (a_bits.length - b_bits.length).abs
    a_bits, b_bits = b_bits, a_bits if length_dist > 0

    a_bits[0, b_bits.length].zip(b_bits).reduce(0) do |sum, values|
      sum + (values[0] == values[1] ? 0 : 1)
    end => diff_dist

    diff_dist + length_dist
  end

  # Strict => no line feeds are added
  # Output: base64 encoded string
  def to_b64(strict: false)
    if strict
      Base64.strict_encode64(@value)
    else
      Base64.encode64(@value)
    end
  end

  # Output: hex encoded string
  def to_hex
    @value.unpack("H*").join
  end

  # Input 1, option 1: raw string: key: the key
  # Input 1, option 2: string: key: the key
  # Input 1, option 3: byte array: key: the key
  # Output: raw string: bytes: the encrypted message
  def encrypt_aes_ecb(key)
    key_str = str(key)

    msg = @value
    if msg.length % 16 > 0
      msg = pad(msg.bytes, 16)
      msg = bytes_to_chars(msg)
    end

    _encrypt_aes_ecb(msg, key_str)
  end

  # Input 1, option 1: raw string: key: the key
  # Input 1, option 2: string: key: the key
  # Input 1, option 3: byte array: key: the key
  # Input: boolean: padding: should messages be padded automatically? true/false
  # Output: raw string: bytes: the decrypted message
  def decrypt_aes_ecb(key, padding: false)
    key_str = str(key)

    data = @value
    if padding
      data = pad(data.bytes, 16)
      data = bytes_to_chars(data)
    end

    _decrypt_aes_ecb(data, key_str)
  end

  # Output: boolean: true if there is an indication that AES ECB encryption is used
  def aes_ecb?
    guess_ecb(@value)
  end

  # Input 1, option 1: raw string: key: the key
  # Input 1, option 2: string: key: the key
  # Input 1, option 3: byte array: key: the key
  #
  # Input 2, option 1: raw string: iv: the iv
  # Input 2, option 2: string: iv: the iv
  # Input 2, option 3: byte array: iv: the iv
  #
  # Output: raw string: bytes: the encrypted message
  def encrypt_aes_cbc(key, iv)
    key_str = str(key)
    iv_str = str(iv)

    msg = @value
    if msg.length % 16 > 0
      msg = pad(msg.bytes, 16)
      msg = bytes_to_chars(msg)
    end

    _encrypt_aes_cbc(msg, key_str, iv_str)
  end

  # Input 1, option 1: raw string: key: the key
  # Input 1, option 2: string: key: the key
  # Input 1, option 3: byte array: key: the key
  #
  # Input 2, option 1: raw string: iv: the iv
  # Input 2, option 2: string: iv: the iv
  # Input 2, option 3: byte array: iv: the iv
  #
  # Input: boolean: padding: should messages be padded automatically? true/false
  # Output: raw string: bytes: the decrypted message
  def decrypt_aes_cbc(key, iv, padding: false)
    key_str = str(key)
    iv_str = str(iv)

    data = @value
    if padding
      data = pad(data.bytes, 16)
      data = bytes_to_chars(data)
    end

    _decrypt_aes_cbc(data, key_str, iv_str)
  end

  def length
    @value.length
  end
  alias :size :length
  alias :count :length

  private

  def bytes_to_chars(obj)
    obj.pack("c*")
  end

  def str(obj)
    if obj.is_a?(RawString)
      obj.value
    elsif obj.is_a?(String)
      obj
    elsif obj.is_a?(Array)
      bytes_to_chars(obj)
    end
  end

  def bytes(obj)
    if obj.is_a?(RawString)
      obj.value.bytes
    elsif obj.is_a?(String)
      obj.bytes
    elsif obj.is_a?(Array)
      obj
    end
  end
end

class String
  def to_raw
    RawString.new(self)
  end

  def hex_to_raw
    RawString.new([self].pack("H*"))
  end

  def b64_to_raw(strict: false)
    b64 = if strict
            Base64.strict_decode64(self)
          else
            Base64.decode64(self)
          end

    RawString.new(b64)
  end
end
