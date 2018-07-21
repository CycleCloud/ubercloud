#
# Cookbook Name: ubercloud
# Recipe:: nfsclient.rb
#

# Search for master IP address
ubercloud_master = cluster.search(:clusterUID => node['cyclecloud']['cluster']['id']).select { |n|
  not n['ubercloud'].nil? and n['ubercloud']['is_master'] == true
}

if ubercloud_master.length > 1
  raise("Found more than one ubercloud master node")
end

ubercloud_master_ip = ubercloud_master[0]["ipaddress"]


yum_package 'nfs-utils' do
  action :install
end

directory '/mnt/exports' do
  action :create
end

directory '/mnt/exports/shared' do
  mode 700
  owner 60001
  group 60001
  action :create
end

execute 'mount_nfs_share' do
	command "/bin/mount #{ubercloud_master_ip}:/mnt/exports/shared /mnt/exports/shared"
end
