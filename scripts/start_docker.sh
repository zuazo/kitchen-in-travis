#!/bin/bash

#
# Installs and starts Docker Engine inside Travis CI using User Mode Linux
#

# Exit immediately if a simple command exits with a non-zero status
set -e

# Define some environment variables
HOST_IP="$(ip addr | awk '/scope global/ {print $2; exit}' | cut -d/ -f1)"
DOCKER_HOST=tcp://$HOST_IP:2375
DOCKER_PORT_RANGE=2400:2500
SLIRP_PORTS=$(seq 2000 2500)
export HOST_IP DOCKER_HOST DOCKER_PORT_RANGE SLIRP_PORTS

echo 'Installing cURL'
sudo apt-get -y update
sudo apt-get install -y ca-certificates curl
echo ''

echo 'Installing docker repository'
curl https://get.docker.com/gpg | sudo apt-key add -
echo 'deb https://get.docker.io/ubuntu docker main' | sudo tee /etc/apt/sources.list.d/docker.list
echo ''

echo 'Prevent APT starting any service'
echo exit 101 | sudo tee /usr/sbin/policy-rc.d
sudo chmod +x /usr/sbin/policy-rc.d
echo ''

echo 'Installing Docker'
sudo apt-get -y update
sudo apt-get -y install lxc lxc-docker slirp
sudo sudo usermod -aG docker "$USER"
echo ''

echo 'Downloading User Mode Linux scripts'
git clone git://github.com/cptactionhank/sekexe
echo ''

echo 'Starting Docker Engine'
sekexe/run 'echo 2000 2500 > /proc/sys/net/ipv4/ip_local_port_range && mount -t tmpfs -o size=8g tmpfs /var/lib/docker && docker -d -H tcp://0.0.0.0:2375' &> docker_daemon.log &
echo ''

echo 'Waiting Docker to start'
while ! docker info &> /dev/null
do
  sleep 1
done
echo ''

docker version
