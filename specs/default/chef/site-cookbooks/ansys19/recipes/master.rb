#
# Cookbook Name: ubercloud
# Recipe:: master.rb
#

node.override['ubercloud']['is_master'] = true
cluster.store_discoverable()

include_recipe "::nfsserver"
include_recipe "::dockerd"

docker_port = node["ubercloud"]["docker"]["port"]
private_registry_user = node["ubercloud"]["docker"]["private_registry_user"]
private_registry_user_password = node["ubercloud"]["docker"]["private_registry_user_password"]
private_registry_server = node["ubercloud"]["docker"]["private_registry_server"]
container_image_private_registry_uri = node["ubercloud"]["docker"]["container_image_for_headnode_private_registry_uri"]
container_image_name = node["ubercloud"]["docker"]["container_image_name"]
customer_email_address = node["ubercloud"]['docker']['customer_email_address']
registry_username = node["ubercloud"]['docker']['private_registry_user']
license_server_string = node["ubercloud"]["docker"]["ansys_license_server"]
dcv_server_string = node["ubercloud"]["docker"]["dcv_license_server"]

# Search for master IP address
node.override['ubercloud']['is_master'] = true

ubercloud_master = cluster.search(:clusterUID => node['cyclecloud']['cluster']['id']).select { |n|
  not n['ubercloud'].nil? and n['ubercloud']['is_master'] == true
}

if ubercloud_master.length > 1
  raise("Found more than one ubercloud master node")
end

ubercloud_master_ip = ubercloud_master[0]["ipaddress"]


include_recipe "::consul"


### Added for UberCloud containers to function properly

directory '/etc/docker' do
  action :create
end

file '/tmp/pull_image' do
  mode 0755
  owner 'root'
  group 'root'
end

execute 'pull image' do
  command "docker login -u #{private_registry_user} -p #{private_registry_user_password} #{private_registry_server}; docker pull #{container_image_private_registry_uri} && rm -f /tmp/pull_image"

  only_if "/usr/bin/rpm -qa | /usr/bin/grep docker && /usr/bin/ps aux | /usr/bin/grep dockerd | /usr/bin/grep -v grep && test -e /tmp/pull_image"
end

file '/tmp/get_cluster_nodes' do
  mode 0755
  owner 'root'
  group 'root'

  content <<-EOU.gsub(/^\s+/, '')
    #!/bin/bash

    cat /dev/null > /home/hpcuser/Desktop/cluster_nodes.txt

    for i in `curl http://#{ubercloud_master_ip}:8500/v1/kv/cluster?keys | sed 's/"//g' | sed 's/\\\[//g' | sed 's/\\\]//g' | awk -F ',' '{ for (i=0; i<=NF; ++i) print $i; }' | awk -F '/' '{print $3}' | grep -v cluster| sort -u | xargs`
    do
      echo $i >> /home/hpcuser/Desktop/cluster_nodes.txt
    done
  EOU

  action :create_if_missing
end


file '/tmp/start_container' do
  mode 0755
  owner 'root'
  group 'root'

  content <<-EOU.gsub(/^\s+/, '')
    #!/bin/bash

    image_id=`docker images  | grep -i ansys | awk '{print $3}'`

    docker run -d --privileged --net host -v '/mnt/exports/shared/hpcuser:/home/hpcuser/cluster_shared_storage' --env "ENV_PRODUCT=default" --env "ENV_CLUSTER_DISCOVERY=consul://#{ubercloud_master_ip}:8500" --env "ENV_NOVNCD_PORT=5901" --env "ENV_NOVNC_PORT=5901" --env "ENV_USE_INTERFACE=eth0" --env "ENV_CUSTOMER_EMAIL=#{customer_email_address}" --env "ENV_SSH_PORT=1022" --env "ENV_SSHD_PORT=1022" --env "ENV_ORDER_NUMBER=ansys_cluster_for_#{registry_username}" --env "ENV_LICENSE_SERVER=#{license_server_string}" --env "ENV_DCV_LICENSE=#{dcv_server_string}" -p 7300-7399:7300-7399 -p 5900:5900  $image_id

   cont_id=`docker ps -q`

   docker cp /tmp/get_cluster_nodes $cont_id:/usr/local/bin/get_cluster_nodes

  EOU

  action :create_if_missing
end

execute 'start_container' do
	command "/tmp/start_container"

	only_if "docker ps | grep init; runtest=$?; docker images | grep ansys ; imagetest=$?; test $runtest == 1 && test $imagetest == 0"
end

execute 'copy get_cluster_nodes inside container' do
  command "docker cp /tmp/get_cluster_nodes `docker ps -q`:/usr/local/bin/get_cluster_nodes"
end


remote_file '/tmp/unmount_azure_encrypted_storage' do
  source 'https://s3.amazonaws.com/ubercloud.public.tools/temporary/unmount_azure_encrypted_storage'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

remote_file '/tmp/mount_azure_encrypted_storage' do
  source 'https://s3.amazonaws.com/ubercloud.public.tools/temporary/mount_azure_encrypted_storage'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'enable encrypted file share on azure' do
  command "docker exec -t `docker ps -q` bash -c 'yum install -y cifs-utils; yum install -y sudo; echo \"hpcuser ALL=(ALL) NOPASSWD: /bin/mount, /bin/umount\" >> /etc/sudoers; mkdir /home/hpcuser/encrypted_storage; chown hpcuser:hpcuser /home/hpcuser/encrypted_storage;'; docker cp /tmp/unmount_azure_encrypted_storage `docker ps -q`:/usr/local/bin/unmount_azure_encrypted_storage; docker cp /tmp/mount_azure_encrypted_storage `docker ps -q`:/usr/local/bin/mount_azure_encrypted_storage;"
end
