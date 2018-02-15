#
# Cookbook Name: ubercloud
# Recipe:: naster.rb
#

node.override['ubercloud']['is_master'] = true
cluster.store_discoverable()

include_recipe "::consul"
include_recipe "::dockerd"

docker_port = node["ubercloud"]["docker"]["port"]
private_registry_user = node["ubercloud"]["docker"]["private_registry_user"]
private_registry_user_password = node["ubercloud"]["docker"]["private_registry_user_password"]
private_registry_server = node["ubercloud"]["docker"]["private_registry_server"]
container_image_private_registry_uri = node["ubercloud"]["docker"]["container_image_private_registry_uri"]
container_image_name = node["ubercloud"]["docker"]["container_image_name"]


execute 'run_local_registry' do
  command "/usr/bin/docker run -d -p #{docker_port}:#{docker_port} --restart=always --name registry registry:2"
  
  only_if "/usr/bin/rpm -qa | /usr/bin/grep docker && /usr/bin/ps aux | /usr/bin/grep dockerd | /usr/bin/grep -v grep"
end


execute 'pull image' do
  command "docker login -u #{private_registry_user} -p #{private_registry_user_password} #{private_registry_server}; docker pull #{container_image_private_registry_uri} && docker tag #{container_image_private_registry_uri} localhost:#{docker_port}/#{container_image_name}  && docker push localhost:#{docker_port}/#{container_image_name}"

  only_if '/usr/bin/rpm -qa | /usr/bin/grep docker && /usr/bin/ps aux | /usr/bin/grep dockerd | /usr/bin/grep -v grep'
end
