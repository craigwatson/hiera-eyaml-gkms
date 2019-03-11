lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hiera/backend/eyaml/encryptors/gkms/version'

Gem::Specification.new do |gem|
  gem.name          = "hiera-eyaml-gkms"
  gem.version       = Hiera::Backend::Eyaml::Encryptors::Gkms::VERSION
  gem.description   = "Google Cloud KMS plugin for Hiera-EYAML"
  gem.summary       = "Encryption plugin for hiera-eyaml backend for Hiera, using Google Cloud KMS"
  gem.author        = "Craig Watson"
  gem.license       = "Apache-2.0"

  gem.homepage      = "http://github.com/craigwatson/hiera-eyaml-google-kms"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('hiera-eyaml', '>=1.3.8')
  gem.add_runtime_dependency('google-cloud-kms')
end
