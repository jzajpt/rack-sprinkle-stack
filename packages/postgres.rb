package :postgres, :provides => :database do
  description 'PostgreSQL database'
  requires :postgres_core# , :postgres_user, :postgres_database, :postgres_autostart
end

package :postgres_core do
  apt %w( postgresql postgresql-contrib postgresql-client libpq-dev )

  verify do
    has_executable 'psql'
    has_apt 'postgresql'
    has_apt 'postgresql-contrib'
    has_apt 'postgresql-client'
    has_apt 'libpq-dev'
  end
end

package :postgres_autostart do
  description "PostgreSQL: Autostart on reboot"
  requires :postgres_core

  runner '/usr/sbin/update-rc.d postgresql defaults'
end

%w[start stop restart reload].each do |command|
  package :"postgres_#{command}" do
    requires :postgres_core

    runner "/etc/init.d/postgresql #{command}"
  end
end
