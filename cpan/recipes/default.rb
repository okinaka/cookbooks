#
# Cookbook Name:: cpan
# Recipe:: default
#

directory '/tmp/chef/cpan/.cpan/CPAN/' do
  action :create
  recursive true
end

directory '/tmp/chef/cpan/install/' do
  action :delete
  recursive true
end

directory '/tmp/chef/cpan/install/' do
  action :create
end

directory '/tmp/chef/cpan/dry-run/' do
  action :delete
  recursive true
end

directory '/tmp/chef/cpan/dry-run/' do
  action :create
end

cookbook_file "/usr/local/bin/dry_run_logger.pl" do
  cookbook 'cpan'
  source "dry_run_logger.pl"
  owner "root"
  group "root"
  mode 0755
end

cookbook_file "/usr/local/bin/chef_cpan.pl" do
  cookbook 'cpan'
  source "chef_cpan.pl"
  owner "root"
  group "root"
  mode 0755
end

cookbook_file "/usr/local/bin/chef_check_installed_module.pl" do
  cookbook 'cpan'
  source "chef_check_installed_module.pl"
  owner "root"
  group "root"
  mode 0755
end

cookbook_file "/tmp/chef/cpan/.modulebuildrc" do
  cookbook 'cpan'
  source ".modulebuildrc"
  owner "root"
  group "root"
end

execute 'install CPAN 1.91' do
  command 'cpan i CPAN'
  not_if "perl -e 'use CPAN 1.91'"
end

execute "CPAN 1.91 installed okay" do
  command "perl -e 'use CPAN 1.91'"
end

execute 'install Getopt::Std' do
  command 'cpan i Getopt::Std'
  not_if "perl -e 'use Getopt::Std'"
end

execute "Getopt::Std installed okay" do
  command "perl -e 'use Getopt::Std'"
end


class Chef::Recipe
  include ModuleCpan
end

cpan_init

cpan_module 'CPAN::Version' do
  action 'install'
end

cpan_module 'Module::Build' do
  action 'install'
end

cpan_dry_run ENV['CHEF_DRY_RUN_VERBOSE'] if ENV['CHEF_DRY_RUN']

