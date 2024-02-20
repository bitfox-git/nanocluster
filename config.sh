#!/bin/sh
echo neo${1} > /media/$USER/rootfs/etc/hostname
sed -i "s/FriendlyElec/neo${1}/g" /media/$USER/rootfs/etc/hosts 
echo "auto eth0

iface eth0 inet static
  address 192.168.107.10${1}
  netmask 255.255.255.0
  gateway 192.168.107.1
  dns-nameservers 192.168.107.1
iface eth0 inet6 auto" > /media/$USER/rootfs/etc/network/interfaces.d/eth0

mkdir /media/$USER/rootfs/root/.ssh
cp /home/$USER/.ssh/id_ed25519.pub /media/$USER/rootfs/root/.ssh/authorized_keys
chmod 644 /media/$USER/rootfs/root/.ssh/authorized_keys
chmod 700 /media/$USER/rootfs/root/.ssh

mkdir /media/$USER/rootfs/home/pi/.ssh
cp /home/$USER/.ssh/id_ed25519.pub /media/$USER/rootfs/home/pi/.ssh/authorized_keys
chmod 644 /media/$USER/rootfs/home/pi/.ssh/authorized_keys
chmod 700 /media/$USER/rootfs/home/pi/.ssh