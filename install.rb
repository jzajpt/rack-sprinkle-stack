#!/usr/bin/env sprinkle -s

require './config'
require './packages/essential'
require './packages/git'
require './packages/deploy_user'
require './packages/ruby'
require './packages/postgres'
require './packages/redis'
require './packages/utilities'
require './packages/rails_app'
require './packages/rabbitmq'
require './packages/nginx'
require './packages/monit'

policy :myapp, roles: :app do

  requires :apt_update
  requires :tools
  requires :git
  requires :deployer
  requires :ruby
  requires :postgres
  requires :nosql
  requires :message_bus
  requires :app
  requires :webserver
  requires :monitoring

end

deployment do

  delivery :ssh do
    user defined?(ROOT_USER) ? ROOT_USER : 'root'
    password defined?(ROOT_USER_PASSWORD) ? ROOT_USER_PASSWORD : nil
    role :app, HOST
  end

  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end

end

