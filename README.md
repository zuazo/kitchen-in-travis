kitchen-travis-example Cookbook [![Build Status](http://img.shields.io/travis/zuazo/kitchen-travis-example-cookbook/master.svg?style=flat)](https://travis-ci.org/zuazo/kitchen-travis-example-cookbook)
===============================

Proof of concept cookbook to run [test-kitchen](http://kitchen.ci/) inside [Travis CI](https://travis-ci.org/) using [kitchen-docker](https://github.com/portertech/kitchen-docker) in [User Mode Linux](https://github.com/jpetazzo/sekexe).

Look the [*.travis.yml*](https://github.com/zuazo/kitchen-travis-example-cookbook/blob/master/.travis.yml) and [*.kitchen.docker.yml*](https://github.com/zuazo/kitchen-travis-example-cookbook/blob/master/.kitchen.docker.yml) files to understand how this works.

This example cookbook only installs nginx. It also includes some [Serverspec](http://serverspec.org/) tests to check everything is working correctly.

## Install the Requirements

First you need to install [Docker](https://docs.docker.com/installation/).

Then you can use [bundler](http://bundler.io/) to install the required ruby gems:

    $ gem install bundle
    $ bundle install

## Running the Tests in Your Workstation

    $ bundle exec rake

This example will run kitchen **with Vagrant** in your workstation. You can use `$ bundle exec rake kitchen:docker` to run kitchen with Docker, as in Travis CI.

## Available Rake Tasks

    $ bundle exec rake -T
    rake kitchen:docker   # Run integration tests with kitchen-docker
    rake kitchen:vagrant  # Run integration tests with kitchen-vagrant

## Known Issues

* Many cookbooks may not work correctly on `centos-7` images: [Systemd removed in CentOS 7](https://github.com/docker-library/docs/tree/master/centos#systemd-integration)

## Feedback is Welcome

Currently I'm using this for my own (small) projects. It may not work correctly in many cases. If you use this or a similar approach successfully with other cookbooks, please [open an issue and let me know about your experience](https://github.com/zuazo/kitchen-travis-example-cookbook/issues/new). Problems, discussions and ideas for improvement, of course, are also welcome.

# License and Author

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@zuazo.org>)
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
