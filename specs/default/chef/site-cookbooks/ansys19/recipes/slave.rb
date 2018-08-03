#
## Cookbook Name: ubercloud
## Recipe:: slave.rb
##
#

yum_package 'epel-release' do
        action :install
end

include_recipe "::nfsclient"
include_recipe "::dockerd"
include_recipe "::pull_container_slave"
include_recipe "::start_container_slave"

