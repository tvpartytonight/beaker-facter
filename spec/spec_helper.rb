require 'simplecov'
require 'beaker-facter'
require 'beaker_test_helpers'
require 'helpers'

require 'rspec/its'

RSpec.configure do |config|
  config.include TestFileHelpers
  config.include HostHelpers
end
