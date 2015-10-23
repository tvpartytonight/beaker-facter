module Acceptance
  module Install
    PLATFORM_PATTERNS = {
      :redhat        => /fedora|el|centos/,
      :debian        => /debian|ubuntu/,
      :debian_ruby18 => /debian|ubuntu-lucid|ubuntu-precise/,
      :solaris       => /solaris/,
      :windows       => /windows/,
    }.freeze

    # Installs packages on the hosts.
    #
    # @param hosts [Array<Host>] Array of hosts to install packages to.
    # @param package_hash [Hash{Symbol=>Array<String,Array<String,String>>}]
    #   Keys should be a symbol for a platform in PLATFORM_PATTERNS.  Values
    #   should be an array of package names to install, or of two element
    #   arrays where a[0] is the command we expect to find on the platform
    #   and a[1] is the package name (when they are different).
    # @param options [Hash{Symbol=>Boolean}]
    # @option options [Boolean] :check_if_exists First check to see if
    #   command is present before installing package.  (Default false)
    # @return true
    def install_packages_on(hosts, package_hash, options = {})
      check_if_exists = options[:check_if_exists]
      hosts = [hosts] unless hosts.kind_of?(Array)
      hosts.each do |host|
        package_hash.each do |platform_key,package_list|
          if pattern = PLATFORM_PATTERNS[platform_key]
            if pattern.match(host['platform'])
              package_list.each do |cmd_pkg|
                if cmd_pkg.kind_of?(Array)
                  command, package = cmd_pkg
                else
                  command = package = cmd_pkg
                end
                if !check_if_exists || !host.check_for_package(command)
                  host.logger.notify("Installing #{package}")
                  additional_switches = '--allow-unauthenticated' if platform_key == :debian
                  host.install_package(package, additional_switches)
                end
              end
            end
          else
            raise("Unknown platform '#{platform_key}' in package_hash")
          end
        end
      end
      return true
    end
    module_function :install_packages_on

    def install_repos_on(host, project, sha, repo_configs_dir)
      platform = host['platform'].with_version_codename
      platform_configs_dir = File.join(repo_configs_dir,platform)
      tld     = sha == 'nightly' ? 'nightlies.puppetlabs.com' : 'builds.puppetlabs.lan'
      project = sha == 'nightly' ? project + '-latest'        : project
      sha     = sha == 'nightly' ? nil                        : sha

      case platform
      when /^(fedora|el|centos)-(\d+)-(.+)$/
        variant = (($1 == 'centos') ? 'el' : $1)
        fedora_prefix = ((variant == 'fedora') ? 'f' : '')
        version = $2
        arch = $3

        repo_filename = "pl-%s%s-%s-%s%s-%s.repo" % [
          project,
          sha ? '-' + sha : '',
          variant,
          fedora_prefix,
          version,
          arch
        ]
        repo_url = "http://%s/%s/%s/repo_configs/rpm/%s" % [tld, project, sha, repo_filename]

        on host, "curl --silent --show-error --output /etc/yum.repos.d/#{repo_filename} #{repo_url}"
      when /^(debian|ubuntu)-([^-]+)-(.+)$/
        variant = $1
        version = $2
        arch = $3

        list_filename = "pl-%s%s-%s.list" % [
          project,
          sha ? '-' + sha : '',
          version
        ]
        list_url = "http://%s/%s/%s/repo_configs/deb/%s" % [tld, project, sha, list_filename]

        on host, "curl --silent --show-error --output /etc/apt/sources.list.d/#{list_filename} #{list_url}"
        on host, "apt-get update"
      else
        if project == 'puppet-agent'
          opts = {
            :puppet_collection => 'PC1',
            :puppet_agent_sha => ENV['SHA'],
            :puppet_agent_version => ENV['SUITE_VERSION'] || ENV['SHA']
          }
          # this installs puppet-agent on windows (msi) and osx (dmg)
          install_puppet_agent_dev_repo_on(agent, opts)
        else
          fail_test("No repository installation step for #{platform} yet...")
        end
      end
    end
    module_function :install_repos_on

  end
end
