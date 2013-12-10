# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'weighted_hash/version'

Gem::Specification.new do |spec|
  spec.name          = "weighted_hash"
  spec.version       = WeightedHash::VERSION
  spec.authors       = ["David Brady", "Kevin Sjoberg"]
  spec.email         = ["dbrady@shinybit.com", "kev.sjoberg@gmail.com"]
  spec.description   = %q{Provides a WeightedHash class for generating random samples based on weighted probabilities.}
  spec.summary       = %q{Generate weighted random probabilities}
  spec.homepage      = "http://github/dbrady/weighted_hash"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
end
