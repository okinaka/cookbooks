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

package "libpath-class-perl" do
  action :install
end

cpan_mods = [
  "Class::Accessor::Fast::XS",
  "Crypt:CBC",
  "Crypt::DES",
  "DBIx::Skinny",
  "Email::AddressParser",
  "Error",
  "JSON::Syck",
  "Path::Class::File::Lockable",
  "Perl6::Slurp",
  "Term::ProgressBar",
  "Text::ASCIITable"]
cpan_mods.each do |module_name|
  cpan_module module_name 
end

version = "2.7.3"

remote_file "#{Chef::Config[:file_cache_path]}/bouncehammer-#{version}.tar.gz" do
  source "http://dist.bouncehammer.jp/bouncehammer-#{version}.tar.gz"
  mode "0644"
end

configure_options = "--disable-webui --prefix=/usr/local/bouncehammer"
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
sqlite_pkgs = ["sqlite3", "libdbd-sqlite3-perl"]
sqlite_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end
script "setup_sqlite" do
  interpreter "bash"
  cwd "/usr/local/bouncehammer"
  code <<-EOF
  touch var/db/bouncehammer.db
  cat share/script/SQLite*.sql | sqlite3 var/db/bouncehammer.db
  cat share/script/mastertable-* | sqlite3 var/db/bouncehammer.db
  EOF
end

cookbook_file "/usr/local/bouncehammer/etc/bouncehammer.cf" do
  source "bouncehammer.cf"
end
