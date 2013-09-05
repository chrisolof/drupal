#
# Author::  Alex Knoll (<alex@newmediadenver.com>)
# Cookbook Name:: drupal
# Recipe:: compass
#
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
compass = FALSE

node[:drupal][:sites].each do |key, data|
  site_name = key
  site = data

  if site[:compass]
    if site[:compass][:compile]
      compass = TRUE
    end
  end
end
if compass
  package "ruby-full" do
    action :install
  end
  package "rubygems" do
    action :install
  end
  # Need to reload OHAI to ensure the newest ruby is loaded up
  bash "install-compass" do
    code <<-EOH
     gem install compass
     gem install sass
     gem install bundler
     EOH
  end

  node[:drupal][:sites].each do |key, data|
    site_name = key
    site = data

    if (site[:compass][:compile]) and site[:compass][:watch_dir]
      bash "bundle-install" do
        cwd "/assets/#{site_name}/current/#{site[:compass][:watch_dir]}"
        code <<-EOH
          bundle install
          EOH
      end

      if site[:compass][:compile]
        bash "compass-compile" do
          cwd "/assets/#{site_name}/current/#{site[:compass][:watch_dir]}"
          code <<-EOH
            bundle exec compass compile /assets/#{site_name}/current/#{site[:compass][:watch_dir]}
            EOH
        end
      end
    end
  end
end
