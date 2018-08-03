#
# Cookbook Name: ubercloud
# Recipe:: nfsclient.rb
#

# Search for master IP address
cluster.store_discoverable()

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
  action :create
end

execute 'mount_nfs_share' do
	command "/bin/mount #{ubercloud_master_ip}:/mnt/exports/shared /mnt/exports/shared"
	only_if "df -h | grep exports | grep shared; mount_test=$?; test $mount_test == 1"
end
