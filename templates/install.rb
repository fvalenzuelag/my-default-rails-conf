####################
# Sprinkle installer
####################

package :build_essential do
  description 'Build tools'
  apt 'build-essential' do
    pre :install, 'apt-get update'
  end
end

package :vim do
  description "vim"
  apt 'vim'

  verify do
    has_apt 'vim'
  end
end

package :git_dependencies do
  description 'Git build dependencies'
  apt 'git-core', :dependencies_only => true
end

package :git, :provides => :scm do
  version '1.8.2'
  description 'Git distributed version control'
  requires :git_dependencies
  source "https://git-core.googlecode.com/files/git-#{version}.tar.gz"
  
  verify do
    has_file '/usr/local/bin/git'
  end
end

package :postgresql, :provides => :database do
  description 'PostgreSQL database'
  requires :build_essential
  apt %w( postgresql postgresql-client libpq-dev )
  
  verify do
    has_executable 'psql'
  end
end

package :language_dependencies do
  requires :build_essential
  apt %w(zlib1g-dev libreadline-dev libssl-dev libffi-dev libncurses5-dev)
end

package :nodejs do
  description 'Node.js Server-side Javascript'
  requires :language_dependencies
end

package :ruby do
  description 'Ruby programming language'
  version '2.0.0-p0'
  requires :language_dependencies
  source 'http://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p0.tar.gz'

  verify do
    has_executable "/usr/local/bin/ruby"
    has_executable "/usr/local/bin/irb"
  end
end

package :pg do
  description 'Ruby on Rails'
  gem 'pg'
end

package :rails do
  description 'Ruby on Rails'
  requires :pg
  run_with_tty "gem install rails"
end

policy :seg3app, :roles => :app do
  requires :build_essential
  requires :git
  requires :vim
  requires :postgresql
  requires :nodejs
  requires :ruby
  requires :rails
end

deployment do
  delivery :capistrano do
    recipes 'config/deploy'
  end

  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end
end
