source 'https://rubygems.org'

gem 'facter', ENV['FACTER_GEM_VERSION'], require: false
gem 'puppet', ENV['PUPPET_GEM_VERSION'], require: false
gem 'rake'

group :development, :test do
  gem 'metadata-json-lint',       require: false
  gem 'puppetlabs_spec_helper',   require: false
  gem 'puppet-lint', '>= 1.1.0',  require: false
  # Use info from metadata.json for tests
  # rubocop:disable Bundler/DuplicatedGem
  gem 'puppet_metadata', '~> 3.0', require: false if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.7.0')
  gem 'puppet_metadata', '~> 2.1', require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.7.0')
  # rubocop:enable Bundler/DuplicatedGem
  gem 'puppet-syntax',            require: false
  gem 'rspec-puppet', '>= 2.4',   require: false
  # This draws in rubocop and other useful gems for puppet tests
  # rubocop:disable Bundler/DuplicatedGem
  gem 'voxpupuli-test', '~> 6.0', require: false if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.7.0')
  gem 'voxpupuli-test', '~> 5.7', require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.7.0')
  # rubocop:enable Bundler/DuplicatedGem
end

group :beaker do
  gem 'beaker',                   require: false
  gem 'beaker-rspec',             require: false
  gem 'pry',                      require: false
  gem 'puppet-blacksmith',        require: false
  gem 'serverspec',               require: false
end

group :docs do
  gem 'puppet-strings'
end

# vim:ft=ruby
