# -*- mode: ruby -*-
# vi: set ft=ruby :

# More info at https://github.com/ruby/rake/blob/master/doc/rakefile.rdoc

require 'bundler/setup'

KITCHEN_RUN = 'kitchen test --log-level info'

desc 'Run Test Kitchen integration tests'
namespace :kitchen do

  desc 'Run integration tests with kitchen-vagrant'
  task :vagrant do
    ENV.delete('KITCHEN_LOCAL_YAML')
    sh KITCHEN_RUN
  end

  desc 'Run integration tests with kitchen-docker'
  task :docker do
    ENV['KITCHEN_LOCAL_YAML'] = '.kitchen.docker.yml'
    sh KITCHEN_RUN
  end

  desc 'Destroy all running instances'
  task :destroy do
    ENV.delete('KITCHEN_LOCAL_YAML')
    sh 'kitchen destroy'
    ENV['KITCHEN_LOCAL_YAML'] = '.kitchen.docker.yml'
    sh 'kitchen destroy'
  end
end

task default: %w(kitchen:vagrant)
