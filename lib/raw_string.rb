require "base64"

class RawString
  attr_reader :value

  def initialize(str)
    @value = str
  end

  # XORs two raw strings. The shortest string acts as key.
  # Input: raw string: what to XOR against
  # Output: raw string: the XORed output
  def ^(raw_string)
    bytes1 = self.value.bytes
    bytes2 = raw_string.value.bytes

    bytes1, bytes2 = bytes2, bytes1 if bytes1.length < bytes2.length

    res = Array.new(bytes1.length) { |i| bytes1[i] ^ bytes2[i % bytes2.length] }
    res = bytes_to_chars(res)
    RawString.new(res)
  end
  alias :xor :^

  # Output: base64 encoded string
  def to_b64
    Base64.strict_encode64(@value)
  end

  # Output: hex encoded string
  def to_hex
    @value.unpack("H*").join
  end

  private

  def bytes_to_chars(obj)
    obj.pack("c*")
  end
end

class String
  def to_raw
    RawString.new(self)
  end

  def hex_to_raw
    RawString.new([self].pack("H*"))
  end

  def b64_to_raw
    RawString.new(Base64.strict_decode64(str))
  end
end
