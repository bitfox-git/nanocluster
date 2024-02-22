# Setup workstation

I use a Raspbery Pi 5 as with the [official Raspberry Pi OS](https://www.raspberrypi.com/software) as workstation. If it is not preinstalled or installed automaticly on the Micro SD card then use the Raspberry Pi Imager to install it. I changed the power settings in my [configuration](config.txt):

```
BOOT_UART=1
POWER_OFF_ON_HALT=1
BOOT_ORDER=0xf416
```

After that, boot into Raspberry Pi OS and install the folowing software:

- flatpak
- gnome-disk-utils
- gnome-software
- podman
- vs code

Setup the [flathub](https://flathub.org/setup/Raspberry%20Pi%20OS) and install [pods](https://flathub.org/apps/com.github.marhkb.Pods):

```
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.github.marhkb.Pods
```

## Troubleshooting

### Directories are not opened in the file manager

```
xdg-mime default pcmanfm.desktop inode/directory
```


