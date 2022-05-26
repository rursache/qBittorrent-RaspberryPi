# qBittorrent 4.4.x on Raspberry Pi (arm64 + armhf)

The existing qBittorrent package on Raspberry Pi OS is outdated. The various online guides and wiki pages are outdated or does not provide a way to "cook" a `.deb` package file. 

This repo wants to solve that by providing a working compiling script while also offering pre-made `.deb` packages for both **libtorrent** and **qbittorrent**.

## Running the script
```
wget --no-cache -O qb.sh https://raw.githubusercontent.com/rursache/qBittorrent-RaspberryPi/master/qb.sh && chmod +x qb.sh &&
./qb.sh -v 4.4.3
```

Parameters:
- `-v` (optional) can be any qBitTorrent version
- `-d` (optional) can provide a different working directory (defaults to `~/Downloads`)

### Installing
**NOTE**: If you already have qBitTorrent installed from the default repos, run `sudo apt remove libtorrent-rasterbar10 -y` before installing the new builds
```
sudo apt install geoip-database -y &&
sudo dpkg -i libtorrent*.deb &&
sudo dpkg -i qbittorrent*.deb
```

## Updates
When a new version of **qbittorrent** (or **libtorrent**) is released you can just run the script again specifing the version you want then following the [installing](https://github.com/rursache/qBittorrent-RaspberryPi#installing) section

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
- A great [tutorial](https://www.internalpointers.com/post/build-binary-deb-package-practical-guide) on how to build `.deb` packages with `dpkg-deb`
