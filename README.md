# nanocluster
The NanoPI Neo3 cluster documentation project

![project logo](images/logo.png)

## NanoPI Neo3 Cluster

This project is a documentation project for the NanoPI Neo3 cluster. The NanoPI Neo3 is a small single board computer with a quad core ARM processor and 1GB of RAM. The NanoPI Neo3 is a low cost single board computer that is ideal for building a small cluster. The [NanoPI Neo3 is available from FriendlyElec](https://wiki.friendlyelec.com/wiki/index.php/NanoPi_NEO3#Introduction).

## Hardware

The NanoPI Neo3 cluster is built using the following hardware:

 - 6 x [NanoPI Neo3](https://wiki.friendlyelec.com/wiki/index.php/NanoPi_NEO3) single board computers
 - Netgear GS308 8 port gigabit switch
 - Anker 60W 6 port USB charger

![NanoPI Neo3 Cluster - power side](images/cluster1.jpg)
![NanoPI Neo3 Cluster - cables side](images/cluster2.jpg)
![NanoPI Neo3 Cluster - top](images/cluster3.jpg)

## Software
### Operating System

The nodes uses the [official debian bookworm image](https://drive.google.com/drive/folders/1_sdgoOb8s5yJn3KVmAKn7AkIrN9bM7-g) from [Google Drive](https://drive.google.com/drive/folders/1_sdgoOb8s5yJn3KVmAKn7AkIrN9bM7-g) as mentioned in the [wiki](https://wiki.friendlyelec.com/wiki/index.php/NanoPi_NEO3#Downloads).
Please, *extract* the image from the archive (.img.gz) with a file manager before *restoring* it with [Gnome Disks](https://apps.gnome.org/en-GB/DiskUtility/) to the SD cards.

### Network configuration on the nodes

The hostname of the nodes is `neo` with the host nuber of the ip address in `10.12.14.0/24`. For example `neo1` with `10.12.14.1`. The network configuration files are in the `/etc/network` folder. Please, change the `interfaces` to:

```
source interfaces.d/*

auto lo
iface lo inet loopback

auto lo
iface lo inet6 loopback
```

And create `eth0` in `/etc/network/interfaces.d/`:

```
auto eth0

iface eth0 inet static
  address 10.12.14.1
  netmask 255.255.255.0
  gateway 10.12.14.254
  dns-nameservers 1.1.1.1 8.8.8.8 9.9.9.9

iface eth0 inet6 auto
```

> It is also posseble to use the [config script](./config.sh) like this: `sh ~/nanocluster/config.sh 1`.

### Workstacion

I use a Raspbery Pi 5 as a development workstacion. It runs on [Alpine Linux](https://wiki.alpinelinux.org/wiki/Raspberry_Pi) with the Gnome desktop. Gnome uses Network Manager. So, remove `/etc/network/interfaces` so that Network Manager may manage the network interfaces. Otherwise the desktop things that you have no internet connection. 

#### Rasbery Pi configuration

By default Alpine Linux has no Raspbery Pi configuration file. So, I copyied the default `config.txt` from the official Raspbery Pi OS and renamed it to `usercfg.txt`. Compair it with the default `config.txt` from Alpine Linux and remove dubble stuff from `usercfg.txt`. So that is looks like this:

```
# For more options and information see
# http://rptl.io/configtxt
# Some settings may impact device functionality. See link above for details

# uncomment if you get no picture on HDMI for a default "safe" mode
hdmi_safe=1

# PI 5
BOOT_UART=1
POWER_OFF_ON_HALT=1
BOOT_ORDER=0xf416

# Uncomment some or all of these to enable the optional hardware interfaces
#dtparam=i2c_arm=on
#dtparam=i2s=on
#dtparam=spi=on

# Enable audio (loads snd_bcm2835)
dtparam=audio=on

# Additional overlays and parameters are documented
# /boot/firmware/overlays/README

# Automatically load overlays for detected cameras
#camera_auto_detect=1

# Automatically load overlays for detected DSI displays
display_auto_detect=1

# Enable DRM VC4 V3D driver
dtoverlay=vc4-kms-v3d
max_framebuffers=2

# Don't have the firmware create an initial video= setting in cmdline.txt.
# Use the kernel's default instead.
disable_fw_kms_setup=1

# Disable compensation for displays with overscan
disable_overscan=1

# Run as fast as firmware / board allows
arm_boost=1

[cm4]
# Enable host mode on the 2711 built-in XHCI USB controller.
# This line should be removed if the legacy DWC2 controller is required
# (e.g. for USB device mode) or if USB support is not required.
otg_mode=1

[all]
```

#### Workstation Network configuration

Maunaly set the IP address to `10.12.14.254` using the Network Manager and the nodes to the `hosts` file (`/etc/hosts`):

```
127.0.0.1    localhost
::1          localhost ip6-localhost ip6-loopback
ff02::1      ip6-allnodes
ff02::2      ip6-allrouters

127.0.1.1    pi

10.12.14.1   neo1
10.12.14.2   neo2
10.12.14.3   neo3
10.12.14.4   neo4
10.12.14.5   neo5
10.12.14.6   neo6
10.12.14.254 pi
```

Enable ip forwarding with `sysctl`:

```
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.default.forwarding=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
```

Use `ufw` to route/forward through the firewall:

```
sudo ufw allow out on eth0
```

Enable NAT by editing `/etc/ufw/before.rules'. Add the following lines at the end of the nat table section:

```
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.12.14.0/24 -o wlan0 -j MASQUERADE
COMMIT
```

And login with `ssh root@10.12.14.1` and the `dietpi` password. 
