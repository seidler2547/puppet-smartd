source 'https://rubygems.org'

gem 'facter', ENV['FACTER_GEM_VERSION'], require: false
gem 'puppet', ENV['PUPPET_GEM_VERSION'], require: false

group :development, :test do
  gem 'metadata-json-lint',       require: false
  gem 'puppetlabs_spec_helper',   require: false
  gem 'puppet-lint', '>= 1.1.0',  require: false
  # Use info from metadata.json for tests
  gem 'puppet_metadata', '~> 2.0', require: false
  gem 'puppet-syntax',            require: false
  gem 'rake', '~> 10.5',          require: false
  gem 'rspec', '~> 3.2',          require: false
  gem 'rspec-puppet', '~> 2.2',   require: false
  # This draws in rubocop and other useful gems for puppet tests
  gem 'voxpupuli-test', '~> 5.6', require: false
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
