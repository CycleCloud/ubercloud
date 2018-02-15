#
# Cookbook Name: ubercloud
# Recipe:: consul.rb
#


# consul can be downloaded directly from
# https://releases.hashicorp.com/consul/1.0.5/consul_1.0.5_linux_amd64.zip?_ga=2.59416687.318928398.1518128675-318761031.1517007483
# But it has to be unzipped and placed accordingly
# Ender was implemented the consul installation in this way because he chose 
# the quick way to deploy it.

remote_file "/tmp/consul_1.0.5_linux_amd64.zip" do
  source "https://releases.hashicorp.com/consul/1.0.5/consul_1.0.5_linux_amd64.zip"
  owner 'root'
  mode '0644'
  action :create_if_missing  
end

# unzip file
execute "Install Consul" do
  command "unzip /tmp/consul_1.0.5_linux_amd64.zip -d /usr/local/sbin/"
end

systemd_unit 'consul.service' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Consul service

  [Service]
  Restart=always
  ExecStartPre=-/bin/mkdir -p /etc/consul /var/lib/consul
  ExecStart=/usr/local/sbin/consul agent -server -config-dir=/etc/consul --data-dir=/var/lib/consul -bootstrap -client 0.0.0.0 -bind 0.0.0.0 -advertise _HEAD_NODE_ETH0_IP_ADDRESS_
  LimitNOFILE=1024

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable]
end

systemd_unit 'consul.service' do
  action :start
end
