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

$user = 'deploy'

policy :myapp, roles: :app do

  requires :essential
  requires :tools
  requires :git
  requires :deployer
  requires :ruby
  requires :postgres
  requires :nosql
  requires :app

end

deployment do

  delivery :ssh do
    user ROOT_USER
    password ROOT_USER_PASSWORD
    role :app, HOST
  end


  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end

end

