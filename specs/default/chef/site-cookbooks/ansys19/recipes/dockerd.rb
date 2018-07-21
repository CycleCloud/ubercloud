#
# Cookbook Name: ubercloud
# Recipe:: dockerd.rb
#

%w(epel-release pdsh).each { |p| package p }

yum_repository 'dockerrepo' do
  description 'Docker Repository'
  baseurl 'https://yum.dockerproject.org/repo/main/centos/$releasever'
  gpgcheck false
  action :create
end

yum_package 'docker-engine = 1.13.0-1.el7.centos' do
  action :install
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
