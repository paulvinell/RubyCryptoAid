def prime p
  for i in 2..Math::sqrt(p.to_f).ceil
    return false if (p != i && p % i == 0)
  end
  return true
end

def factorize p, arr=[]
  if p == 1
    return arr unless arr.empty?
    return [1]
  end
  start = 2
  start = arr.max unless arr.empty?
  for i in start..Math::sqrt(p.to_f).ceil
    if p % i == 0
      return factorize(p / i, arr + [i])
    end
  end
  return arr + [p]
end

def primesTo n
  arr = Array.new(n - 1) { |i| i + 2 }

  last = 0
  while last < arr.length && arr[last]**2 <= n
    arr = arr.select { |v| (v % arr[last] != 0 || arr[last] == v) }
    last += 1
  end
  return arr
end

def fermat a, p
  return a**(p-1) % p == 1
end
