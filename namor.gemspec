# -*- encoding: utf-8 -*-
require File.expand_path('../lib/namor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jason May"]
  gem.email         = ["jmay@pobox.com"]
  gem.description   = %q{Munging English names}
  gem.summary       = %q{Parse & extract pieces of names}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "namor"
  gem.require_paths = ["lib"]
  gem.version       = Namor::VERSION

  gem.add_development_dependency "rake", "~> 0.9.2"
  gem.add_development_dependency "rspec", "~> 2.9.0"
  gem.add_development_dependency "guard-rspec", "~> 0.7.0"
  gem.add_development_dependency "ruby_gntp", "~> 0.3.4"
end
