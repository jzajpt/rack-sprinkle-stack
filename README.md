# Rack Sprinkle Stack

A set of Sprinkle config files to setup Rack stack with rbenv, PostgreSQL, 
Redis & Rails application.

## Packages

Following packages will be installed:

* Git
* htop
* tmux
* ImageMagick
* Vim
* RBenv (local install under deploy user)
* Ruby 2.0
* Redis
* Postgresql

## Usage

Install Sprinkle gem on your local machine:

```shell
gem install sprinkle
```

Create `config.rb` file (use `config.rb.sample` as and example) and run 
Sprinkle:

```shell
sprinkle -c -s install.rb 
```

Please note that setup this has been tested only on Ubuntu 12.04 LTS.

