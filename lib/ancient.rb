#caesar(v, KEY) to encrypt, caesar(v, -KEY) to decrypt
def caesar v, i
  return v.chars.each.map {
    |c| 
    shiftChar(c, i)
  }.join
end

#Pass in message + hash of (character, shift amount)
def presetScheme msg, scheme
  return msg.chars.each.map  do |c|
    shift = scheme[c]
    shift ||= 0
    shiftChar(c, shift)
  end.join
end

def vigenereEncrypt msg, key
  res = ""
  for i in (0..(msg.length - 1))
    res += shiftChar(msg.chars[i], shiftLength(key.chars[i % key.length]))
  end
  return res
end

def vigenereDecrypt msg, key
  res = ""
  for i in (0..(msg.length - 1))
    res += shiftChar(msg.chars[i], -shiftLength(key.chars[i % key.length]))
  end
  return res
end

def vigenereBreakMm msg, min_keylength, max_keylength
  best = ["", 100000]
  
  for i in (min_keylength..max_keylength)
    key = vigenereBreakL msg, i
    dist = englishBlueprintDist(vigenereDecrypt(msg, key))
      
    if dist < best[1]
      best[0] = key
      best[1] = dist
    end
  end
  
  return best[0]
end

def vigenereBreakL msg, keylength
  msg = charAnalysisStrip(msg)
  key = ""

  for i in (0..(keylength - 1))
    frag_msg = ""
  
    (i..(msg.length - 1)).step(keylength) do |j|
      frag_msg += msg[j]
    end
    
    key += ('a'.ord + caesarBreak(frag_msg)).chr
  end
  
  return key
end

def caesarBreak msg
  msg = charAnalysisStrip msg
  
  best = [0, 0]
  
  for i in (0..('z'.ord - 'a'.ord))
    test = caesar(msg, -i)
    dist = englishBlueprintDist test
    
    if dist > best[1]
      best[0] = i
      best[1] = dist
    end
  end
  
  return best[0]
end

def charAnalysisStrip s
  return s.downcase.chars.select { |c| c.ord >= 'a'.ord && c.ord <= 'z'.ord }.join()
end

def englishBlueprintDist s
  s = charAnalysisStrip s
  span = 'z'.ord - 'a'.ord + 1
  
  #a-z char frequencies
  freq = [0.08167, 0.01492, 0.02782, 0.04253,
    0.12702, 0.02228, 0.02015, 0.06094,
    0.06966, 0.00153, 0.00772, 0.04025,
    0.02406, 0.06749, 0.07507, 0.01929,
    0.00095, 0.05987, 0.06327, 0.09056,
    0.02758, 0.00978, 0.02360, 0.00150,
    0.01974, 0.00074]
    
  arr = [0] * span
  s.chars.each { |c|  arr[c.ord - 'a'.ord] += 1 }

  dist = 0
  freq.each_with_index do |f, i|
    dist += (arr[i].to_f / s.length.to_f) * f
  end
    
  return dist
end

def charShift? c1, c2
  i = c1.ord - c2.ord
  
  while i < 0
    i = 'Z'.ord - 'A'.ord + 1 + i
  end
  
  return i
end

def shiftChar c, i
  while i < 0
    i = 'Z'.ord - 'A'.ord + 1 + i
  end
  
  if c.ord >= 'A'.ord && c.ord <= 'Z'.ord
    return (((c.ord - 'A'.ord + i) % ('Z'.ord - 'A'.ord + 1)) + 'A'.ord).chr
  elsif c.ord >= 'a'.ord && c.ord <= 'z'.ord  
    return (((c.ord - 'a'.ord + i) % ('z'.ord - 'a'.ord + 1)) + 'a'.ord).chr
  end
  
  return c
end

def shiftLength c
  if c.ord >= 'A'.ord && c.ord <= 'Z'.ord
    return c.ord - 'A'.ord
  elsif c.ord >= 'a'.ord && c.ord <= 'z'.ord  
    return c.ord - 'a'.ord
  end
  
  return 0
end