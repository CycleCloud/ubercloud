#
# Cookbook Name: ubercloud
# Recipe:: dockerd.rb
#

yum_repository 'docker-ce' do
  description 'Docker Repository'
  baseurl 'https://download.docker.com/linux/centos/7/$basearch/stable'
  gpgcheck false
  action :create
end

yum_package 'device-mapper-persistent-data' do
	action :install
end

yum_package 'docker-ce = 18.03.1.ce-1.el7.centos' do
  action :install
end

directory '/etc/docker' do
        action :create
end

file '/etc/docker/daemon.json' do
        content <<-EOU.gsub(/^\s+/, '')
                {
                        "storage-driver": "devicemapper",
                        "storage-opts": [
                                "dm.basesize=256G"
                        ]
                }
        EOU

        action :create_if_missing
end

systemd_unit 'docker.service' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Docker Application Container Engine
  Documentation=https://docs.docker.com
  After=network-online.target firewalld.service
  Wants=network-online.target

  [Service]
  Type=notify
  ExecStart=/usr/bin/dockerd -g /mnt/resource/docker-data
  ExecReload=/bin/kill -s HUP $MAINPID
  LimitNOFILE=infinity
  LimitNPROC=infinity
  LimitCORE=infinity
  TimeoutStartSec=0
  Delegate=yes
  KillMode=process
  Restart=on-failure
  StartLimitBurst=3
  StartLimitInterval=60s
  
  [Install]
  WantedBy=multi-user.target
  
  EOU
  
  action [:create, :enable]
end

systemd_unit 'docker.service' do
  action :start
end
