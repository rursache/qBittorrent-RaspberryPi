#!/bin/bash
#
# qBitTorrent + libtorrent compile script for Raspberry Pi
# Radu Ursache
#

echo "qBitTorrent + libtorrent compile script for Raspberry Pi"
echo "Build by Radu Ursache"
echo "v1.1.0"

###########
## Funcs ##
###########

function log { 
    echo -e "--------------\n$1\n--------------"
}

function increaseSwapSize {
    log "Low RAM device and swap size is too small, resizing swap..."
    sudo dphys-swapfile swapoff
    sudo rm /etc/dphys-swapfile
    sudo bash -c "echo 'CONF_SWAPSIZE=2048' >> /etc/dphys-swapfile"
    sudo dphys-swapfile setup
    sudo dphys-swapfile swapon
    log "Swap increased to 2GB"
}

function installDependecies {
    log "Preparing dependecies..."
    sudo apt update && sudo apt install build-essential pkg-config git automake libtool libc6-dev libboost-dev libboost-system-dev libboost-chrono-dev libboost-random-dev libssl-dev qt5-qmake qtbase5-dev qttools5-dev-tools libqt5svg5-dev zlib1g-dev checkinstall unzip geoip-database -y
    log "Dependencies ready"
}

function compileLibTorrent {
    log "Compiling libtorrent..."
    cd ${workingDir}
    git clone https://github.com/arvidn/libtorrent.git && cd libtorrent && git checkout $(git tag | grep v1\.2.\. | sort -t _ -n -k 3 | tail -n 1)
    ./autotool.sh
    ./configure --with-boost-libdir=/usr/lib/$arch --with-libiconv CXXFLAGS="-std=c++17"
    make -j$(nproc)
    sudo mkdir -p /usr/local/share/cmake && sudo mkdir -p /usr/local/include
    log "Creating libtorrent deb"
    sudo checkinstall -y -D --backup=no --pkgname libtorrent --pkgversion $(git tag | grep v1\.2.\. | sort -t _ -n -k 3 | tail -n 1 | cut -c 2-) --provides libtorrent-rasterbar10
    sudo bash -c "echo '/usr/local/lib' >> /etc/ld.so.conf.d/libtorrent.conf" && sudo ldconfig
    export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
    mv -f *.deb ~/Downloads
    log "libtorrent ready"
}

function compileQBitTorrent {
    log "Compiling qbittorrent..."
    cd ${workingDir}
    wget -O qb.zip https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-${version}.zip
    unzip qb.zip && rm qb.zip && mv -f qBit*/ qb && cd qb
    ./configure --enable-systemd --with-boost-libdir=/usr/lib/$arch CXXFLAGS="-std=c++17"
    make -j$(nproc)
    log "qbittorrent ready"
}

function createQBitTorrentDeb {
    log "Creating qBitTorrent deb..."
    cd ${workingDir}
    wget -O control https://raw.githubusercontent.com/rursache/qBittorrent-RaspberryPi/master/control
    sed -i "s/Version: CHANGEME/Version: ${version}/" control
    sed -i "s/Architecture: CHANGEME/Architecture: ${archShort}/" control
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
    mv -f qb-deb.deb "qbittorrent_${version}-1_${archShort}.deb"
    log "qbittorrent deb done"
}

function cleanup {
    log "Cleaning up..."
    cd ${workingDir}
    rm -rf qb-deb
    rm -rf qb
    sudo rm -rf libtorrent
}


###########
## Start ##
###########

log "Starting..."

version=4.4.5
workingDir=~/Downloads
arch=""
archShort=""
swapSize=$(grep SwapTotal /proc/meminfo | sed 's/[^0-9]*//g')
ramSize=$(grep MemTotal /proc/meminfo | sed 's/[^0-9]*//g')

while getopts v:d: flag
do
    case "${flag}" in
        v) version=${OPTARG};;
        d) workingDir=${OPTARG};;
    esac
done

if [[ $(uname -m) == 'x86_64' ]]
then
    arch="x86_64-linux-gnu"
    archShort="amd64"
else
    if [[ $(getconf LONG_BIT) == 64 ]]
    then
        arch="aarch64-linux-gnu"
        archShort="arm64"
    else
        arch="arm-linux-gnueabihf"
        archShort="armhf"
    fi
fi

log "Found arch ${arch}"

if [[ $swapSize -gt 2000000 ]]
then
    log "Swap size valid"
else
    if [[ $ramSize -gt 3787500 ]]
    then
        log "RAM size valid"
    else
        increaseSwapSize
    fi
fi

installDependecies
compileLibTorrent
compileQBitTorrent
createQBitTorrentDeb
cleanup

log "Success!"
log "Deb files can be found in ${workingDir}"
log "Run\n\nsudo apt install geoip-database -y &&\nsudo dpkg -i libtorrent*.deb &&\nsudo dpkg -i qbittorrent*.deb\n\nto install them. Enjoy!"
