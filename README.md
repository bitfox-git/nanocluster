# nanocluster
The NanoPI Neo3 cluster documentation project

![project logo](images/logo.png)

## NanoPI Neo3 Cluster

This project is a documentation project for the NanoPI Neo3 cluster. The NanoPI Neo3 is a small single board computer with a quad core ARM processor and 1GB of RAM. The NanoPI Neo3 is a low cost single board computer that is ideal for building a small cluster. The [NanoPI Neo3 is available from FriendlyElec](https://wiki.friendlyelec.com/wiki/index.php/NanoPi_NEO3#Introduction).

## Cluster Hardware

The NanoPI Neo3 cluster is built using the following hardware:

 - 6 x [NanoPI Neo3](https://wiki.friendlyelec.com/wiki/index.php/NanoPi_NEO3) single board computers
 - Netgear GS308 8 port gigabit switch
 - Anker 60W 6 port USB charger

![NanoPI Neo3 Cluster - power side](images/cluster1.jpg)
![NanoPI Neo3 Cluster - cables side](images/cluster2.jpg)
![NanoPI Neo3 Cluster - top](images/cluster3.jpg)

## Cluster Software
### Operating System

The nodes uses the [official debian bookworm image](https://drive.google.com/file/d/1WMHuiTW-hMY0nQESvpRpt88eRmXapAcX/view) from the [wiki](https://wiki.friendlyelec.com/wiki/index.php/NanoPi_NEO3#Downloads).
Please, *extract* the image from the archive (.img.gz) with a file manager before *restoring* it with [Gnome Disks](https://apps.gnome.org/en-GB/DiskUtility/) to the SD cards.

### Cluster Network configuration

The hostname of the nodes is `neo` with the host nuber of the ip address in `192.168.1.0/24`. For example `neo1` with `192.168.1.1`. The network configuration files are in the `/etc/network` folder. Please, change the `interfaces` to:

```
source interfaces.d/*

auto lo
iface lo inet loopback

auto lo
iface lo inet6 loopback
```

And create `eth0` in `/etc/network/interfaces.d/` and replace X with the host number:

```
auto eth0

iface eth0 inet static
  address 192.168.107.10X
  netmask 255.255.255.0
  gateway 192.168.107.1
  dns-nameservers 192.168.107.1

iface eth0 inet6 auto
```

> It is also posseble to use the [config script](./config.sh) like this: `sh ~/nanocluster/config.sh 1`.

## DietPi Setup

Login with `ssh root@<IP address from dhcp server>` and the `dietpi` password.

`DietPi-Update` will be executed when logging in for the first time. After that install:

- ansible
- avahi-daemon
- dropbear (or openssh)
- iptables-persistent
- libnss-mdns
- systemd-resolved

The first node will be our Kubernetes and Ansible controller. So install `ansible-core` and Kubernetes on the first node:

```
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s --cluster-cidr=10.42.0.0/16,2001:cafe:42::/56 --service-cidr=10.43.0.0/16,2001:cafe:43::/112
```

### Hostname discovery with Avahi and resolved

Enable Avahi and resolved if not enabled to allow hostname discovery on all nodes:

```
sudo iptables -A INPUT -p udp --dport 5353 -j ACCEPT
sudo netfilter-persistent save
sudo sed -i '/^#MulticastDNS=yes/s/^#//' /etc/systemd/resolved.conf
sudo systemctl enable --now systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

### Kubernetes

#### neo1

```
# Kubernetes API server
sudo iptables -A INPUT -p tcp --dport 6443 -j ACCEPT

# etcd server client API
sudo iptables -A INPUT -p tcp --dport 2379:2380 -j ACCEPT

# Flannel VXLAN (if using Flannel)
sudo iptables -A INPUT -p udp --dport 8472 -j ACCEPT

# kubelet
sudo iptables -A INPUT -p tcp --dport 10250 -j ACCEPT

# kube-scheduler
sudo iptables -A INPUT -p tcp --dport 10251 -j ACCEPT

# kube-controller-manager
sudo iptables -A INPUT -p tcp --dport 10252 -j ACCEPT

# NodePort Services range
sudo iptables -A INPUT -p tcp --dport 30000:32767 -j ACCEPT

# Save the rules
sudo netfilter-persistent save && \
sudo netfilter-persistent reload
```

Enable the `k3s` service if not enabled and edit or create `/etc/rancher/k3s/config.yaml`:

```
write-kubeconfig-mode: '0644'
tls-san:
  - neo1.local
  - neo2.local
  - neo3.local
  - neo4.local
  - neo5.local
  - neo6.local
```

#### other nodes

```
# Allow outbound connections to the k3s server
sudo iptables -A OUTPUT -p tcp --dport 6443 -j ACCEPT && \
sudo iptables -A OUTPUT -p tcp --dport 2379:2380 -j ACCEPT && \
sudo iptables -A OUTPUT -p udp --dport 8472 -j ACCEPT && 
sudo iptables -A OUTPUT -p tcp --dport 10250 -j ACCEPT

# Save the rules
sudo netfilter-persistent save && \
sudo netfilter-persistent reload
```

Get the token on neo1:

```
sudo cat /var/lib/rancher/k3s/server/node-token
```

and use it to add the other nodes to the cluster:

```
curl -sfL https://get.k3s.io | K3S_URL=https://neo1.local:6443 K3S_TOKEN=<token> K3S_NODE_NAME="neo2" sh -
```

Verify the nodes on neo1:

```
kubectl get nodes
```

### SSH Keys

It is nice to have SSH keys to connect from the manager node to the worker nodes. So, create one on the manager node:

```
ssh-keygen -t ed25519 -C dietpi@neo1
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
```

And add it to the worker nodes:

```
echo "ssh-ed25519 XXXXXXXXXXXXXXXXXXXXXXXX dietpi@neo1.local" >> /home/dietpi/.ssh/authorized_keys
```

### Ansible

Edit or create `/etc/ansible/hosts`:

```
[control]
neo1.local

[managed]
neo2.local
neo3.local
neo4.local
neo5.local
neo6.local
```

### Disable root login

Edit the `/etc/passwd` file and change the shell from `/bin/bash` to `/usr/sbin/nologin` for the root user on every node.
