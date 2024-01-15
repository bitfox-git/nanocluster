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

We use the [official debian bookworm image](https://drive.google.com/drive/folders/1_sdgoOb8s5yJn3KVmAKn7AkIrN9bM7-g) from [Google Drive](https://drive.google.com/drive/folders/1_sdgoOb8s5yJn3KVmAKn7AkIrN9bM7-g) as mentioned in the [wiki](https://wiki.friendlyelec.com/wiki/index.php/NanoPi_NEO3#Downloads). 
After that we *extract* the image from the archive (.img.gz) with the file manager. 
Then we can use [Gnome Disks](https://apps.gnome.org/en-GB/DiskUtility/) to *restore* the image to the SD cards.

### Network configuration

We use the hostname `neo` with the host nuber added from the static ip adress in `10.12.14.0/24`. For example `neo1` with `10.12.14.1`. The network configuration files are in the `/etc/network` folder. We changed the `interfaces` to:

```
source interfaces.d/*

auto lo
iface lo inet loopback

auto lo
iface lo inet6 loopback
```

and we created `eth0` in `/etc/network/interfaces.d/`:

```
auto eth0

iface eth0 inet static
  address 10.12.14.1
  netmask 255.255.255.0
  gateway 10.12.14.254
  dns-nameservers 1.1.1.1 8.8.8.8 9.9.9.9

iface eth0 inet6 auto
```

Please, mount the SD card and run `config.sh` in the mounted directory with a host number as argument. For example: `sh ~/nanocluster/config.sh 1`. 

#### Routing

We connected a raspbery pi with wifi to the cluster switch. In raspbery PI OS edit the `/etc/nftables.conf` file so that it look like this:

```bash
#!/usr/sbin/nft -f

flush ruleset

table ip nat {
        chain prerouting {
                type nat hook prerouting priority 0;
        }

        chain postrouting {
                type nat hook postrouting priority 100;
                masquerade
        }
}

table inet filter {
        chain input {
                type filter hook input priority filter;
        }
        chain forward {
                type filter hook forward priority filter;
                policy drop;

                # Allow established/related connections
                ct state established,related accept

                # Allow forwarding from wlan0 to eth0
                iifname "wlan0" oifname "eth0" accept
        }
        chain output {
                type filter hook output priority filter;
        }
}
```

and restart the firewall with `sudo systemctl restart nftables`. Use the network manager on the raspbery pi to add a static ip address `10.12.14.254` to `eth0` and add the nodes to the *hosts* file:

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
