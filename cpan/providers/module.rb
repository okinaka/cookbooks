include Chef::Mixin::Command
include ModuleCpan

action :install do

  mod = @module.name
  version = @module.version

  if ((not @module.exists) or @module.from_source == true ) 
    log '******************'
    log "about installing module #{mod} of version # #{version} ..."
    install_module
    new_resource.updated_by_last_action(true)
  else
    log "module #{mod} of version #{version} already installed ..."
  end 
end

action :update do

  mod = @module.name
  version = @module.version

  log '******************'
  log "about updating module #{mod} to version # #{version} ..."
  install_module
  new_resource.updated_by_last_action(true)

end


def load_current_resource

  @module = Chef::Resource::CpanModule.new(new_resource.name)
  @module.version(new_resource.version)
  @module.name(new_resource.name)
  @module.force(new_resource.force)
  @module.exact_version(new_resource.exact_version)
  @module.release_version(new_resource.release_version)
  @module.from_source(new_resource.from_source)
  @module.cwd(new_resource.cwd)

  begin
    if run_command_with_systems_locale(:command => check_module_cmd) == 0
      @module.exists(true)
      node.run_state[:cpan][:install_summary] << { 
        :install_object => @module.name, :version => @module.version, :installed => true, :use_ok => true, :uptodate => true 
      }
    end
    rescue Chef::Exceptions::Exec => e
      @module.exists(false)
      log "cannot find module #{@module.name} installed on your system" do 
       level :debug
      end
  end
  nil
end

def check_module_cmd
  flags = ''
  flags <<  '-e' if @module.exact_version
  flags <<  '-d' if cpan_dry_run?
  flags <<  '-t' if @module.from_source
  "#{cpan_check_module_bin} #{flags} -m #{@module.name} -v #{@module.version}" 
end

def install_module_cmd 
  flags = ''
  flags <<  '-f' if @module.force
  flags <<  '-t' if @module.from_source
  flags <<  '-d' if cpan_dry_run?
  "#{cpan_client_bin} #{flags} -i #{install_object} -m #{@module.name}"

end

def install_object 
  @module.release_version ? @module.release_version : @module.name
end

def install_module

  mod = @module.name
  version = @module.version
  force = @module.force
  cwdir = @module.cwd

  log_file = install_log_file mod

  install_ok_file = install_ok_file mod

  execute "#{cpan_dry_run? ? 'dry-run' : 'real'} install #{install_object}" do
    command "#{install_module_cmd} > #{log_file}"
    action :run
    cwd cwdir  ? cwdir : './'
  end

  ruby_block "push to install_summary" do
    block do
      node.run_state[:cpan][:install_summary] << { 
        :install_object => install_object, :version => version, :uptodate => false
      }
    end
    action :create
  end

  ruby_block "UPDATE INSTALL SUMMARY DATA INSTALL-OK" do
    block do
      Chef::Log.info "#{mod} #{version} *--* INSTALL OKAY"
      node.run_state[:cpan][:install_summary][-1][:installed] = true
    end
    only_if "test -f #{install_ok_file}"
    action :create
  end   

  ruby_block "UPDATE INSTALL SUMMARY DATA INSTALL-FAILED" do
    block do
      Chef::Log.info "#{mod} #{version} *--* INSTALL FAILED"
      node.run_state[:cpan][:install_summary][-1][:installed] = false
    end
    not_if "test -f #{install_ok_file}"
    action :create
  end   

  ruby_block "UPDATE INSTALL SUMMARY DATA USE-OK" do
    block do
      Chef::Log.info "use  #{mod} #{version} *--* OKAY"
      node.run_state[:cpan][:install_summary][-1][:use_ok] = true
    end
    only_if check_module_cmd
    action :create
  end

  ruby_block "UPDATE INSTALL SUMMARY DATA USE-FAILED" do
    block do
      Chef::Log.info "use  #{mod} #{version} *--* FAILED"
      node.run_state[:cpan][:install_summary][-1][:use_ok] = false
    end
    not_if check_module_cmd
    action :create
  end

  ruby_block "INSTALL DETAILS" do
    block do
      Chef::Log.info '*** INSTALL DETAILS ***'
      grep_cmd = 'echo &&  perl -ne \''
      grep_cmd << 'print if /^\s+[\w+]+\/.*\.gz/ ... /\s+--\s+[A-Z]/ or /is up to date/i or /available on CPAN/i \''
      Chef::Log.info(`#{grep_cmd} #{log_file}`)
    end
    action :create
  end

  if cpan_dry_run?
    ruby_block "DRY-RUN STAT" do
      block do
        flags = ''
        flags << '-v' if cpan_dry_run_verbose?
        Chef::Log.info '*** DRY-RUN STAT ***'
        Chef::Log.info(`/usr/local/bin/dry_run_logger.pl /tmp/chef/cpan/dry-run/ #{flags} #{log_file}`)
      end
      action :create
    end
  end

end

