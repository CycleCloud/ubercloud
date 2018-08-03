# Search for master IP address
node.override['ubercloud']['is_master'] = true
cluster.store_discoverable()

ubercloud_master = cluster.search(:clusterUID => node['cyclecloud']['cluster']['id']).select { |n|
  not n['ubercloud'].nil? and n['ubercloud']['is_master'] == true
}

if ubercloud_master.length > 1
  raise("Found more than one ubercloud master node")
end

ubercloud_master_ip = ubercloud_master[0]["ipaddress"]


private_registry_user = node["ubercloud"]["docker"]["private_registry_user"]
customer_email_address = node["ubercloud"]['docker']['customer_email_address']
license_server_string = node["ubercloud"]["docker"]["ansys_license_server"]
dcv_server_string = node["ubercloud"]["docker"]["dcv_license_server"]




file '/tmp/start_container' do
  mode 0755
  owner 'root'
  group 'root'

  content <<-EOU.gsub(/^\s+/, '')
    #!/bin/bash
    image_id=`docker images  | grep -i azurecr | awk '{print $3}'`
    docker run -d --privileged --net host -v '/mnt/exports/shared/hpcuser:/home/hpcuser/cluster_shared_storage' --env "ENV_PRODUCT=default" --env "ENV_CLUSTER_DISCOVERY=consul://#{ubercloud_master_ip}:8500" --env "ENV_NOVNCD_PORT=5901" --env "ENV_NOVNC_PORT=5901" --env "ENV_USE_INTERFACE=eth0" --env "ENV_CUSTOMER_EMAIL=#{customer_email_address}" --env "ENV_SSH_PORT=1022" --env "ENV_SSHD_PORT=1022" --env "ENV_ORDER_NUMBER=ubercloud_cluster_for_#{private_registry_user}" --env "ENV_LICENSE_SERVER=#{license_server_string}" --env "ENV_DCV_LICENSE=#{dcv_server_string}" -p 7300-7399:7300-7399 -p 5900:5900  $image_id
   cont_id=`docker ps -q`
  EOU

  action :create_if_missing
end

execute 'start_container' do
	command "/tmp/start_container"

	only_if "docker ps | grep init; runtest=$?; docker images | grep azurecr ; imagetest=$?; test $runtest == 1 && test $imagetest == 0"
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
