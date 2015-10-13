require 'rspec/core/rake_task'

task :default => :test

desc 'Run spec tests'
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/'
end

desc 'Run spec tests with coverage'
RSpec::Core::RakeTask.new(:coverage) do |t|
  ENV['BEAKER_FACTER_COVERAGE'] = 'y'
  t.rspec_opts = ['--color']
  t.pattern = 'spec/'
end

def hosts
  ENV['HOSTS'] || ENV['CONFIG'] || 'acceptance/config/nodes/redhat-7-x86_64.yaml'
end

def tests
  ENV['TESTS'] || ENV['TEST'] || 'acceptance/tests'
end

namespace :component do

  desc 'A quick acceptance test, named because it has no pre-suites to run'
  task :test do
    sh('beaker',
       '--hosts', hosts,
       '--tests', tests,
       '--log-level', 'verbose',
       '--keyfile', ENV['KEY'] || "#{ENV['HOME']}/.ssh/id_rsa")
  end

end
