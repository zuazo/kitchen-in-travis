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
  travis_section 'Setting environment variables for Docker'
  SLIRP_HOST="$(ip addr | awk '/scope global/ {print $2; exit}' | cut -d/ -f1)"
  SLIRP_MIN_PORT='2375'
  SLIRP_MAX_PORT='2400'
  SLIRP_PORTS="$(seq "${SLIRP_MIN_PORT}" "${SLIRP_MAX_PORT}")"
  DOCKER_HOST="tcp://${SLIRP_HOST}:${SLIRP_MIN_PORT}"
  DOCKER_PORT_RANGE="$((SLIRP_MIN_PORT+1)):${SLIRP_MAX_PORT}"
  export SLIRP_HOST DOCKER_HOST DOCKER_PORT_RANGE SLIRP_PORTS
  echo "SLIRP_HOST=${SLIRP_HOST}"
  echo "DOCKER_HOST=${DOCKER_HOST}"
  echo "DOCKER_PORT_RANGE=${DOCKER_PORT_RANGE}"
travis_fold end env.setup
echo

travis_fold start docker.repository.install
  travis_section 'Installing docker repository'
  wget -qO- https://get.docker.io/gpg | sudo apt-key add -
  echo 'deb https://get.docker.io/ubuntu docker main' \
    | sudo tee /etc/apt/sources.list.d/docker.list
travis_fold end docker.repository.install
echo

travis_fold start apt.policy.setup
  travis_section 'Preventing APT from starting any service'
  echo exit 101 | sudo tee /usr/sbin/policy-rc.d
  sudo chmod +x /usr/sbin/policy-rc.d
travis_fold end apt.policy.setup
echo

travis_fold start docker.install
  travis_section 'Installing Docker'
  sudo apt-get -y update
  sudo apt-get -y install lxc lxc-docker slirp
  sudo sudo usermod -aG docker "${USER}"
travis_fold end docker.install
echo

travis_fold start uml.download
  travis_section 'Downloading User Mode Linux scripts'
  travis_retry git clone git://github.com/cptactionhank/sekexe
travis_fold end uml.download
echo

#travis_fold start uml.test
#  travis_section 'Testing UML'
#  sekexe/run
#travis_fold end uml.test

travis_fold start docker.start
  travis_section 'Starting Docker Engine'
  sekexe/run \
    "echo ${SLIRP_MIN_PORT} ${SLIRP_MAX_PORT} > /proc/sys/net/ipv4/ip_local_port_range " \
    '; echo ====================' \
    '; echo DOCKER ENGINE START' \
    '; echo ====================' \
    '; uname -a ' \
    '; ifconfig -a ' \
    '; ulimit -a ' \
    '; ( sleep 5 ' \
      '&& echo ====================' \
      '&& echo DOCKER ENGINE STATUS' \
      '&& echo ====================' \
      '&& ps axu ' \
      '&& netstat -puatn & ) ' \
    "; docker -D -d -H tcp://0.0.0.0:${SLIRP_MIN_PORT}" \
    2>&1 \
             | tee -a docker_daemon.log &
travis_fold end docker.start
echo

echo 'Kernel:'
sudo uname -a
echo 'Network interfaces:'
sudo /sbin/ifconfig -a
echo 'Network status:'
sudo netstat -puatn
echo 'Process list:'
sudo ps axu | grep 'docke[r]'
echo 'Loaded Kernel Modules:'
sudo lsmod
echo 'Limits:'
ulimit -a
echo 'Limits (root):'
sudo bash -c 'ulimit -a'
echo 'Network interfaces:'
echo 'dmesg:'
sudo dmesg | tail -50
echo 'Docker client version:'
docker --version

travis_fold start docker.wait
  travis_section 'Waiting for Docker to start'
  while ! docker info &> /dev/null
  do
    echo -n .
    sleep 1
  done
travis_fold end docker.wait
echo

travis_section 'Docker version:'
docker version
echo
