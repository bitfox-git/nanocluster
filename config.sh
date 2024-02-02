#!/bin/sh

echo "allow-hotplug eth0

iface eth0 inet dhcp
iface eth0 inet6 auto
" > etc/network/interfaces.d/eth0

echo "# Location: /etc/network/interfaces
# Please modify network settings via: dietpi-config
# Or create your own drop-ins in: /etc/network/interfaces.d/

# Drop-in configs
source interfaces.d/*

auto lo
iface lo inet loopback

auto lo
iface lo inet6 loopback
" > etc/network/interfaces

echo "neo${1}
" > etc/hostname

echo "
127.0.0.1  localhost
::1        localhost ip6-localhost ip6-loopback
ff02::1    ip6-allnodes
ff02::2    ip6-allrouters

127.0.1.1  neo${1} neo${1}.local
" > etc/hosts
