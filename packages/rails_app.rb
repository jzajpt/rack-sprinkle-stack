require 'securerandom'

package :rails_app, :provides => :app do
  description "Finalize settings for the rails app"

  requires :app_dir, :known_hosts, :postgres_user, :postgres_database,
    :database_config, :app_env_config, :app_nginx_config, :deploy_sudoers,
    :app_monit_config, :unicorn_script
end

package :app_dir do
  description 'Create the application directory'
  runner "mkdir -p /var/www/#{APP_NAME}"
  runner "chown '#{DEPLOY_USER}:#{DEPLOY_USER}' /var/www/#{APP_NAME}"

  verify do
    has_directory "/var/www/#{APP_NAME}"
  end
end

package :known_hosts do
  description "Add git host to known_hosts so that capistrano doesn't prompt for it"

  githost_key = `ssh-keyscan #{GIT_HOST}`
  known_hosts = "/home/#{DEPLOY_USER}/.ssh/known_hosts"
  push_text githost_key, known_hosts
  runner "chown -R #{DEPLOY_USER}:#{DEPLOY_USER} /home/#{DEPLOY_USER}/.ssh/known_hosts"

  verify do
    file_contains "/home/#{DEPLOY_USER}/.ssh/known_hosts", GIT_HOST
  end
end

package :postgres_user do
  runner %{echo "CREATE ROLE #{DB_USER} WITH LOGIN ENCRYPTED PASSWORD '#{DB_PASSWORD}';" | sudo -u postgres psql}

  verify do
    @commands << "echo 'SELECT ROLNAME FROM PG_ROLES' | sudo -u postgres psql | grep #{DB_USER}"
  end
end

package :postgres_database do
  runner "sudo -u postgres createdb --owner=#{DB_USER} #{DB_NAME}"

  verify do
    @commands << "sudo -u postgres psql -l | grep #{DB_NAME}"
  end
end

package :app_shared_config_dir do
  runner "mkdir -p /var/www/#{APP_NAME}/shared/config"
  runner "chown -R #{DEPLOY_USER}:#{DEPLOY_USER} /var/www/#{APP_NAME}/shared"
end

package :database_config do
  requires :app_shared_config_dir

  database_config_file = "/var/www/#{APP_NAME}/shared/config/database.yml"
  file database_config_file, :contents => render('database.yml')
  runner "chown -R #{DEPLOY_USER}:#{DEPLOY_USER} #{database_config_file}"

  verify do
    has_file database_config_file
  end
end

package :app_env_config do
  requires :app_shared_config_dir

  env_config_file = "/var/www/#{APP_NAME}/shared/config/dotenv"
  push_text "SECRET_TOKEN=#{SecureRandom.hex(42)}", env_config_file
  runner "chown -R #{DEPLOY_USER}:#{DEPLOY_USER} #{env_config_file}"
end

package :app_nginx_config do
  requires :nginx_binary

  nginx_config_file = "/etc/nginx/conf.d/#{APP_NAME}.conf"
  file nginx_config_file, :contents => render('nginx_server')

  verify do
    has_file nginx_config_file
  end
end

package :deploy_sudoers do
  sudoers = "/etc/sudoers.d/#{DEPLOY_USER}_conf"
  file sudoers, :contents => render('sudoers')
  runner "chmod 0440 #{sudoers}"

  verify do
    has_file sudoers
  end
end

package :app_monit_config do
  requires :monit_binary

  monit_config_file = "/etc/monit/conf.d/#{APP_NAME}.conf"
  file monit_config_file, :contents => render('monit_app')

  verify do
    has_file monit_config_file
  end
end

package :unicorn_script do
  requires :app_dir

  runner "mkdir -p /var/www/#{APP_NAME}/shared/bin"
  unicorn_script_file = "/var/www/#{APP_NAME}/shared/bin/unicorn_script.sh"
  file unicorn_script_file, :contents => render('unicorn_script.sh')
  runner "chown -R '#{DEPLOY_USER}:#{DEPLOY_USER}' #{unicorn_script_file}"
  runner "chmod +x #{unicorn_script_file}"

  verify do
    has_file unicorn_script_file
  end
end

