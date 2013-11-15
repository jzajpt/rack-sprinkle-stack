package :nginx_binary, :provides => :webserver do

  apt 'nginx' do
    pre :install do
      push_text 'deb http://nginx.org/packages/ubuntu/ precise nginx', '/etc/apt/sources.list'
    end
    pre :install, 'apt-get update -y'
  end

end
