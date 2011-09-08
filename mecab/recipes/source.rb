
pkgs = %w{ gcc gcc-c++ make automake autoconf}
pkgs.each do |pkg|
  package pkg
end

version = '0.98'
configure_options = "--enable-utf8-only"

remote_file "#{Chef::Config[:file_cache_path]}/mecab-#{version}.tar.gz" do
  source "http://sourceforge.net/projects/mecab/files/mecab/#{version}/mecab-#{version}.tar.gz/download"
end

bash "build mecab" do
  cwd  Chef::Config[:file_cache_path]
  code <<-EOF
  tar -xzf mecab-#{version}.tar.gz
  (cd mecab-#{version} && ./configure #{configure_options})
  (cd mecab-#{version} && make && make install)
  EOF
end

dic_version = "2.7.0-20070801"
dic_options = "--with-charset=utf8"

remote_file "#{Chef::Config[:file_cache_path]}/mecab-ipadic-#{dic_version}.tar.gz" do
  source "http://sourceforge.net/projects/mecab/files/mecab-ipadic/#{dic_version}/mecab-ipadic-#{dic_version}.tar.gz"
end

bash "build mecab-ipadic" do
  cwd  Chef::Config[:file_cache_path]
  code <<-EOF
  tar -xzf mecab-ipadic-#{dic_version}.tar.gz
  (cd mecab-ipadic-#{dic_version} && ./configure #{dic_options})
  (cd mecab-ipadic-#{dic_version} && make && make install)
  EOF
end

template "/etc/ld.so.conf.d/mecab.conf" do
  source "mecab.conf"
  owner "root"
  group "root"
  mode "0644"
end

execute "ldconfig"
