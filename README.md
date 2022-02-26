# qBittorrent 4.4.x on Raspberry Pi (arm64 + armhf)

The existing qBittorrent package on Raspberry Pi OS is outdated. The various online guides and wiki pages are outdated or does not provide a way to "cook" a `.deb` package file. 

This repo wants to solve that by providing a working "copy-paste" guide while also offering pre-made `.deb` packages for both **libtorrent** and **qbittorrent**.

⚠️ On armhf (32 bit Raspberry Pi OS) replace `aarch64-linux-gnu` with `arm-linux-gnueabihf` paths in the `configure` commands.

## Install dependecies
```
sudo apt install build-essential pkg-config git automake libtool libc6-dev libboost-dev libboost-system-dev libboost-chrono-dev libboost-random-dev libssl-dev qtbase5-dev qttools5-dev-tools libqt5svg5-dev zlib1g-dev checkinstall unzip -y
```

## Increase the swap size (for < 4GB RAM RPIs)
```
sudo dphys-swapfile swapoff &&
sudo nano /etc/dphys-swapfile &&
sudo dphys-swapfile setup &&
sudo dphys-swapfile swapon
```
Set `CONF_SWAPSIZE` to `2048` and then `sudo reboot`

## Compile libtorrent
```
git clone https://github.com/arvidn/libtorrent.git && cd libtorrent && git checkout $(git tag | grep v1\.2.\. | sort -t _ -n -k 3 | tail -n 1) &&
./autotool.sh &&
./configure --with-boost-libdir=/usr/lib/aarch64-linux-gnu --with-libiconv CXXFLAGS="-std=c++17" &&
make -j$(nproc) &&
sudo mkdir -p /usr/local/share/cmake && sudo mkdir -p /usr/local/include &&
sudo checkinstall -D --backup=no --pkgname libtorrent --pkgversion $(git tag | grep v1\.2.\. | sort -t _ -n -k 3 | tail -n 1 | cut -c 2-) --provides libtorrent-rasterbar10 &&
sudo bash -c "echo '/usr/local/lib' >> /etc/ld.so.conf.d/libtorrent.conf" && sudo ldconfig &&
export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
```

## Compile qBittorrent
**NOTE**: When changing versions, also update the `CONTROL` file
```
wget -O qb.zip https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-4.4.1.zip &&
unzip qb.zip && rm qb.zip && mv qBit*/ qb && cd qb &&
./configure --enable-systemd --with-boost-libdir=/usr/lib/aarch64-linux-gnu CXXFLAGS="-std=c++17" &&
make -j$(nproc)
```
### Create deb file
**NOTE**: This should be executed outside the `qb` folder (eg. `/home/pi/Downloads`)

**NOTE2**: You can (and should) provide a custom `control` file. The existing one stands as an example
```
wget -O control https://raw.githubusercontent.com/rursache/qBittorrent-RaspberryPi/master/control &&
sed -i -e '$a\' control &&
mkdir -p qt-deb/DEBIAN && mv control "$_" &&
mkdir -p qt-deb/usr/local/share/man/man1 && cp qb/doc/qbittorrent.1 "$_" &&
mkdir -p qt-deb/usr/local/share/applications && cp qb/dist/unix/org.qbittorrent.qBittorrent.desktop "$_" &&
mkdir -p qt-deb/usr/local/share/metainfo && cp qb/dist/unix/org.qbittorrent.qBittorrent.appdata.xml "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/128x128 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/16x16 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/192x192 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/22x22 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/24x24 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/32x32 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/36x36 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/48x48 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/64x64 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/72x72 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/96x96 "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/scalable "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/scalable/status && cp qb/src/icons/qbittorrent-tray.svg "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/scalable/status && cp qb/src/icons/qbittorrent-tray-dark.svg "$_" &&
mkdir -p qt-deb/usr/local/share/icons/hicolor/scalable/status && cp qb/src/icons/qbittorrent-tray-light.svg "$_" &&
mkdir -p qt-deb/usr/local/share/pixmaps && cp qb/dist/unix/menuicons/128x128/apps/qbittorrent.png "$_" &&
mkdir -p qt-deb/usr/local/bin && cp qb/src/qbittorrent "$_" &&
dpkg-deb --build --root-owner-group qt-deb
```
### Installing
```
sudo apt install geoip-database -y &&
sudo dpkg -i libtorrent*.deb &&
sudo dpkg -i qbittorrent*.deb
```

## Updates
When a new version of **qbittorrent** (or **libtorrent**) is released you can just edit the `CONTROL` file to bump the version. Then run the same commands replacing the version number with the one you want

## Run qBittorrent at boot
```
sudo bash -c "echo '@qbittorrent' >> /etc/xdg/lxsession/LXDE-pi/autostart"
```

## Notes
- You can also just run `sudo make install` instead of using `checkinstall` (on **libtorrent**) and `dpkg-deb` (on **qbittorrent**) if you do not want packaged `.deb` files

## Credits
- Official wiki:
	- [Page 1](https://github.com/qbittorrent/qBittorrent/wiki/Compilation:-Raspberry-Pi-OS-and-DietPi)
	- [Page 2](https://github.com/qbittorrent/qBittorrent/wiki/Compilation%3A-Debian-and-Ubuntu#compiling-qbittorrent-with-the-gui)
- Checkinstall [man page](https://manpages.debian.org/jessie/checkinstall/checkinstall.8)
- This [askubuntu post](https://askubuntu.com/questions/1014619/a-working-version-of-checkinstall) by Stewart which made me switch from `checkinstall` to `dpkg-deb` when building **qbittorrent**
- A great [tutorial](https://www.internalpointers.com/post/build-binary-deb-package-practical-guide) to build `.deb` packages with `dpkg-deb`
