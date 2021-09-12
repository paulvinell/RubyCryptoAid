# The Extended Euclidean Algorithm
def egcd i, j, x=1, y=1
  return egcd(j, i).reverse if i < j
  return [1, 0] if j <= 0

  r = egcd(j, i % j, x, y)
  x = r[1]
  y = r[0] - ((i - (i % j)) / j) * r[1]
  
  return [x, y]
end

def gcd i, j
  return i if j == 0
  return gcd(j, i % j)
end
