if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '.bundle/gems'
  end
end
require 'beaker-facter'
require 'beaker_test_helpers'
require 'helpers'

require 'rspec/its'

RSpec.configure do |config|
  config.include TestFileHelpers
  config.include HostHelpers
end
