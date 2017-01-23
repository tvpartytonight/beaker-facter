module Beaker
  module DSL
    module Helpers
      module Facter
        require 'stringify-hash'
        require 'beaker-facter/helpers'
        require 'beaker-facter/version'
      end
    end
  end
end

# Boilerplate DSL inclusion mechanism:
# First we register our module with the Beaker DSL
Beaker::DSL.register( Beaker::DSL::Helpers::Facter )

# Second,We need to reload the DSL, but before we had reloaded
# it in the global namespace, which result in errors colliding
# with other gems rightfully not expecting beaker's dsl to
# be available at the global level.
module Beaker
  class TestCase
    include Beaker::DSL
  end
end
