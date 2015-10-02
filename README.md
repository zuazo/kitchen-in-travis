kitchen-in-travis Cookbook [![Build Status](https://travis-ci.org/zuazo/kitchen-in-travis.svg?branch=master)](https://travis-ci.org/zuazo/kitchen-in-travis)
==========================

Proof of concept cookbook to run [test-kitchen](http://kitchen.ci/) inside [Travis CI](https://travis-ci.org/) using [kitchen-docker](https://github.com/portertech/kitchen-docker) in [User Mode Linux](https://github.com/jpetazzo/sekexe).

You can use this in your cookbook by using a *.travis.yml* file similar to the following:

```yaml
rvm:
- 2.2

sudo: true

before_script:
- source <(curl -sL https://raw.githubusercontent.com/zuazo/kitchen-in-travis/0.3.0/scripts/start_docker.sh)

script:
# Run test-kitchen with docker driver, for example:
- KITCHEN_LOCAL_YAML=.kitchen.docker.yml bundle exec kitchen test
```

Look [below](https://github.com/zuazo/kitchen-in-travis#how-to-implement-this-in-my-cookbook) for more complete examples.

The following files will help you understand how this works:

* [*.travis.yml*](https://github.com/zuazo/kitchen-in-travis/blob/master/.travis.yml)
* [*scripts/start_docker.sh*](https://github.com/zuazo/kitchen-in-travis/blob/master/scripts/start_docker.sh): Starts [Docker Engine](https://www.docker.com/docker-engine) inside Travis CI.
* [*.kitchen.docker.yml*](https://github.com/zuazo/kitchen-in-travis/blob/master/.kitchen.docker.yml)
* [*Rakefile*](https://github.com/zuazo/kitchen-in-travis/blob/master/Rakefile)

This example cookbook only installs nginx. It also includes some [Serverspec](http://serverspec.org/) tests to check everything is working correctly.

## Related Projects

* [kitchen-in-travis-native](https://github.com/zuazo/kitchen-in-travis-native): Runs test-kitchen inside Travis CI using the [native Docker service](http://blog.travis-ci.com/2015-08-19-using-docker-on-travis-ci/) and kitchen-docker. The builds are faster (~2 mins to start), but a little less customizable.
* [kitchen-in-circleci](https://github.com/zuazo/kitchen-in-circleci): Runs test-kitchen inside [CircleCI](https://circleci.com/).

## Install the Requirements

First you need to install [Docker](https://docs.docker.com/installation/).

Then you can use [bundler](http://bundler.io/) to install the required ruby gems:

    $ gem install bundle
    $ bundle install

## Running the Tests in Your Workstation

    $ bundle exec rake

This example will run kitchen **with Vagrant** in your workstation. You can use `$ bundle exec rake integration:docker` to run kitchen with Docker, as in Travis CI.

## Available Rake Tasks

    $ bundle exec rake -T
    rake integration:docker   # Run integration tests with kitchen-docker
    rake integration:vagrant  # Run integration tests with kitchen-vagrant

## How to Implement This in My Cookbook

First, create a `.kitchen.docker.yml` file with the platforms you want to test:

```yaml
---
driver:
  name: docker

platforms:
- name: centos-6.6
  run_list:
- name: ubuntu-14.04
  run_list:
  - recipe[apt]
# [...]
```

If not defined, it will get the platforms from the main `.kitchen.yml` by default.

You can get the list of the platforms officially supported by Docker [here](https://hub.docker.com/explore/).

Then, I recommend you to create a task in your *Rakefile*:

```ruby
# Rakefile
require 'bundler/setup'

# [...]

desc 'Run Test Kitchen integration tests'
namespace :integration do
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
```

This will allow us to use `$ bundle exec rake integration:docker` to run the tests.

The *.travis.yml* file example:

```yaml
rvm:
- 2.0.0
- 2.1
- 2.2

sudo: true

before_script:
- source <(curl -sL https://raw.githubusercontent.com/zuazo/kitchen-in-travis/0.3.0/scripts/start_docker.sh)

script:
- travis_retry bundle exec rake integration:docker
```

If you are using a *Gemfile*, you can add the following to it:

```ruby
# Gemfile

group :integration do
  gem 'test-kitchen', '~> 1.2'
end

group :docker do
  gem 'kitchen-docker', '~> 2.1.0'
end
```

This will be enough if you want to test only 2 or 3 platforms. If you want more, continue reading:

### How to Run Tests in Many Platforms

Travis CI has a build time limitation of **50 minutes**. If you want to test many platforms, you will need to split up the tests in multiple Travis CI builds. For those cases, I recommend you to use a *Rakefile* Rake task similar to the following:

```ruby
# Rakefile
require 'bundler/setup'

# [...]

desc 'Run Test Kitchen integration tests'
namespace :integration do
  # Gets a collection of instances.
  #
  # @param regexp [String] regular expression to match against instance names.
  # @param config [Hash] configuration values for the `Kitchen::Config` class.
  # @return [Collection<Instance>] all instances.
  def kitchen_instances(regexp, config)
    instances = Kitchen::Config.new(config).instances
    return instances if regexp.nil? || regexp == 'all'
    instances.get_all(Regexp.new(regexp))
  end

  # Runs a test kitchen action against some instances.
  #
  # @param action [String] kitchen action to run (defaults to `'test'`).
  # @param regexp [String] regular expression to match against instance names.
  # @param loader_config [Hash] loader configuration options.
  # @return void
  def run_kitchen(action, regexp, loader_config = {})
    action = 'test' if action.nil?
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    config = { loader: Kitchen::Loader::YAML.new(loader_config) }
    kitchen_instances(regexp, config).each { |i| i.send(action) }
  end

  desc 'Run integration tests with kitchen-vagrant'
  task :vagrant, [:regexp, :action] do |_t, args|
    run_kitchen(args.action, args.regexp)
  end

  desc 'Run integration tests with kitchen-docker'
  task :docker, [:regexp, :action] do |_t, args|
    run_kitchen(args.action, args.regexp, local_config: '.kitchen.docker.yml')
  end
end
```

This will allow us to run different kitchen tests using the `$ rake integration:docker[REGEXP]` command.

Then, you can use the following *.travis.yml* file:

```yaml
rvm:
- 2.0.0
- 2.1
- 2.2

sudo: true

env:
  matrix:
# Split up the test-kitchen run to avoid exceeding 50 minutes:
  - KITCHEN_REGEXP=centos
  - KITCHEN_REGEXP=debian
  - KITCHEN_REGEXP=ubuntu

before_script:
- source <(curl -sL https://raw.githubusercontent.com/zuazo/kitchen-in-travis/0.3.0/scripts/start_docker.sh)

script:
- travis_retry bundle exec rake integration:docker[$KITCHEN_REGEXP]
```

## Real-world Examples

* [netstat](https://github.com/zuazo/netstat-cookbook) cookbook ([*.travis.yml*](https://github.com/zuazo/netstat-cookbook/blob/master/.travis.yml), [*.kitchen.docker.yml*](https://github.com/zuazo/netstat-cookbook/blob/master/.kitchen.docker.yml), [*Rakefile*](https://github.com/zuazo/netstat-cookbook/blob/master/Rakefile)): Runs kitchen tests against many platforms. Includes a minimal Serverspec test.

* [opendkim](https://github.com/onddo/opendkim-cookbook) cookbook ([*.travis.yml*](https://github.com/onddo/opendkim-cookbook/blob/master/.travis.yml), [*.kitchen.docker.yml*](https://github.com/onddo/opendkim-cookbook/blob/master/.kitchen.docker.yml), [*Rakefile*](https://github.com/onddo/opendkim-cookbook/blob/master/Rakefile)): Runs kitchen tests in different Travis builds separated by platform. Includes Serverspec tests.

* [dovecot](https://github.com/onddo/dovecot-cookbook) cookbook ([*.travis.yml*](https://github.com/onddo/dovecot-cookbook/blob/master/.travis.yml), [*.kitchen.docker.yml*](https://github.com/onddo/dovecot-cookbook/blob/master/.kitchen.docker.yml), [*Rakefile*](https://github.com/onddo/dovecot-cookbook/blob/master/Rakefile)): Runs kitchen tests in different Travis builds separated by suite. Includes Serverspec and bats tests.

* [dhcp](https://github.com/chef-brigade/dhcp-cookbook) cookbook ([*.travis.yml*](https://github.com/chef-brigade/dhcp-cookbook/blob/master/.travis.yml), [*.kitchen.docker.yml*](https://github.com/chef-brigade/dhcp-cookbook/blob/master/.kitchen.docker.yml), [*Rakefile*](https://github.com/chef-brigade/dhcp-cookbook/blob/master/Rakefile)): Runs kitchen tests in different Travis builds separated by distribution. Includes Serverspec and bats tests.

* [onddo_proftpd](https://github.com/onddo/proftpd-cookbook) cookbook ([*.travis.yml*](https://github.com/onddo/proftpd-cookbook/blob/master/.travis.yml), [*.kitchen.docker.yml*](https://github.com/onddo/proftpd-cookbook/blob/master/.kitchen.docker.yml), [*Rakefile*](https://github.com/onddo/proftpd-cookbook/blob/master/Rakefile)): Runs kitchen tests in 9 different Travis builds. Includes Serverspec tests.

## Known Issues

### The Test Cannot Exceed 50 Minutes

Each test can not take more than 50 minutes to run within Travis CI. It's recommended to split the kitchen run in multiple builds using the [Travis CI build matrix](http://docs.travis-ci.com/user/customizing-the-build/#build-matrix).

Look at the examples in this documentation to learn how to avoid this.

### Official CentOS 7 and Fedora Images

Cookbooks requiring [systemd](http://www.freedesktop.org/wiki/Software/systemd/) may not work correctly on CentOS 7 and Fedora containers. See [*Systemd removed in CentOS 7*](https://github.com/docker-library/docs/tree/master/centos#systemd-integration).

You can use alternative images that include systemd. These containers must run in **privileged** mode:

```yaml
# .kitchen.docker.yml

# Non-official images with systemd
- name: centos-7
  driver_config:
    # https://registry.hub.docker.com/u/milcom/centos7-systemd/dockerfile/
    image: milcom/centos7-systemd
    privileged: true
- name: fedora
  driver_config:
    image: fedora/systemd-systemd
    privileged: true
```

### Problems with Upstart in Ubuntu

Some cookbooks requiring [Ubuntu Upstart](http://upstart.ubuntu.com/) may not work correctly.

You can use the official Ubuntu images with Upstart enabled:

```yaml
# .kichen.docker.yml

- name: ubuntu-14.10
  run_list: recipe[apt]
  driver_config:
    image: ubuntu-upstart:14.10
```

### Install `netstat` Package

It's recommended to install `net-tools` on some containers if you want to test listening ports with Serverspec. This is because some images come without `netstat` installed.

This is required for example for the following Serverspec test:

```ruby
# test/integration/default/serverspec/default_spec.rb
describe port(80) do
  it { should be_listening }
end
```

You can ensure that `netstat` is properly installed running the [`netstat`](https://supermarket.chef.io/cookbooks/netstat) cookbook:

 ```yaml
# .kitchen.docker.yml

- name: debian-6
  run_list:
  - recipe[apt]
  - recipe[netstat]
```

### Travis CI Error: *SSH session could not be established*

Sometimes kitchen exits with the following error:

    >>>>>> Converge failed on instance <default-debian-7>.
    >>>>>> Please see .kitchen/logs/default-debian-7.log for more details
    >>>>>> ------Exception-------
    >>>>>> Class: Kitchen::ActionFailed
    >>>>>> Message: SSH session could not be established
    >>>>>> --------

If you get this error on Travis CI, avoid passing the `--concurrency` option to test-kitchen. It does not work in some cases. I recommend using [the Travis CI build matrix to run multiple tests concurrently](#how-to-run-tests-in-many-platforms).

### Travis CI Error: *No output has been received in the last 10 minutes*

If a command can take a long time to run and is very quiet, you may need to run it with some flags to increase verbosity such as: `--verbose`, `--debug`, `--l debug`, ...

### Travis CI Error: Waiting Docker to Start Timeout (*No output has been received in the last 10 minutes*)

UML does not seem to work properly on some projects. The Travis build output in these cases:

```
$ source <(curl -sL https://raw.githubusercontent.com/zuazo/kitchen-in-travis/0.3.0/scripts/start_docker.sh)
[...]
Starting Docker Engine
Waiting Docker to start

No output has been received in the last 10 minutes, this potentially indicates a stalled build or something wrong with the build itself.
```

Try using [kitchen-in-travis-native](https://github.com/zuazo/kitchen-in-travis-native) or [kitchen-in-circleci](https://github.com/zuazo/kitchen-in-circleci) if you encounter this problem.

#### *Travis CI Error: Waiting Docker to Start Timeout* Debug Information

On some project builds [SLIRP](http://slirp.sourceforge.net/http://slirp.sourceforge.net/) seems not to work correctly. This is the exact error in the UML boot process:

```
$ ip link set eth0 up
RTNETLINK answers: No such file or directory
```

But the interface exists:

```
eth0      Link encap:Serial Line IP
          inet addr:10.1.1.1  Mask:255.255.255.0
          NOARP  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:256
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
          Interrupt:5
```

I have not found a way to fix the problem. Please, [let me know](https://github.com/zuazo/kitchen-in-travis/issues/new?title=Fix%20Waiting%20Docker%20to%20Start%20Timeout%20Error) if you find a solution.

## Feedback Is Welcome

Currently I'm using this for my own projects. It may not work correctly in many cases. If you use this or a similar approach successfully with other cookbooks, please [open an issue and let me know about your experience](https://github.com/zuazo/kitchen-in-travis/issues/new). Problems, discussions and ideas for improvement, of course, are also welcome.

## Acknowledgements

See [here](https://github.com/zuazo/docker-in-travis#acknowledgements).

# License and Author

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@zuazo.org>)
| **Contributor:**     | [Jacob McCann](https://github.com/jmccann)
| **Copyright:**       | Copyright (c) 2015, Xabier de Zuazo
| **License:**         | Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
