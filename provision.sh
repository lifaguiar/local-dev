#!/bin/bash
yum update -y
yum install -y unzip zip
curl -sSL https://get.docker.com/ | sh
mkdir -p /data

# Look up for DOWN interfaces other than lo and docker0 and bring it up
for net in $(ip addr | egrep -v '(lo|docker0)' | grep DOWN | cut -d ':' -f2); do
   ifup $net
done

# We have other disk, use it for Docker instaltion 
if [ "$(parted -lm | grep '/dev/xdb')" != "" ]; then
   if [ "$(/sbin/parted -lm | grep -a1 /dev/sdb | grep xfs)" == "" ]; then 
      mkfs.xfs /dev/sdb
      printf "/dev/sdb\t/data\txfs\tdefaults 0 0">>/etc/fstab
      mount /dev/sdb /data   
   fi
fi

mkdir /data/docker

# Not use /var/lib for Docker instalations
printf '{\n\t"graph":"/data/docker"\n}' >/etc/docker/daemon.json

# Firewalld causes explicit enable ports for services. Use iptables while docker use iptables
systemctl stop firewalld
systemctl disable firewalld

# Start docker daemon
systemctl start docker

# We want daemon start automatically when machine is up
systemctl enable docker
