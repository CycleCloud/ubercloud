private_registry_user = node["ubercloud"]["docker"]["private_registry_user"]
private_registry_user_password = node["ubercloud"]["docker"]["private_registry_user_password"]
private_registry_server = node["ubercloud"]["docker"]["private_registry_server"]
container_image_private_registry_uri = node["ubercloud"]["docker"]["container_image_for_headnode_private_registry_uri"]

file '/tmp/pull_image' do
  mode 0755
  owner 'root'
  group 'root'
end

execute 'pull image' do
  command "docker login -u #{private_registry_user} -p #{private_registry_user_password} #{private_registry_server}; docker pull #{container_image_private_registry_uri} && rm -f /tmp/pull_image"

  only_if "/usr/bin/rpm -qa | /usr/bin/grep docker && /usr/bin/ps aux | /usr/bin/grep dockerd | /usr/bin/grep -v grep && test -e /tmp/pull_image"
end

