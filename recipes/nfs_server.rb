#
# Author::  Christopher Caldwell (<chrisolof@gmail.com>)
# Cookbook Name:: drupal
# Recipe:: nfs_server
#
# Copyright 2013, Christopher Caldwell.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Chef::Log.debug "drupal::nfs_server - node[:drupal][:server][:nfs_exports] = #{node[:drupal][:server][:nfs_exports].inspect}"

# Set up our exports, if we have any
unless node[:drupal][:server][:nfs_exports].nil?
  # Make sure we have the required package to export NFS shares
  package 'nfs-kernel-server'
  # Iterate through our exports
  node[:drupal][:server][:nfs_exports].each do |export_directory, export|
    # Iterate through the clients permitted to access this export
    export[:clients].each do |client_network, client|
      nfs_export "#{export_directory}" do
        network "#{client_network}"
        # Add export details if they've been specified (nfs cookbook provides
        # defaults)
        unless client[:writeable].nil?
          writeable client[:writeable]
        end
        unless client[:sync].nil?
          sync client[:sync]
        end
        unless client[:options].nil?
          options client[:options]
        end
      end
    end
  end
  # Make NFS server aware of our new export(s)
  execute "exportfs -ra" do
    command "exportfs -ra"
  end
end
