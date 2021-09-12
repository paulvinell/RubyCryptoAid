Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.0.0'
  s.name          = 'crypto_aid'
  s.version       = '0.0.2'
  s.authors       = ['Paul Vinell']
  s.date          = '2021-09-12'
  s.description   = 'Aid for solving cryptography exercises'
  s.homepage      = 'http://www.t2data.com'
  s.summary       = 'Cryptography exercise aid'
  s.email         = 'vinell@kth.se'
  s.files         = ['crypto_aid.gemspec'] + Dir['lib/**/*']
  s.require_paths = ['lib']
end
