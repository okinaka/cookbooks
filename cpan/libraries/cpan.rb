module ModuleCpan

  def default_cpan_mirror
    'http://cpan.dk'.freeze
  end
  def dryrun_dest_dir
      '/tmp/chef/cpan/dry-run/'.freeze
  end

  def cpan_dry_run dry_run_verbose = false
      node.run_state[:cpan][:dryrun] = true
      node.run_state[:cpan][:dryrun_verbose] = true
      update_cpan_config(
        :mbuild_install_arg => "--destdir=#{dryrun_dest_dir}", 
        :make_install_arg   => "DESTDIR=#{dryrun_dest_dir}"
      )
      log 'PUT CPAN CLIENT INTO DRY-RUN MODE'
  end 

  def cpan_mirror url
      node.run_state[:cpan][:urllist] = [url]
      update_cpan_config :urllist => [url]
      unless  ENV['CPAN_INDEX_NO_RELOAD']
        LOG 'RELOAD CPAN INDEX BECAUSE CPAN MIRROR CHANGED (YOU CAN SKIP THIS BY SETTING UP CPAN_INDEX_NO_RELOAD ENV VAR)'
        cpan_reload_index 
      end
  end

  def cpan_init
      config = {
        :mbuild_install_arg => '', 
        :make_install_arg => '',
        :urllist => [ default_cpan_mirror ],
        :dryrun => false,
        :install_summary => []
      }
      node.run_state[:cpan] = config
      node.run_state[:cpan][:dryrun_verbose] = false
      update_cpan_config config
      if  ENV['CPAN_INDEX_RELOAD']
        log 'RELOAD CPAN INDEX ON START UP'
        cpan_reload_index 
      else
        log 'SKIP CPAN INDEX RELOAD ON START UP (YOU CAN SET IT UP BY CPAN_INDEX_RELOAD ENV VAR)'
      end
      cpan_cache_clean
  end

  def cpan_reload_index
      execute 'reload cpan index' do
        command 'HOME=/tmp/chef/cpan/  perl -MCPAN -e "CPAN::Shell->reload(q{index})"'
      end
  end

  def cpan_cache_clean
      execute 'clean cpan cache' do
        command 'rm -rf /root/.cpan/sources; rm -rf /root/.cpan/build/'
      end
  end

  

  def update_cpan_config config
      log 'update chef cpan client config'
      log config 
      template '/tmp/chef/cpan/.cpan/CPAN/MyConfig.pm' do
        cookbook  'cpan'
        source    'cpan-config.pm'
        config[:urllist] = node.run_state[:cpan][:urllist] unless config.has_key?(:urllist)
        variables( 
          :config => config
        )
        mode '0666'
        action :create
      end
  end

  def cpan_client_bin
    'perl /usr/local/bin/chef_cpan.pl'.freeze
  end

  def cpan_check_module_bin
    'perl /usr/local/bin/chef_check_installed_module.pl'.freeze
  end


  def cpan_dry_run?
    node.run_state[:cpan][:dryrun]
  end

  def cpan_dry_run_verbose?
    node.run_state[:cpan][:dryrun_verbose]
  end

  def cpan_client 
    if cpan_dry_run?
      "#{cpan_client_bin} -d -m".freeze
    else
      "#{cpan_client_bin} -m".freeze
    end 
  end

  def install_log_file module_name
    "/tmp/chef/cpan/install/#{module_name}_install.log"
  end 

  def install_ok_file module_name
    "/tmp/chef/cpan/install/#{module_name}_install.ok"
  end  

end
