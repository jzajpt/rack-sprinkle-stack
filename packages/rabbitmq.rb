
package :rabbitmq_binary, :provides => :message_bus do

  apt 'rabbitmq-server' do
    pre :install do
      push_text 'deb http://www.rabbitmq.com/debian/ testing main', '/etc/apt/sources.list'
    end
    pre :install, 'apt-get update -y'
  end

end
