# These are specifically to mock Beaker methods necessary for testing
# that will be available during runtime because this is never run separate
# from Beaker itself.
#
# Including Beaker as a dependency would not work as a solution to this issue,
# since that would make a cycle in the dependency graph, at least until
# Beaker 3.0 happens and this is no longer a dependency of Beaker's.
module BeakerTestHelpers

  class Result
    attr_accessor :host, :cmd, :exit_code, :stdout, :stderr, :output,
                  :raw_stdout, :raw_stderr, :raw_output
    def initialize(host, cmd)
      @host       = host
      @cmd        = cmd
      @stdout     = ''
      @stderr     = ''
      @output     = ''
      @exit_code  = nil
    end
  end

  def block_on hosts
    if block_given?
      yield hosts
    end
  end

end
