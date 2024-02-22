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

The nodes uses a [dietpi image](https://dietpi.com/#download) for the `NanoPi NEO3`.
Please, *extract* the image from the archive (.img.gz) with a file manager before *restoring* it with [Gnome Disks](https://apps.gnome.org/en-GB/DiskUtility/) to the SD cards. After that, mount the DIETPISETUP partition manually to make sure to have write access to the volume.

```bash
sudo mount /dev/sda2 /mnt
ls -lha /mnt
```

The resolt should be:

```
total 46K
drwxr-xr-x  2 root root  16K Jan  1  1970 .
drwxr-xr-x 18 root root 4.0K Feb 12 14:21 ..
-rwxr-xr-x  1 root root  336 Feb 20 01:27 dietpiEnv.txt
-rwxr-xr-x  1 root root  18K Feb 20 01:27 dietpi.txt
-rwxr-xr-x  1 root root 3.9K Feb 20 01:27 dietpi-wifi.txt
-rwxr-xr-x  1 root root  440 Feb 20 01:27 Readme-DietPi-Config.txt
```

Then use the [script](sed.sh) to replace the default values. In this case the Micro SD card is used for the firts node:

```bash
sudo ./dietpi 1
``` 

The [script](sed.sh) changed the hostname of the nodes to `neo` with a host nuber from the first argument of the [script](sed.sh). So `./dietpi 1` changes it to `neo1`. It also sets a static ip address for the `192.168.1.0/24` network. In this case it became `192.168.1.101`. More information is in the network configuration folder: `/mnt/etc/network`.

> [!TIP]
> 
> Generate a ssh key pair bevore using the [script](sed.sh). It will copy the id_ed25519 public key from the users home dirictory.
> 
> ```bash
> ssh-keygen -t ed25519 -C "ansible@host.local"
> ```

Umount `/mnt` and repeat for the other nodes:

```bash
sudo umount /mnt
```

### Kubernetes

#### neo1

```bash
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

```yaml
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

```bash
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

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

and use it to add the other nodes to the cluster:

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://neo1.local:6443 K3S_TOKEN=<token> K3S_NODE_NAME="neo2" sh -
```

Verify the nodes on neo1:

```bash
kubectl get nodes
```

### SSH Keys

It is nice to have SSH keys to connect from the manager node to the worker nodes. So, create one on the manager node:

```bash
ssh-keygen -t ed25519 -C dietpi@neo1
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
```

And add it to the worker nodes:

```bash
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
