lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nebulous/version'

Gem::Specification.new do |spec|
  spec.name          = 'nebulous'
  spec.version       = Nebulous::VERSION
  spec.authors       = ['Zach Graves']
  spec.email         = ['zagraves@gmail.com']
  spec.summary       = 'Read CSV files with substantially less murderous rage!'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/zachgraves/nebulous'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'cocaine', '~> 0.5'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'byebug'
end
