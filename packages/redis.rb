package :redis, :provides => :nosql do
  description 'Install redis'

  apt 'redis-server'

  verify do
    has_executable 'redis-server'
    has_executable 'redis-cli'
    has_apt 'redis-server'
  end
end
