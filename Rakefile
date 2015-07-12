# -*- mode: ruby -*-
# vi: set ft=ruby :

# More info at https://github.com/ruby/rake/blob/master/doc/rakefile.rdoc

require 'bundler/setup'

desc 'Run Test Kitchen integration tests'
namespace :kitchen do

  desc 'Run integration tests with kitchen-vagrant'
  task :vagrant do
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      instance.test(:always)
    end
  end

  desc 'Run integration tests with kitchen-docker'
  task :docker do
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    @loader = Kitchen::Loader::YAML.new(local_config: '.kitchen.docker.yml')
    Kitchen::Config.new(loader: @loader).instances.each do |instance|
      instance.test(:always)
    end
  end
end

task default: %w(kitchen:vagrant)
