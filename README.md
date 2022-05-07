# qBittorrent 4.4.x on Raspberry Pi (arm64 + armhf)

The existing qBittorrent package on Raspberry Pi OS is outdated. The various online guides and wiki pages are outdated or does not provide a way to "cook" a `.deb` package file. 

This repo wants to solve that by providing a working "copy-paste" guide while also offering pre-made `.deb` packages for both **libtorrent** and **qbittorrent**.

## Increase the swap size (for < 4GB RAM RPIs)
```
sudo dphys-swapfile swapoff &&
sudo nano /etc/dphys-swapfile &&
sudo dphys-swapfile setup &&
sudo dphys-swapfile swapon
```
Set `CONF_SWAPSIZE` to `2048` and then `sudo reboot`

## Getting the updated debs
One line:
```
wget --no-cache -O qb.sh https://raw.githubusercontent.com/rursache/qBittorrent-RaspberryPi/master/qb.sh &&
chmod +x qb.sh && ./qb.sh -version 4.4.2
```

Manual:
- Download the `qb.sh` bash script from this repo
- Start it with `./qb.sh -version 4.4.2`

Where **-version** is optional and can be any qBitTorrent version

### Installing
**NOTE**: If you already have qBittorrent installed from the default repos, run `sudo apt remove libtorrent-rasterbar10 -y` before installing the new builds
```
sudo apt install geoip-database -y &&
sudo dpkg -i libtorrent*.deb &&
sudo dpkg -i qbittorrent*.deb
```

## Updates
When a new version of **qbittorrent** (or **libtorrent**) is released you can just run the script again specifing the version you want

## Run qBittorrent at boot
```
sudo bash -c "echo '@qbittorrent' >> /etc/xdg/lxsession/LXDE-pi/autostart"
```

## Credits
- Official wiki:
	- [Page 1](https://github.com/qbittorrent/qBittorrent/wiki/Compilation:-Raspberry-Pi-OS-and-DietPi)
	- [Page 2](https://github.com/qbittorrent/qBittorrent/wiki/Compilation%3A-Debian-and-Ubuntu#compiling-qbittorrent-with-the-gui)
- Checkinstall [man page](https://manpages.debian.org/jessie/checkinstall/checkinstall.8)
- This [askubuntu post](https://askubuntu.com/questions/1014619/a-working-version-of-checkinstall) by Stewart which made me switch from `checkinstall` to `dpkg-deb` when building **qbittorrent**
- A great [tutorial](https://www.internalpointers.com/post/build-binary-deb-package-practical-guide) to build `.deb` packages with `dpkg-deb`
