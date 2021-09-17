require 'raw_string'

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

# Tries to find the key size based on hamming distance between blocks.
# Input: raw string: the string to XOR against
# Input: [integer, integer]: key_length: the key length search interval (inclusive)
# Input: integer: samples: the number of samples to take. This guides the keysize guesses.
# Input: integer: results: the number of keysizes to return.
# Output: keysize: the assumed key size
def xor_keysize(raw_string, key_length, samples: 1, results: 3)
  results = [results, key_length.max - key_length.min].min
  keysizes = []

  for length in key_length[0]..key_length[1]
    current_score = 0

    sample1 = raw_string.value[0, length]
    samples.times do |sample_index|
      sample2 = raw_string.value[(sample_index+1)*length, length]

      current_score += sample1.to_raw.hamming_dist(sample2.to_raw)

      sample1 = sample2
    end

    current_score /= length.to_f
    current_score /= samples.to_f

    keysizes.append([length, current_score])
  end

  keysizes.sort_by { |elem| elem[1] }[0, results]
end

# Bruteforces the key based on some user defined metric.
# Uses divide and conquer to exploit knowing the key length.
# Input: raw string: the string to XOR against
# Input: integer: key_length: the key length
# Input (optional): [integer, integer]: key_value: the key value search interval (inclusive) (individual characters)
# Input (optional), yield: fn -> number: yields a raw_string and expects to be returned a score,
#                                        for instance, a measure of character frequency. The score is maximized.
# Output: raw string: the found key
def xor_key_brute_daq(raw_string, key_length, key_value: [0, 255])
  key = RawString.new("")

  key_length.times do |key_index|
    (key_index..raw_string.value.length).step(key_length).map do |data_index|
      raw_string.value[data_index]
    end.join.to_raw => data

    key_fragment = xor_key_brute(data, key_length: [1, 1], key_value: key_value) do |rs|
      yield(rs)
    end
    key = key.append(key_fragment)
  end

  key
end

# Bruteforces the key based on some user defined metric.
# Input: raw string: the string to XOR against
# Input (optional): [integer, integer]: key_length: the key length search interval (inclusive)
# Input (optional): [integer, integer]: key_value: the key value search interval (inclusive) (individual characters)
# Input (optional), yield: fn -> number: yields a raw_string and expects to be returned a score,
#                                        for instance, a measure of character frequency. The score is maximized.
# Output: raw string: the found key
def xor_key_brute(raw_string, key_length: [1, 1], key_value: [0, 255])
  best_key = nil
  best_score = -1

  value_interval_size = key_value[1] - key_value[0]

  for length in key_length[0]..key_length[1]
    (value_interval_size ** length).times do |value|
      current_key_bytes = get_key(value, length, key_value)
      current_key_str = current_key_bytes.pack("c*")
      current_key = RawString.new(current_key_str)

      xor_string = raw_string ^ current_key

      current_score = yield(xor_string)
      if best_score < current_score
        best_score = current_score
        best_key = current_key
      end
    end
  end

  best_key
end

# Cycles through all possible keys.
# Can be thought of as the "key_index":ed number in base "key value's interval size"
# with a modulo of "key value's interval size"^length.
# In total there are "key value's interval size"^length different keys.
# E.g.
# get_key(0, 3, [0, 1]) => [0, 0, 0]
# get_key(1, 3, [0, 1]) => [1, 0, 0]
# get_key(2, 3, [0, 1]) => [0, 1, 0]
# get_key(3, 3, [0, 1]) => [1, 1, 0]
# get_key(3, 2, [0, 1]) => [1, 1]
# get_key(3, 2, [0, 3]) => [3, 0]
#
# Input: integer: key_index: where in the cycle we are
# Input: integer: length: how long the key is at most
# Input: [integer, integer]: key_value: the key value search interval (inclusive) (individual characters)
# Output: integer array: the key at the given position
def get_key(key_index, length, key_value)
  value_interval_size = key_value[1] - key_value[0]
  previous_keys_sum = 0
  current_key = Array.new(length) do |index|
    value = ((key_index - previous_keys_sum) % ((value_interval_size + 1) ** (index + 1))) / ((value_interval_size + 1) ** index)
    previous_keys_sum += value
    value
  end
  current_key.map { |value| value + key_value[0] }
end
