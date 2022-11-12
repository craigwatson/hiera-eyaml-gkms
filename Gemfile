# frozen_string_literal: true

source 'https://rubygems.org/'

# Find a location or specific version for a gem. place_or_version can be a
# version, which is most often used. It can also be git, which is specified as
# `git://somewhere.git#branch`. You can also use a file source location, which
# is specified as `file://some/location/on/disk`.
def location_for(place_or_version, fake_version = nil)
  case place_or_version
  when %r{^(https[:@][^#]*)#(.*)}
    [fake_version, { git: Regexp.last_match(1), branch: Regexp.last_match(2), require: false }].compact
  when %r{^file://(.*)}
    ['>= 0', { path: File.expand_path(Regexp.last_match(1)), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

gemspec

group :development do
  gem 'puppet', *location_for(ENV.fetch('PUPPET_VERSION')) if ENV.fetch('PUPPET_VERSION', nil)
end

group :test do
  gem 'rubocop'
end

group :coverage, optional: ENV.fetch('COVERAGE', nil) != 'yes' do
  gem 'codecov', require: false
  gem 'simplecov-console', require: false
end
