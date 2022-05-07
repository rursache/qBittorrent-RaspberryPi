#!/bin/bash
#
# qBitTorrent + libtorrent compile script for Raspberry pi
# Radu Ursache
# 
# v1.0
#

function log {
  echo "--------------"
  echo $1
  echo "--------------"
}

log "Preparing..."

version=${1:-"4.4.2"}
arch=""
archShort=""

if [[ $(getconf LONG_BIT) == 64 ]]
then
  arch="aarch64-linux-gnu"
  archShort="arm64"
else
  arch="arm-linux-gnueabihf"
  archShort="armhf"
fi

log "Found arch ${arch}"

function installDependecies {
  echo "Preparing dependecies..."
  sudo apt update && sudo apt install build-essential pkg-config git automake libtool libc6-dev libboost-dev libboost-system-dev libboost-chrono-dev libboost-random-dev libssl-dev qtbase5-dev qttools5-dev-tools libqt5svg5-dev zlib1g-dev checkinstall unzip geoip-database -y
  echo "Dependencies ready"
}

function compileLibTorrent {
  log "Compiling libtorrent..."
  cd ~/Downloads
  git clone https://github.com/arvidn/libtorrent.git && cd libtorrent && git checkout $(git tag | grep v1\.2.\. | sort -t _ -n -k 3 | tail -n 1)
  ./autotool.sh
  ./configure --with-boost-libdir=/usr/lib/aarch64-linux-gnu --with-libiconv CXXFLAGS="-std=c++17"
  make -j$(nproc)
  sudo mkdir -p /usr/local/share/cmake && sudo mkdir -p /usr/local/include
  log "Creating libtorrent deb"
  sudo checkinstall -D --backup=no --pkgname libtorrent --pkgversion $(git tag | grep v1\.2.\. | sort -t _ -n -k 3 | tail -n 1 | cut -c 2-) --provides libtorrent-rasterbar10
  sudo bash -c "echo '/usr/local/lib' >> /etc/ld.so.conf.d/libtorrent.conf" && sudo ldconfig
  export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
  log "libtorrent ready"
}

function compileqBitTorrent {
  log "Compiling qbittorrent..."
  cd ~/Downloads
  wget -O qb.zip https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-${version}.zip
  unzip qb.zip && rm qb.zip && mv qBit*/ qb && cd qb
  ./configure --enable-systemd --with-boost-libdir=/usr/lib/aarch64-linux-gnu CXXFLAGS="-std=c++17"
  make -j$(nproc)
  log "qbittorrent ready"
}

function createqBitTorrentDeb {
  log "Creating qBitTorrent deb..."
  wget -O control https://raw.githubusercontent.com/rursache/qBittorrent-RaspberryPi/master/control
  sed -i "s/Version: CHANGEME/Version: ${version}/" filename
  sed -i "s/Architecture: CHANGEME/Architecture: ${archShort}/" filename
  sed -i -e '$a\' control
  mkdir -p qb-deb/DEBIAN && mv control "$_"
  mkdir -p qb-deb/usr/local/share/man/man1 && cp qb/doc/qbittorrent.1 "$_"
  mkdir -p qb-deb/usr/local/share/applications && cp qb/dist/unix/org.qbittorrent.qBittorrent.desktop "$_"
  mkdir -p qb-deb/usr/local/share/metainfo && cp qb/dist/unix/org.qbittorrent.qBittorrent.appdata.xml "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/128x128 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/16x16 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/192x192 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/22x22 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/24x24 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/32x32 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/36x36 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/48x48 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/64x64 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/72x72 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/96x96 "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/ && cp -R qb/dist/unix/menuicons/scalable "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/scalable/status && cp qb/src/icons/qbittorrent-tray.svg "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/scalable/status && cp qb/src/icons/qbittorrent-tray-dark.svg "$_"
  mkdir -p qb-deb/usr/local/share/icons/hicolor/scalable/status && cp qb/src/icons/qbittorrent-tray-light.svg "$_"
  mkdir -p qb-deb/usr/local/share/pixmaps && cp qb/dist/unix/menuicons/128x128/apps/qbittorrent.png "$_"
  mkdir -p qb-deb/usr/local/bin && cp qb/src/qbittorrent "$_"
  dpkg-deb --build --root-owner-group qb-deb
  log "qBitTorrent deb done"
}

function cleanup {
  log "Cleaning up..."
  rm -rf qb-deb
  rm -rf qb
  rm -rf libtorrent
  rm qb.sh
}

installDependecies
compileLibTorrent
createqBitTorrentDeb
cleanup

log "Done"
