package :install_rbenv do
  description 'Ruby RBEnv'
  runner  "sudo -u #{DEPLOY_USER} -i git clone git://github.com/sstephenson/rbenv.git /home/#{DEPLOY_USER}/.rbenv"
  runner "sudo -u #{DEPLOY_USER} -i git clone git://github.com/sstephenson/ruby-build.git /home/#{DEPLOY_USER}/.rbenv/plugins/ruby-build"

  push_text 'export PATH="$HOME/.rbenv/bin:$PATH"', "/home/#{DEPLOY_USER}/.profile"
  push_text 'eval "$(rbenv init -)"', "/home/#{DEPLOY_USER}/.profile"

  runner "chown '#{DEPLOY_USER}' /home/#{DEPLOY_USER}/.profile"

  verify do
    has_executable "/home/#{DEPLOY_USER}/.rbenv/bin/rbenv"
  end
end


package :install_rbenv_sudo do
  requires :install_rbenv
  description 'Ruby RBEnv-sudo'

  runner "sudo -u #{DEPLOY_USER} -i mkdir -p /home/#{DEPLOY_USER}/.rbenv/plugins"
  runner "sudo -u #{DEPLOY_USER} -i git clone git://github.com/dcarley/rbenv-sudo.git /home/#{DEPLOY_USER}/.rbenv/plugins/rbenv-sudo"

  verify do
    has_executable "/home/#{DEPLOY_USER}/.rbenv/plugins/rbenv-sudo/bin/rbenv-sudo"
  end
end


package :install_ruby do
  requires :install_rbenv
  requires :install_rbenv_sudo
  version '2.0.0-p247'

  runner "sudo -u #{DEPLOY_USER} -i rbenv install #{version}"
  runner "sudo -u #{DEPLOY_USER} -i rbenv rehash"

  verify do
    has_executable "/home/#{DEPLOY_USER}/.rbenv/shims/ruby"
  end
end


package :use_rbenv do
  requires :install_ruby

  version '2.0.0-p247'

  runner "sudo -u #{DEPLOY_USER} -i rbenv rehash"
  runner "sudo -u #{DEPLOY_USER} -i rbenv global #{version}"
  runner "sudo -u #{DEPLOY_USER} -i rbenv rehash"
end

package :config_gemrc do
  gemrc_template =`cat #{File.join(File.dirname(__FILE__), '..', 'assets', 'gemrc')}`
  gemrc_file = "/home/#{DEPLOY_USER}/.gemrc"

  push_text gemrc_template, gemrc_file
  runner "chown #{DEPLOY_USER}:#{DEPLOY_USER} #{gemrc_file}"

  verify do
    has_file gemrc_file
  end
end

package :update_rubygems do
  requires :use_rbenv
  requires :config_gemrc

  runner "sudo -u #{DEPLOY_USER} -i gem update --system"

  verify do
    has_executable "/home/#{DEPLOY_USER}/.rbenv/shims/gem"
  end
end

package :install_bundler do
  requires :use_rbenv
  requires :config_gemrc

  runner "sudo -u #{DEPLOY_USER} -i gem install bundler"
  runner "sudo -u #{DEPLOY_USER} -i rbenv rehash"

  verify do
    has_executable "/home/#{DEPLOY_USER}/.rbenv/shims/bundle"
  end
end

package :ruby_essentials do
  apt 'libssl-dev zlib1g zlib1g-dev libreadline-dev'
end


package :ruby do
  requires :ruby_essentials
  requires :config_gemrc
  requires :install_bundler
end
