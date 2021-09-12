def integral f, start, stop, step_size=0.001
  t = lambda do |h|
    trapezoidal_integral(f, start, stop, h)
  end
  return richardson_extrapolation(t, 2, step_size, 2)
end

# f - Function to extrapolate from
# n - Targeted function's rate of convergence
# h - Step size
# t - Scaling
def richardson_extrapolation f, n, h, t
  return ((t**n) * f.call(h/t) - f.call(h)) / (t**n - 1)
end

def trapezoidal_integral f, start, stop, inc
  result = 0
  (start..stop).step(inc).each_cons(2) do |i, j|
    area = (j - i) * (f.call(i) + f.call(j)) / 2
    result += area if !area.nan? and !area.infinite?
  end
  return result
end

# f - Function to query
# x1 - Starting point 1
# x2 - Starting point 2
# y - y position that is searched for
def secant_method f, x1, x2, y=0, timeout=30
  g = lambda { |x| f.call(x) - y }
  l = [x1, x2]
  lf1 = g.call(l[-1]).to_f
  lf2 = g.call(l[-2]).to_f
  while l.size == l.uniq.size and (l[-1] - l[-2]).abs > 10**(-7) and l.size() < timeout and lf1 != lf2
    l.push(l[-1] - lf1*(l[-1] - l[-2])/(lf1 - lf2))
    lf2 = lf1
    lf1 = g.call(l[-1])
  end
  return l[-1]
end