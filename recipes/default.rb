#
# Cookbook Name:: memcached
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
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

package "libevent-1.4-2" do
  action :install
end

cookbook_file "/tmp/memcached_1.2.8-1_amd64.deb" do
  source "memcached_1.2.8-1_amd64.deb"
  owner node['account']['default']['user']
  group node['account']['default']['group']
  mode "0644"
end

package "memcached" do
  action :install
  source "/tmp/memcached_1.2.8-1_amd64.deb"
  provider Chef::Provider::Package::Dpkg
  not_if 'dpkg -s memcached | grep "Version: 1.2.8-1"'
end

service "memcached" do
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

template "/etc/memcached.conf" do
  backup 5
  source "memcached.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
      :verbosity => node[:memcached][:verbosity],
      :listen => node[:memcached][:listen],
      :user => node[:account][:daemon][:user],
      :port => node[:memcached][:port],
      :memory => node[:memcached][:memory]
  )
  notifies :restart, resources(:service => "memcached"), :immediately
end

script "enable and hold memcached" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    echo "ENABLE_MEMCACHED=yes" > /etc/default/memcached 
    dpkg --get-selections memcached
    echo memcached hold | dpkg --set-selections
    dpkg --get-selections memcached
    aptitude hold memcached -y
  EOH
  not_if 'grep ENABLE_MEMCACHED=yes /etc/default/memcached'
end