#
# Copyright:: Copyright (c) 2018 GitLab Inc.
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

require 'rainbow'
require "#{base_path}/embedded/service/omnibus-ctl/lib/gitlab_ctl"

add_command_under_category('renew-le-certs', "Let's Encrypt", "Renew the existing Let's Encrypt certificates", 2) do
  node_attributes = GitlabCtl::Util.get_node_attributes
  auto_renew_log_directory = node_attributes['letsencrypt']['auto_renew_log_directory']

  unless node_attributes['letsencrypt']['enable']
    $stderr.puts 'LetsEncrypt is not enabled in your gitlab.rb. Have you run "gitlab-ctl reconfigure" yet?'
    exit 1
  end

  remove_old_node_state

  status = GitlabCtl::Util.chef_run('solo.rb', 'renew-letsencrypt.json', "#{auto_renew_log_directory}/renewal.#{Time.now.to_i}.log")
  $stdout.puts status.stdout
  $stderr.puts Rainbow("There was an error renewing Let's Encrypt certificates, please checkout the output").red if status.error?
end
