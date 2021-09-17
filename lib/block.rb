require "openssl"
require_relative "raw_string"
require_relative "xor"

# Pads a byte array to an appropriate length
# Output: byte array: the input but with appropriate padding
def pad(bytes, blocklength)
  padding_left = bytes.length % blocklength
  diff = blocklength - padding_left

  if diff > 0
    diff.times do
      bytes.push(diff)
    end
  end

  bytes
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

def encryptCBC v, key, iv
  cipher = OpenSSL::Cipher.new("AES-128-ECB")
  cipher.encrypt
  cipher.key = key

  res = [iv]

  pad(v.bytes(), 16).each_slice(16) do |block|
    res.push(cipher.update(xor(block, res[-1].bytes).pack("c*")))
  end

  res.shift
  return res.join
end

def decryptCBC v, key, iv
  cipher = OpenSSL::Cipher.new("AES-128-ECB")
  cipher.key = key
  cipher.padding = 0
  cipher.decrypt

  cipher_blocks = v.bytes.each_slice(16)
  mid_blocks = (cipher.update(v) + cipher.final).bytes.each_slice(16).map { |i| i }

  res = xor(mid_blocks.shift, iv.bytes)
  mid_blocks.zip(cipher_blocks).each do |mid, cip|
    res += xor(mid, cip)
  end

  return res.pack("c*")
end
