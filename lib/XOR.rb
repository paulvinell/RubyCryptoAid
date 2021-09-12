require "Lib/Base"

def xor msg, key
  arr = []
    
  for i in 0..(msg.length - 1)
    arr[i] = msg[i] ^ key[i % key.length]
  end
  
  return arr
end

def hammingDistance s, t
  sb = s.pack("c*").unpack("B*").join.chars
  tb = t.pack("c*").unpack("B*").join.chars
  
  dist = 0
  for i in 0..([sb.length, tb.length].min - 1)
    if sb[i] != tb[i]
      dist += 1
    end
  end
  
  return dist + (sb.length - tb.length).abs
end

def xorFindSingleCharKey msgBytes
  besti = 0
  bestc = 0
  
  for i in 0..255
    arr = []
      
    msgBytes.each_with_index do |b, j|
      val = b ^ i
      
      if val.is_a?(Integer)
        arr[j] = val
      end
    end
 
    res = arr.pack("c*")
    
    magiccount = res.scan(/[ETAOIN SHRDLU]/i).size;
    if bestc < magiccount
      besti = i
      bestc = magiccount
    end
  end
  
  return besti
end