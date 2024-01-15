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

