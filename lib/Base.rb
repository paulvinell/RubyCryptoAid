require "base64"

def hexToB64 h
  return Base64.encode64(hexDecode(h))
end

def b64ToHex h
  return hexEncode(Base64.decode64(h))
end

def hexDecode s
  return [s].pack("H*")
end

def hexEncode s
  return s.unpack("H*")
end