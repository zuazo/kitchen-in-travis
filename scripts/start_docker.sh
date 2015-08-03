#!/bin/bash

#
# Installs and starts Docker Engine inside Travis CI using User Mode Linux
#

# Exit immediately if a simple command exits with a non-zero status
set -e

# Some travis bash functions
ANSI_YELLOW='\e[33;1m'
if ! type travis_fold &> /dev/null
then
  ANSI_RESET='\e[0m'

  travis_fold() {
    local ACTION="${1}"
    local NAME="${2}"
    echo "${NAME} ${ACTION}"
    [ x"${ACTION}" == x'end' ] && echo
  }
fi

travis_section() {
  echo -e "${ANSI_YELLOW}${*}${ANSI_RESET}"
}

travis_fold start env.setup
  travis_section 'Set environment variables'
  SLIRP_HOST="$(ip addr | awk '/scope global/ {print $2; exit}' | cut -d/ -f1)"
  SLIRP_PORTS="$(seq 2000 2500)"
  DOCKER_HOST="tcp://${SLIRP_HOST}:2375"
  DOCKER_PORT_RANGE=2400:2500
  export SLIRP_HOST DOCKER_HOST DOCKER_PORT_RANGE SLIRP_PORTS
  echo "SLIRP_HOST=${SLIRP_HOST}"
  echo "DOCKER_HOST=${DOCKER_HOST}"
  echo "DOCKER_PORT_RANGE=${DOCKER_PORT_RANGE}"
travis_fold end env.setup

travis_fold start docker.repository.install
  travis_section 'Install docker repository'
  wget -qO- https://get.docker.io/gpg | sudo apt-key add -
  echo 'deb https://get.docker.io/ubuntu docker main' \
    | sudo tee /etc/apt/sources.list.d/docker.list
travis_fold end docker.repository.install

travis_fold start apt.policy.setup
  travis_section 'Prevent APT from starting any service'
  echo exit 101 | sudo tee /usr/sbin/policy-rc.d
  sudo chmod +x /usr/sbin/policy-rc.d
travis_fold end apt.policy.setup

travis_fold start docker.install
  travis_section 'Install Docker'
  sudo apt-get -y update
  sudo apt-get -y install lxc lxc-docker slirp
  sudo sudo usermod -aG docker "${USER}"
travis_fold end docker.install

travis_fold start uml.download
  travis_section 'Download User Mode Linux scripts'
  git clone git://github.com/cptactionhank/sekexe
travis_fold end uml.download

travis_fold start docker.start
  travis_section 'Start Docker Engine'
  sekexe/run \
               'echo 2000 2500 > /proc/sys/net/ipv4/ip_local_port_range ' \
               '&& mount -t tmpfs -o size=8g tmpfs /var/lib/docker ' \
               '&& docker -D -d -H tcp://0.0.0.0:2375' \
               2>&1 \
             | tee -a docker_daemon.log &
travis_fold end docker.start

travis_fold start docker.wait
  travis_section 'Wait for Docker to start'
  while ! docker info > /dev/null
  do
    echo -n .
    sleep 1
  done
travis_fold end docker.wait

travis_section 'Docker Version'
docker version
