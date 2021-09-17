require_relative "numerical"

class StochasticVariables
  # x - list of values
  # p - array of probabilities for each value

  def initialize x, p=nil
    @x = x
    @p = p
  end

  def d
    return Math.sqrt(v)
  end

  def v
    return @x.map { |i| (i.to_f - e)**2 }.reduce(:+) / @x.length
  end

  def e
    return @x.reduce(:+).to_f / @x.length if @p.nil?
    return @x.zip(@p).map { |pair| pair[0].to_f * pair[1].to_f }.reduce(:+)
  end
end

class Sample

  def self.add s1, s2, same_variation=false
    if same_variation
      return Sample.new(nil, s1.e + s2.e, Math.sqrt(((s1.n - 1)*s1.v + (s2.n - 1)*s2.v) / (s1.n + s2.n - 2)))
    else
      return Sample.new(nil, s1.e + s2.e, Math.sqrt(s1.v/s1.n + s2.v/s2.n))
    end
  end

  # x - list of values
  # sd - standard deviation

  def initialize x=nil, mean=nil, sd=nil, n=nil
    @x = x
    @mean = mean
    @sd = sd
    @n = n
  end

  def n
    return @n unless @n.nil?
    return @x.length unless @x.nil?
    return Float::NAN
  end

  def d
    return @sd unless @sd.nil?
    return Math.sqrt(v)
  end

  def v
    return @sd**2 unless @sd.nil?
    return @x.map { |i| (i.to_f - e)**2 }.reduce(:+) / (@x.length - 1) unless @x.nil?
    return Float::NAN
  end

  def e
    return @mean unless @mean.nil?
    return @x.reduce(:+).to_f / @x.length unless @x.nil?
    return Float::NAN
  end
end

class NormalDistribution

  # Adds two normal distributions
  def self.add nd1, nd2
    return NormalDistribution.new(nd1.e + nd2.e, Math.sqrt(nd1.v + nd2.v))
  end

  def initialize mean=0, sd=1
    @mean = mean
    @sd = sd
  end

  def e
    return @mean
  end

  def v
    return @sd**2
  end

  # General normal cumulative distribution function
  def cdf x
    return integral(lambda { |xpos| pdf(xpos) }, -8 * @sd, x)
  end

  # General normal probability distribution function
  # x - Point in the normal distribution (measured in standard deviations)
  # mean - The mean of the normal distribution
  # sd - The standard deviation of the normal distribution
  def pdf x
    return (1 / Math.sqrt(2 * Math::PI * @sd**2)) * Math::E**(-((x - @mean)**2) / (2 * @sd**2))
  end

  # Find the x that gives some percentage of the distribution
  # p - The percentage sought
  def r_cdf p
    return secant_method(lambda { |x| cdf(x) }, @mean + 1, @mean - 1, p)
  end
end

class TDistribution

  # k - Degrees of freedom
  def initialize k=1
    @k = k.to_f
  end

  def v
    return @k.to_f / (@k - 2) if @k > 2
    return Float::INFINITY
  end

  def cdf x
    return 1 - cdf(-x) if x < 0
    return 1 - 0.5*regularized_incomplete_beta_function(@k/(x**2 + @k), @k / 2, 0.5)
  end

  def pdf x
    return (gamma((@k + 1) / 2) / (Math.sqrt(@k * Math::PI) * gamma(@k / 2))) * (1 + (x.to_f**2)/@k)**(-(@k+1)/2)
  end

  def r_cdf p
    return secant_method(lambda { |x| cdf(x) }, 1, -1, p)
  end
end

