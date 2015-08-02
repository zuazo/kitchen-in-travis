#!/bin/bash

#
# Installs and starts Docker Engine inside Travis CI using User Mode Linux
#

# Exit immediately if a simple command exits with a non-zero status
set -e

# Define some environment variables
SLIRP_HOST="$(ip addr | awk '/scope global/ {print $2; exit}' | cut -d/ -f1)"
SLIRP_PORTS="$(seq 2000 2500)"
DOCKER_HOST="tcp://${SLIRP_HOST}:2375"
DOCKER_PORT_RANGE=2400:2500
export SLIRP_HOST DOCKER_HOST DOCKER_PORT_RANGE SLIRP_PORTS

echo "SLIRP_HOST=${SLIRP_HOST}"
echo "DOCKER_HOST=${DOCKER_HOST}"
echo "DOCKER_PORT_RANGE=${DOCKER_PORT_RANGE}"

echo 'Installing docker repository'
wget -qO- https://get.docker.io/gpg | sudo apt-key add -
echo 'deb https://get.docker.io/ubuntu docker main' | sudo tee /etc/apt/sources.list.d/docker.list
echo ''

echo 'Prevent APT starting any service'
echo exit 101 | sudo tee /usr/sbin/policy-rc.d
sudo chmod +x /usr/sbin/policy-rc.d
echo ''

echo 'Installing Docker'
sudo apt-get -y update
sudo apt-get -y install lxc lxc-docker slirp
sudo sudo usermod -aG docker "${USER}"
echo ''

echo 'Downloading User Mode Linux scripts'
git clone git://github.com/cptactionhank/sekexe
echo ''

echo 'Starting Docker Engine'
sekexe/run 'echo 2000 2500 > /proc/sys/net/ipv4/ip_local_port_range && mount -t tmpfs -o size=8g tmpfs /var/lib/docker && docker -D -d -H tcp://0.0.0.0:2375' 2>&1 | tee -a docker_daemon.log &
echo ''

echo 'Waiting Docker to start'
while ! docker info > /dev/null
do
  echo -n .
  sleep 1
done
echo ''

echo 'Docker version:'
docker version
