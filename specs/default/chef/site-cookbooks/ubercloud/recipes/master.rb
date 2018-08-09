#
# Cookbook Name: ubercloud
# Recipe:: master.rb
#

yum_package 'epel-release' do
        action :install
end
 
include_recipe "::disable_nouveau"
include_recipe "::lis"
include_recipe "::nvidia"
include_recipe "::nfsserver"
include_recipe "::dockerd"
include_recipe "::consul"
include_recipe "::pull_container_master"
include_recipe "::start_container_master"

