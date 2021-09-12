class Polynomial
  attr_reader :coefficients

  # c0 + c1*x + c2*x^2 + ...
  def initialize(*coefficients)
    @coefficients = coefficients
  end

  def degree
    d = 0
    coefficients.each_with_index do |v, i|
      d = i if v != 0
    end
    d
  end

  def coefficient_at(degree)
    coefficients[degree] || 0
  end

  def set_coefficient(degree, value)
    coefficients[degree] = value
  end

  def evaluate(x)
    sum = 0
    base = 1
    (0..degree).each do |d|
      sum += coefficient_at(d) * base
      base *= x
    end
    sum
  end

  def /(p2)
    q_tot = Polynomial.new()
    q = Polynomial.new()
    r = Polynomial.new(*coefficients.dup)

    while (true)
      cr = r.coefficient_at(r.degree)
      c2 = p2.coefficient_at(p2.degree)
      dq = r.degree - p2.degree

      break if dq < 0

      q.set_coefficient(dq, cr.to_f / c2)
      r = r - (p2 * q)

      q_tot = q_tot + q
      q = Polynomial.new()
    end

    [q_tot, r]
  end

  def +(p2)
    p = Polynomial.new()
    (0..[degree, p2.degree].max).each do |d|
      p.set_coefficient(d, coefficient_at(d) + p2.coefficient_at(d))
    end
    p
  end

  def -(p2)
    p = Polynomial.new()
    (0..[degree, p2.degree].max).each do |d|
      p.set_coefficient(d, coefficient_at(d) - p2.coefficient_at(d))
    end
    p
  end

  def *(p2)
    p = Polynomial.new()
    (0..degree).each do |d1|
      c1 = coefficient_at(d1)

      (0..p2.degree).each do |d2|
        c2 = p2.coefficient_at(d2)

        current = p.coefficient_at(d1+d2)
        p.set_coefficient(d1+d2, current + (c1*c2))
      end
    end
    p
  end

  def to_s()
    return "#{coefficient_at(0)}" if degree == 0

    terms = (0..degree).to_a.map do |d|
      [d, coefficient_at(d)]
    end.select do |d, c|
      c != 0
    end.map do |d, c|
        c = c.to_i if (c.is_a? Float) && (c % 1) == 0
        
        next "#{c}" if d == 0 && c > 0
        next "(#{c})" if d == 0 && c < 0
        next "x" if d == 1 && c == 1
        next "x^#{d}" if d > 0 && c == 1

        coefficient_str = if c > 0
                            "#{c}*"
                          else
                            "(#{c})*"
                          end

        case d
        when 1
          "#{coefficient_str}x"
        else
          "#{coefficient_str}x^#{d}"
        end
    end.reverse.join(" + ")
  end
end
