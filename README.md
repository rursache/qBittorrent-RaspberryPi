# qBittorrent 4.4.x on Raspberry Pi (arm64 + armhf)

⚠️ No longer supported, migrate to a [docker installation](https://hub.docker.com/r/linuxserver/qbittorrent) for a hassle-free experience

The existing qBittorrent package on Raspberry Pi OS is outdated. The various online guides and wiki pages are outdated or does not provide a way to "cook" a `.deb` package file. 

This repo wants to solve that by providing a working compiling script while also offering pre-made `.deb` packages for both **libtorrent** and **qbittorrent**.

## Running the script
```
wget --no-cache -O qb.sh https://raw.githubusercontent.com/rursache/qBittorrent-RaspberryPi/master/qb.sh && chmod +x qb.sh &&
./qb.sh -v 4.4.5
```

Parameters:
- `-v` (optional) can be any qBitTorrent version
- `-d` (optional) can provide a different working directory (defaults to `~/Downloads`)

This script works on arm64, armhf and amd64.

> **Note**
> 
> Compilig takes around 30mins on a Raspberry Pi 4 (4GB RAM) with active cooling. 
> 
> If you're having issues, make sure the swap size is at least 4GB and be patient.

### Installing
> **Note**
> 
> If you already have qBitTorrent installed from the default repos, run 
> 
> `sudo apt remove libtorrent-rasterbar10 -y`
> 
> before installing the new builds

```
sudo apt install qt5-qmake qtbase5-dev qttools5-dev-tools libqt5svg5-dev geoip-database -y &&
sudo dpkg -i libtorrent*.deb &&
sudo dpkg -i qbittorrent*.deb
```

## Updates
When a new version of **qbittorrent** (or **libtorrent**) is released you can just run the script again specifing the version you want then following the [installing](https://github.com/rursache/qBittorrent-RaspberryPi#installing) section

## Run qBittorrent at boot
On Raspberry Pi OS run:
```
sudo bash -c "echo '@qbittorrent' >> /etc/xdg/lxsession/LXDE-pi/autostart"
```

## amd64 Support
Starting with v1.1.0 of the script, amd64 builds are supported as well. Pre-builds are also available in the [Releases](https://github.com/rursache/qBittorrent-RaspberryPi/releases) section

## Credits
- Official wiki:
	- [Page 1](https://github.com/qbittorrent/qBittorrent/wiki/Compilation:-Raspberry-Pi-OS-and-DietPi)
	- [Page 2](https://github.com/qbittorrent/qBittorrent/wiki/Compilation%3A-Debian-and-Ubuntu#compiling-qbittorrent-with-the-gui)
- Checkinstall [man page](https://manpages.debian.org/jessie/checkinstall/checkinstall.8)
- This [askubuntu post](https://askubuntu.com/questions/1014619/a-working-version-of-checkinstall) by Stewart which made me switch from `checkinstall` to `dpkg-deb` when building **qbittorrent**
- A great [tutorial](https://www.internalpointers.com/post/build-binary-deb-package-practical-guide) on how to build `.deb` packages with `dpkg-deb`
