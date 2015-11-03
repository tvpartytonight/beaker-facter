test_name 'fact_on, fact, facter, oh my' do
  facts_expected = [/timezone => \w\w\w/, /facterversion => \d+\.\d+\.\d+/]
  agents.each do |agent|
    on(agent, 'ln -s /opt/puppetlabs/bin/facter /opt/puppetlabs/bin/cfacter')
    step "facter should return all facts on #{agent}" do
      facts = on(agent,facter).stdout
      facts_expected.each do |expected|
        assert_match(expected, facts, 'expected fact not found using facter helper')
      end
    end

    step "cfacter should return all facts on #{agent}" do
      facts = on(agent,facter).stdout
      facts_expected.each do |expected|
        assert_match(expected, facts, 'expected fact not found using facter helper')
      end
    end

    step "fact_on should work on a single host" do
      fact = fact_on(agent,'osfamily')
      assert_match(/\w+/, fact, 'osfamily fact not found using fact_on helper')
    end
  end


  step "fact_on should work on a multiple hosts and return an array" do
    facts = fact_on(hosts,'hostname')
    assert(facts.kind_of?(Array), 'fact_on did not return an array when given an array')
    facts.each.with_index do |fact,index|
      assert_equal(hosts[index].hostname.split('.').first, fact, 'hostname fact not found using fact helper on multiple hosts')
    end
  end

  step "fact should work on default host" do
    fact = fact('ipaddress')
    assert_equal(default.ip, fact, 'ipaddress fact not found using fact helper on default host')
  end

end
