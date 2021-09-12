require "openssl"
require "Lib/XOR"

def pad bytes, blocklength
  i = bytes.length
  while i > blocklength
    i -= blocklength
  end
  
  diff = blocklength - i
  if diff > 0
    diff.times do
      bytes.push(diff)
    end
  end
  
  return bytes
end

def guess_CBC_ECB enc
  slices = []
  enc.bytes.each_slice(16) do |v|
    v = v.pack("c*")
    
    if slices.include? v
      return :ECB
    else
      slices.push(v)
    end
  end
  return :CBC
end

def encryptECB v, key
  cipher = OpenSSL::Cipher.new("AES-128-ECB")
  cipher.encrypt
  cipher.key = key
  return cipher.update(v) + cipher.final
end

def decryptECB v, key
  cipher = OpenSSL::Cipher.new("AES-128-ECB")
  cipher.key = key
  cipher.padding = 0
  cipher.decrypt
  return cipher.update(v) + cipher.final
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