class ChiSquare

  # Calculates Q
  # Two parameters:
  # a - matrix of actual values
  # (e - matrix of expected values, otherwise assumes even spread)
  def self.q_matrix a, e=nil
    if e.nil?
      row_size = a.size
      col_size = a.transpose.size
      row_sum = a.clone.map { |y| y.reduce(:+) }
      col_sum = a.transpose.clone.map { |x| x.reduce(:+) }
      tot_sum = row_sum.clone.reduce(:+).to_f

      res = 0.0
      row_size.times do |y|
        col_size.times do |x|
          m = row_sum[y]*col_sum[x]/tot_sum # Expected value at (x,y)
          res += (a[y][x].to_f - m)**2 / m
         end
       end
       return res
    end
    return q_list(a.flatten, e.flatten)
  end

  # Calculates Q
  # Two parameters:
  # a - list of actual values
  # e - list of expected values
  def self.q_list a, e
    return a.zip(e).map { |pair| (pair[0].to_f - pair[1].to_f)**2 / pair[1].to_f }.reduce(:+)
  end

  # k - degrees of freedom
  def initialize k
    @k = k.to_f
  end

  def pdf x
    return (x**(@k/2 - 1) * Math::E**(-x.to_f/2))/(2**(@k/2) * gamma(@k/2))
  end

  def cdf x
    return lower_incomplete_gamma(@k/2, x.to_f/2)/gamma(@k/2)
  end

  # Returns the maximum point on the probability density function
  def pdf_max
    return @k - 2 if @k >= 2
    return 0
  end

  # Find the x that gives some percentage of the distribution
  # p - The percentage sought
  def r_cdf p
    return secant_method(lambda { |x| cdf(x) }, pdf_max, pdf_max + 1, p)
  end
end

class ExponentialDistribution

  # λ = rate
  def initialize rate
    @rate = rate
  end

  def e
    return 1/@rate
  end

  def v
    return 1/(@rate**2)
  end

  def d
    return Math.sqrt(v)
  end

  def pdf x
    return @rate*(Math::E**(-1*@rate*x))
  end

  def cdf x
    return integral(lambda { |xpos| pdf(xpos) }, 0, x)
  end
end

class PoissonDistribution

  # Adds two poisson distributions
  def self.add pd1, pd2
    return PoissonDistribution.new(pd1.e + pd2.e)
  end

  def initialize mean
    @mean = mean.to_f
  end

  def e
    return @mean
  end

  def v
    return e
  end

  def d
    return Math.sqrt(v)
  end

  def pdf k
    return (@mean**k)/factorial(k) * Math::E**(-1*@mean)
  end

  # Probability that a value is less or equals to k
  def cdf k
    return Math::E**(-1*@mean) * (0..k).to_a.map { |i| (@mean**i)/factorial(i) }.reduce(:+)
  end
end

class BinomialDistribution

  def initialize n, p
    @n = n
    @p = p
  end

  def e
    return @n * @p
  end

  def v
    return @n * @p * (1 - @p)
  end

  def pdf k
    return combination(@n, k) * @p**k * (1 - @p)**(@n - k)
  end

  # Probability that a value is less or equals to k
  def cdf k
    return (0..k).to_a.map { |i| pdf(i) }.reduce(:+)
  end
end

# Calculates the gamma function
def gamma z
  return integral(lambda { |x| x**(z-1) * Math::E**(-x)}, 0, 50)
end

# Calculates the lower incomplete gamma function
def lower_incomplete_gamma s, x
  return integral(lambda { |t| t**(s-1) * Math::E**(-t)}, 0, x)
end

# Calculates the regularized incomplete beta function
def regularized_incomplete_beta_function x, a, b
  return incomplete_beta_function(x, a, b)/beta_function(a, b)
end

# Calculates the incomplete beta function
def incomplete_beta_function x, a, b
  return integral(lambda { |t| t**(a-1) * (1-t)**(b-1) }, 0, x, 0.00001)
end

# Calculates the beta function
def beta_function a, b
  return incomplete_beta_function(1, a, b)
end

# Calculates the factorial of an integer
def factorial k
  return (1..k).to_a.reduce(:*) if k >= 1
  return 1
end

# Calculates n choose k
def combination n, k
  return factorial(n)/(factorial(k)*factorial(n-k))
end
