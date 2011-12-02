include_recipe "postgresql::server"
include_recipe "mecab::source"

package "postgresql-devel"

version = "9.0.0"

remote_file "#{Chef::Config[:file_cache_path]}/textsearch_ja-#{version}.tar.gz" do
  source "http://pgfoundry.org/frs/download.php/2943/textsearch_ja-#{version}.tar.gz"
end

bash "build textsearch_ja" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar -xzf textsearch_ja-#{version}.tar.gz
  (cd textsearch_ja-#{version} && make USE_PGXS=1 && make USE_PGXS=1 install)
  EOF
end
