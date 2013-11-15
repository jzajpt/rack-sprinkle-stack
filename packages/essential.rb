package :apt_update do
  description 'Apt-get update'

  runner 'apt-get -y update'
end

package :build_essential do
  requires :apt_update
  description 'Build tools'

  apt 'build-essential'
end
