#
# Cookbook Name: ubercloud
# Recipe:: consul.rb
#

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


# download consul
remote_file "/tmp/consul_1.0.5_linux_amd64.zip" do
  source "https://releases.hashicorp.com/consul/1.0.5/consul_1.0.5_linux_amd64.zip"
  owner 'root'
  mode '0644'
  action :create_if_missing  
end

# unzip file
execute "Install Consul" do
  command "unzip -o /tmp/consul_1.0.5_linux_amd64.zip -d /usr/local/sbin/"
end

systemd_unit 'consul.service' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Consul service

  [Service]
  Restart=always
  ExecStartPre=-/bin/mkdir -p /etc/consul /var/lib/consul
  ExecStart=/usr/local/sbin/consul agent -server -config-dir=/etc/consul --data-dir=/var/lib/consul -bootstrap -client 0.0.0.0 -bind 0.0.0.0 -advertise #{ubercloud_master_ip} 
  LimitNOFILE=1024

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable]
end

systemd_unit 'consul.service' do
  action :start
end
