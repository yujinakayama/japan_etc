# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'japan_etc/version'

Gem::Specification.new do |spec|
  spec.name          = 'japan_etc'
  spec.version       = JapanETC::VERSION
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']

  spec.summary       = 'Japan ETC (Electronic Toll Collection System) database'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/yujinakayama/japan_etc'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 0.15'
  spec.add_runtime_dependency 'pdf-reader', '~> 2.2'
  spec.add_runtime_dependency 'spreadsheet', '~> 1.2'

  spec.add_development_dependency 'bundler', '~> 2.0'
end
