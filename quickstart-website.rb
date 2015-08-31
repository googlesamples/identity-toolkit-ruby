# Copyright 2014 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
require 'gitkit_client'
require 'sinatra'
require 'cgi'
require 'pp'

gitkit_client = GitkitLib::GitkitClient.create_from_config_file 'gitkit-server-config.json'

set :port, 8000

# Page with the Gitkit Sign In button
get '/' do
  token = request.cookies['gtoken']
  gitkit_user,_ = gitkit_client.verify_gitkit_token token
  erb File.read('login.html'), :locals => {:gitkit_user => gitkit_user}
end

# Gitkit widget page for password login and federated login
get '/gitkit' do
  erb File.read('widget.html'), :locals => {:postBody => CGI.escape(request.body.read)}
end

# IDP may post assertion to the endpoint
post '/gitkit' do
  erb File.read('widget.html'), :locals => {:postBody => CGI.escape(request.body.read)}
end

# Endpoint to send email for ResetPassword & ChangeEmail actions
post '/sendemail' do
  result = gitkit_client.get_oob_result params, request.ip, request.cookies['gtoken']
  # Actual application should send email according to the result
  # In this sample code we only print out the result object
  pp result
  result[:response_body]
end
