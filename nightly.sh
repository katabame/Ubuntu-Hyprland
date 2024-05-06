#!/usr/bin/bash
set -e

function ensure_root() {
    if [[ `groups` =~ "root" ]]; then
            "$@"
    else
            sudo "$@"
    fi
}

function apt_install() {
    ensure_root apt-get install -y --no-install-recommends "$@"
}

## 00 basic build tools
ensure_root apt-get update
apt_install \
    ca-certificates meson jq cmake-extras \
    clang git wget autoconf automake make

## 01 change working directory
mkdir ~/hyprsource
cd ~/hyprsource

## 70 xorg-macros
git clone https://gitlab.freedesktop.org/xorg/util/macros.git
cd ./macros
    ./autogen.sh
    ./configure
    ensure_root make install
cd ~/hyprsource

## 71 libxcb-errors
#git clone https://gitlab.freedesktop.org/xorg/lib/libxcb-errors.git
#cd ./libxcb-errors
#    git submodule update --init
#    apt_install libtool xcb-proto
#    export ACLOCAL_PATH=/usr/local/share/aclocal
#    cp /usr/share/libtool/build-aux/ltmain.sh ./
#    ./autogen.sh
#    ./configure
#    make
#    ensure_root make install
#cd ~/hyprsource

## 90 execinfo
## 91 epoll-shim
#git clone https://github.com/jiixyj/epoll-shim.git
#cmake -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
#cmake --build ./build -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
#sudo cmake --install ./build

# 94 hyprlang
git clone https://github.com/hyprwm/hyprlang.git
cd ./hyprlang
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target hyprlang -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource

# 95 hyprcursor
git clone https://github.com/hyprwm/hyprcursor.git
cd ./hyprcursor
    apt_install libzip-dev librsvg2-dev libtomlplusplus-dev
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource

# 96 wayland-protocols
git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git
cd ./wayland-protocols
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release
    ninja
    ensure_root ninja install
cd ~/hyprsource

# 97 hyprland-protocols
git clone https://github.com/hyprwm/hyprland-protocols.git
cd ./hyprland-protocols
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release
    ensure_root ninja install
cd ~/hyprsource

# 98 hyprwayland-scanner
git clone https://github.com/hyprwm/hyprwayland-scanner.git
cd ./hyprwayland-scanner
    apt_install libpugixml-dev
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource

# 99 Hyprland
git clone https://github.com/hyprwm/hyprland.git
cd ./hyprland
    sed -i 's/\/usr\/local/\/usr/g' Makefile
    apt_install \
        libwayland-dev libdrm-dev libxkbcommon-dev \
        libpixman-1-dev libegl-dev libgbm-dev libgles-dev \
        libudev-dev libseat-dev hwdata libdisplay-info-dev \
        libliftoff-dev libinput-dev libxcb-dri3-dev libxcb-present-dev \
        xwayland libxcb-render-util0-dev libxcb-composite0-dev \
        libxcb-shm0-dev libxcb-ewmh-dev libxcb-xinput-dev libxcb-icccm4-dev \
        libxcb-res0-dev libcairo2-dev libpango1.0-dev
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release
    ninja
    mkdir ~/hyprsource/artifact
    cp ./hyprctl/hyprctl ~/hyprsource/artifact
    cp ./hyprpm/src/hyprpm ~/hyprsource/artifact
    cp ./src/Hyprland ~/hyprsource/artifact
    ensure_root ninja install
cd ~
