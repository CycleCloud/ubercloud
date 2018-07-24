#
# Cookbook Name: ubercloud
# Recipe:: nfsserver.rb
#

yum_package 'nfs-utils' do
  action :install
end

file '/etc/exports' do
  mode 0644
  owner 'root'
  group 'root'

  content <<-EOU.gsub(/^\s+/, '')
    /mnt/exports/shared	10.0.0.0/8(rw,async)
  EOU

  action :create
end

directory '/mnt/exports' do
end

directory '/mnt/exports/shared' do
end

directory '/mnt/exports/shared/hpcuser' do
  mode 0700
  owner 60001
  group 60001
end

systemd_unit 'nfs.service' do
  action [:enable, :start]
end

execute 'exportfs' do
	command "/sbin/exportfs -ra"
end
