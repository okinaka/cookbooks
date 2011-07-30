#
# Cookbook Name:: bouncehammer
# Recipe:: default
#
# Copyright 2011, Okinaka
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "perl"

base_pkgs = ["build-essential", "perl-doc"]
base_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

perl_pkgs = [
    "libcompress-zlib-perl",
    "libcrypt-cbc-perl", 
    "libcrypt-des-perl",
    "liberror-perl",
    "libpath-class-perl",
    "libperl6-slurp-perl",
    "libterm-progressbar-perl",
    "libtext-asciitable-perl",
    "libdbd-sqlite3-perl",
    "libtime-piece-perl",
    "libyaml-syck-perl"
  ]
perl_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

cpan_mods = [
  "Class::Accessor::Fast::XS",
  "DBIx::Skinny",
  "Email::AddressParser",
  "Path::Class::File::Lockable",
  ]
cpan_mods.each do |module_name|
  cpan_module module_name 
end

version = node[:bouncehammer][:version]
dist_dir = node[:bouncehammer][:dir]

remote_file "#{Chef::Config[:file_cache_path]}/bouncehammer-#{version}.tar.gz" do
  source "http://dist.bouncehammer.jp/bouncehammer-#{version}.tar.gz"
  mode "0644"
end

configure_options = "--disable-webui --prefix=#{dist_dir}"
script "build_bouncehammer" do
  interpreter "bash"
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar -xzvf bouncehammer-#{version}.tar.gz
  (cd bouncehammer-#{version} && ./configure #{configure_options})
  (cd bouncehammer-#{version} && make && make install)
  EOF
end

# For sqlite.
sqlite_pkgs = ["sqlite3", ]
sqlite_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end
script "setup_sqlite" do
  interpreter "bash"
  cwd dist_dir
  code <<-EOF
  touch var/db/bouncehammer.db
  cat share/script/SQLite*.sql | sqlite3 var/db/bouncehammer.db
  cat share/script/mastertable-* | sqlite3 var/db/bouncehammer.db
  EOF
end

cookbook_file "#{dist_dir}/etc/bouncehammer.cf" do
  source "bouncehammer.cf"
end
