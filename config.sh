#!/bin/sh

echo "auto eth0

iface eth0 inet static
  address 192.168.107.101
  netmask 255.255.255.0
  gateway 192.168.107.1
  dns-nameservers 192.168.107.1

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
127.0.0.1  neo${1} neo${1}.local localhost ip4-localhost
::1        neo${1} neo${1}.local localhost ip6-localhost
" > etc/hosts

for I in {1..${2:-6}}
do
  if [ "$I" -ne "${1}" ]
  then
    echo "192.168.107.10$I   neo$I" >> etc/hosts
  fi
done
