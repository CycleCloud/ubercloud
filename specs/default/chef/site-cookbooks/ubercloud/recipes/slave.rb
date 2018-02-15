### Added for UberCloud containers to function properly

directory '/etc/docker' do
  action :create
end

# Search for master IP address
node.override['ubercloud']['is_master'] = true

ubercloud_master = cluster.search(:clusterUID => node['cyclecloud']['cluster']['id']).select { |n|
  not n['ubercloud'].nil? and n['ubercloud']['is_master'] == true
}

if ubercloud_master.length > 1
  raise("Found more than one ubercloud master node")
end

ubercloud_master_ip = ubercloud_master[0]["ipaddress"]

file '/etc/docker/daemon.json' do
  content <<-EOU.gsub(/^\s+/, '')
  {
  	"insecure-registries" : ["#{ubercloud_master_ip}:5000"]
  }

  EOU

  mode 0755
  owner 'root'
  group 'root'
end

include_recipe "::dockerd"

container_image_name = node["ubercloud"]["docker"]["container_image_name"]

execute 'pull image' do
  command "docker pull #{ubercloud_master_ip}:5000/#{container_image_name}  > /tmp/docker_tmp_file"

  only_if '/usr/bin/rpm -qa | /usr/bin/grep docker && /usr/bin/ps aux | /usr/bin/grep dockerd | /usr/bin/grep -v grep'

  creates '/tmp/docker_tmp_file'
end
