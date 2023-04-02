require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-lint/tasks/puppet-lint'

begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError # rubocop:disable Lint/SuppressedException
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2')
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end
