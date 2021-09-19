require "openssl"
require_relative "raw_string"
require_relative "xor"

# Pads a byte array to an appropriate length
# Output: byte array: the input but with appropriate padding
def pad(bytes, blocklength)
  padding_left = bytes.length % blocklength

  if padding_left > 0
    diff = blocklength - padding_left

    return bytes + [diff]*diff
  end

  bytes
end

# Takes two objects, be it raw strings, strings, or byte arrays.
# Outputs a string of the two XOR:ed together.
# Fairly naive and does not take length into consideration.
# If the second object is shorter than the first object then
# this is treated like a key XOR.
def _xor(obj1, obj2)
  (RawString.new(obj1) ^ RawString.new(obj2)).value
end

# Output: boolean: true if there is an indication that AES ECB encryption is used
def guess_ecb(enc)
  slices = []

  enc.bytes.each_slice(16) do |v|
    v = v.pack("c*")

    if slices.include? v
      return true
    else
      slices.push(v)
    end
  end

  false
end

# Input: string: msg: the message to be encrypted
# Input: string: key: the key
# Output: string: bytes: the encrypted message
def _encrypt_aes_ecb(msg, key)
  cipher = OpenSSL::Cipher.new("AES-128-ECB")
  cipher.encrypt
  cipher.key = key
  cipher.update(msg) + cipher.final
end

# Input: string: msg: the message to be decrypted
# Input: string: key: the key
# Output: string: bytes: the decrypted message
def _decrypt_aes_ecb(msg, key)
  cipher = OpenSSL::Cipher.new("AES-128-ECB")
  cipher.decrypt
  cipher.padding = 0
  cipher.key = key
  cipher.update(msg) + cipher.final
end

def _encrypt_aes_cbc(v, key, iv)
  cipher = OpenSSL::Cipher.new("AES-128-ECB")
  cipher.encrypt
  cipher.key = key

  res = [iv]

  pad(v.bytes, 16).each_slice(16) do |block|
    xor_res = _xor(block, res[-1])
    res.push(cipher.update(xor_res))
  end

  res.shift
  res.join
end

def _decrypt_aes_cbc(v, key, iv)
  cipher_blocks = v.bytes.each_slice(16)
  mid_blocks = _decrypt_aes_ecb(v, key).bytes.each_slice(16).to_a

  # 1st block (decrypted) ^ IV ("0th" block)
  res = _xor(mid_blocks.shift, iv)

  mid_blocks.zip(cipher_blocks).each do |mid, cip|
    # i:th block (decrypted) ^ (i-1):th encrypted block (encrypted)
    res += _xor(mid, cip)
  end

  res
end
