# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hiera/backend/eyaml/encryptors/gkms/version'
require 'English'

Gem::Specification.new do |gem|
  gem.name        = 'hiera-eyaml-gkms'
  gem.version     = Hiera::Backend::Eyaml::Encryptors::GkmsVersion::VERSION
  gem.description = 'Google Cloud KMS plugin for Hiera-EYAML'
  gem.summary     = 'Encryption plugin for hiera-eyaml backend for Hiera, using Google Cloud KMS'
  gem.author      = 'Craig Watson'
  gem.license     = 'Apache-2.0'
  gem.homepage    = 'https://github.com/craigwatson/hiera-eyaml-gkms'

  gem.files         = `git ls-files`.split($/).reject { |file| file =~ /^features.*$/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('google-cloud-kms', '2.0.0')
  gem.add_dependency('hiera-eyaml', '>= 3.2.0', '< 4.0')

  gem.required_ruby_version = '>=2.4', '< 4'
end
