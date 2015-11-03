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

namespace :component do

  def hosts
    ENV['HOSTS'] || ENV['CONFIG'] || 'acceptance/config/nodes/redhat-7-x86_64.yaml'
  end

  def tests
    ENV['TESTS'] || ENV['TEST'] || 'acceptance/tests'
  end

  def generate_beaker_cli_flags
    # the options file (including the default options might also have tests
    #   they'll get merged with the below by beaker
    tests_opt = "--tests=#{tests}" if tests

    hosts_opt = "--hosts=#{hosts}" if hosts

    overriding_options = ENV['OPTIONS'].to_s

    # compact to remove the nil elements
    [hosts_opt, tests_opt, *overriding_options.split(' ')].compact
  end

  desc 'Component functional tests for beaker-facter.'
  task :test do
    sh('beaker',
       '--type', 'foss',
       '--load-path', 'acceptance/lib',
       '--pre-suite', 'acceptance/pre-suite',
       '--keyfile', ENV['KEY'] || "#{ENV['HOME']}/.ssh/id_rsa",
       *generate_beaker_cli_flags,
      )
  end

end
