# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resourced/version'

Gem::Specification.new do |gem|
  gem.name          = "resourced"
  gem.version       = Resourced::VERSION
  gem.authors       = ["Andrey Savchenko"]
  gem.email         = ["andrey@aejis.eu"]
  gem.description   = %q{WIP - not for production}
  gem.summary       = %q{Missing layer between model and controller}
  gem.homepage      = "https://github.com/Ptico/resourced"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "coercible"
  gem.add_dependency "activesupport"
  gem.add_development_dependency "rspec"
end
