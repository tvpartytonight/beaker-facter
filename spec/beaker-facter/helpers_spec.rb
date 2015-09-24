require 'spec_helper'

class ClassMixedWithDSLHelpers
  include BeakerTestHelpers
  include Beaker::DSL::Helpers::Facter
  include Beaker::DSL::Wrappers

  def logger
    RSpec::Mocks::Double.new('logger').as_null_object
  end
end

describe ClassMixedWithDSLHelpers do

  let( :command ){ 'ls' }
  let( :beaker_command ) { class_double("Beaker::DSL::Wrappers::Command").as_stubbed_const(:transfer_nested_constants => true) }
  let( :host )   { double.as_null_object }
  let( :result ) { BeakerTestHelpers::Result.new( host, command ) }

  let( :master ) { make_host( 'master',   :roles => %w( master agent default)    ) }
  let( :agent )  { make_host( 'agent',    :roles => %w( agent )           ) }
  let( :dash )   { make_host( 'console',  :roles => %w( dashboard agent ) ) }
  let( :db )     { make_host( 'db',       :roles => %w( database agent )  ) }
  let( :custom ) { make_host( 'custom',   :roles => %w( custom agent )    ) }
  let( :hosts )  { [ master, agent, dash, db, custom ] }
  let(:empty_opts) { {'ENV' => {}, :cmdexe => true } }

  describe '#facter' do
    it 'should split out the options and pass "facter" as first arg to Command' do
      expect( beaker_command ).to receive( :new ).
        with('facter', [ '-p' ], empty_opts)
      subject.facter( '-p' )
    end
  end

  describe '#cfacter' do
    it 'should split out the options and pass "cfacter" as first arg to Command' do
      expect( beaker_command ).to receive( :new ).
        with('cfacter', [ '-p' ], empty_opts)
      subject.cfacter( '-p' )
    end
  end

  describe '#fact_on' do
    it 'retrieves a fact on a single host' do
      result.stdout = "family\n"
      expect( subject ).to receive(:facter).with('osfamily',{}).once
      expect( subject ).to receive(:on).and_return(result)

      expect( subject.fact_on('host','osfamily') ).to be === result.stdout.chomp
    end

   it 'retrieves an array of facts from multiple hosts' do
      allow( subject ).to receive( :hosts ).and_return( hosts )
      times = hosts.length
      results = []
      hosts.each.with_index do |host, index|
        results[index] = BeakerTestHelpers::Result.new( host, command )
        results[index].stdout = "family\n"
      end
      expected = ["family"] * hosts.length
      expect( subject ).to receive(:facter).with('osfamily',{}).once
      expect( subject ).to receive(:on).and_return(results)

      expect( subject.fact_on(hosts,'osfamily') ).to be === expected
    end
  end

  describe '#fact' do
    it 'delegates to #fact_on with the default host' do
      allow( subject ).to receive(:hosts).and_return(hosts)
      allow( subject ).to receive( :default ).and_return( hosts[0] )
      expect( subject ).to receive(:fact_on).with(master,"osfamily",{}).once

      subject.fact('osfamily')
    end
  end

end
