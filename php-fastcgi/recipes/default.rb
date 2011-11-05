%w{php5-cgi spawn-fcgi}.each do |pkg|
  package pkg
end

execute "bootstrap" do
  command "update-rc.d php-fastcgi defaults"
  action :nothing
end

template "/etc/init.d/php-fastcgi" do
  source "php-fastcgi.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :run, resources(:execute => "bootstrap")
end

service "php-fastcgi" do
  action :restart
end
