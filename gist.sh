#!/bin/bash
set -ex

# For Ubuntu 22.04
UBUNTU_VERSION=`lsb_release -r | awk '{print $2}'`
OLD_UBUNTU_VERSION='22.04'
PIXMAN_VERSION='0.43.4'
XCBPROTO_VERSION='1.17.0'
LIBXCB_VERSION='1.17.0'

HYPRLAND_VERSION='0.38.1'
HYPRLANG_VERSION='0.5.0'
HYPRCURSOR_VERSION='0.1.7'
WAYLAND_VERSION='1.22.0'
WAYLAND_PROTOCOLS_VERSION='1.34'
LIBDISPLAY_INFO_VERSION='0.1.1'
TOMLPLUSPLUS_VERSION='3.4.0'

if [ "${UBUNTU_VERSION}" = "${OLD_UBUNTU_VERSION}" ]; then
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    sudo apt-get install -y --no-install-recommends \
        wget build-essential cmake-extras cmake \
        gettext gettext-base fontconfig libfontconfig-dev libffi-dev libxml2-dev \
        libxkbcommon-x11-dev libxkbregistry-dev libxkbcommon-dev libpixman-1-dev \
        libudev-dev libseat-dev seatd libvulkan-dev libvulkan-volk-dev \
        vulkan-validationlayers-dev libvkfft-dev libgulkan-dev libegl-dev libgles2 \
        libegl1-mesa-dev glslang-tools libinput-bin libinput-dev \
        libavutil-dev libavcodec-dev libavformat-dev \
        libpango1.0-dev xdg-desktop-portal-wlr hwdata \
        libcairo2-dev libzip-dev librsvg2-dev libgbm-dev jq \
        gcc-13 g++-13 python3-pip autoconf automake xutils-dev libtool
    sudo pip3 install meson ninja
    export CC=/usr/bin/gcc-13
    export CXX=/usr/bin/g++-13
else
    sudo apt-get install -y --no-install-recommends \
        meson wget build-essential ninja-build cmake-extras cmake \
        gettext gettext-base fontconfig libfontconfig-dev libffi-dev libxml2-dev \
        libxkbcommon-x11-dev libxkbregistry-dev libxkbcommon-dev libpixman-1-dev \
        libudev-dev libseat-dev seatd libxcb-dri3-dev libvulkan-dev libvulkan-volk-dev \
        vulkan-utility-libraries-dev libvkfft-dev libgulkan-dev libegl-dev libgles2 \
        libegl1-mesa-dev glslang-tools libinput-bin libinput-dev libxcb-composite0-dev \
        libavutil-dev libavcodec-dev libavformat-dev libxcb-ewmh2 libxcb-ewmh-dev \
        libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev \
        libxcb-xinput-dev libpango1.0-dev xdg-desktop-portal-wlr hwdata \
        libcairo2-dev libzip-dev librsvg2-dev libgbm-dev jq
fi

mkdir ~/HyprSource
cd ~/HyprSource

## Clone sources

# hyprland
wget -O hyprland.tar.gz "https://github.com/hyprwm/Hyprland/releases/download/v${HYPRLAND_VERSION}/source-v${HYPRLAND_VERSION}.tar.gz"
mkdir ~/HyprSource/hyprland &&
tar -xzf hyprland.tar.gz -C ~/HyprSource/hyprland --strip-components 1 &&
rm hyprland.tar.gz

# hyprlang
wget -O hyprlang.tar.gz "https://github.com/hyprwm/hyprlang/archive/refs/tags/v${HYPRLANG_VERSION}.tar.gz"
mkdir ~/HyprSource/hyprlang &&
tar -xzf hyprlang.tar.gz -C ~/HyprSource/hyprlang --strip-components 1 &&
rm hyprlang.tar.gz

# hyprcursor
wget -O hyprcursor.tar.gz "https://github.com/hyprwm/hyprcursor/archive/refs/tags/v${HYPRCURSOR_VERSION}.tar.gz"
mkdir ~/HyprSource/hyprcursor &&
tar -xzf hyprcursor.tar.gz -C ~/HyprSource/hyprcursor --strip-components 1 &&
rm hyprcursor.tar.gz

# wayland
wget -O wayland.tar.gz "https://gitlab.freedesktop.org/wayland/wayland/-/archive/${WAYLAND_VERSION}/wayland-${WAYLAND_VERSION}.tar.gz"
mkdir ~/HyprSource/wayland &&
tar -xzf wayland.tar.gz -C ~/HyprSource/wayland --strip-components 1 &&
rm wayland.tar.gz

# wayland-protocols
wget -O wayland-protocols.tar.gz "https://gitlab.freedesktop.org/wayland/wayland-protocols/-/archive/${WAYLAND_PROTOCOLS_VERSION}/wayland-protocols-${WAYLAND_PROTOCOLS_VERSION}.tar.gz"
mkdir ~/HyprSource/wayland-protocols &&
tar -xzf wayland-protocols.tar.gz -C ~/HyprSource/wayland-protocols --strip-components 1 &&
rm wayland-protocols.tar.gz

# libdisplay-info
wget -O libdisplay-info.tar.gz "https://gitlab.freedesktop.org/emersion/libdisplay-info/-/archive/${LIBDISPLAY_INFO_VERSION}/libdisplay-info-${LIBDISPLAY_INFO_VERSION}.tar.gz"
mkdir ~/HyprSource/libdisplay-info &&
tar -xzf libdisplay-info.tar.gz -C ~/HyprSource/libdisplay-info --strip-components 1 &&
rm libdisplay-info.tar.gz

# tomlplusplus
wget -O tomlplusplus.tar.gz "https://github.com/marzer/tomlplusplus/archive/refs/tags/v${TOMLPLUSPLUS_VERSION}.tar.gz"
mkdir ~/HyprSource/tomlplusplus &&
tar -xzf tomlplusplus.tar.gz -C ~/HyprSource/tomlplusplus --strip-components 1 &&
rm tomlplusplus.tar.gz

# libdrm
wget -O libdrm.tar.gz "https://gitlab.freedesktop.org/mesa/drm/-/archive/main/drm-main.tar.gz"
mkdir ~/HyprSource/libdrm &&
tar -xzf libdrm.tar.gz -C ~/HyprSource/libdrm --strip-components 1 &&
rm libdrm.tar.gz

if [ "${UBUNTU_VERSION}" = "${OLD_UBUNTU_VERSION}" ]; then
    # pixman
    wget -O pixman.tar.gz "https://cairographics.org/releases/pixman-${PIXMAN_VERSION}.tar.gz"
    mkdir ~/HyprSource/pixman &&
    tar -xzf pixman.tar.gz -C ~/HyprSource/pixman --strip-components 1 &&
    rm pixman.tar.gz

    # xcb-proto
    wget -O xcb-proto.tar.gz "https://xcb.freedesktop.org/dist/xcb-proto-${XCBPROTO_VERSION}.tar.gz"
    mkdir ~/HyprSource/xcb-proto &&
    tar -xzf xcb-proto.tar.gz -C ~/HyprSource/xcb-proto --strip-components 1 &&
    rm xcb-proto.tar.gz

    # libxcb
    wget -O libxcb.tar.gz "https://xcb.freedesktop.org/dist/libxcb-${LIBXCB_VERSION}.tar.gz"
    mkdir ~/HyprSource/libxcb &&
    tar -xzf libxcb.tar.gz -C ~/HyprSource/libxcb --strip-components 1 &&
    rm libxcb.tar.gz
fi

## Build dependencies

# wayland
cd ~/HyprSource/wayland
mkdir ./build &&
cd    ./build &&
meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -Ddocumentation=false &&
ninja
sudo ninja install

# wayland-protocols
cd ~/HyprSource/wayland-protocols
mkdir ./build &&
cd    ./build &&
meson setup --prefix=/usr --buildtype=release &&
ninja
sudo ninja install

# libdisplay-info
cd ~/HyprSource/libdisplay-info
mkdir ./build &&
cd    ./build &&
meson setup --prefix=/usr --buildtype=release &&
ninja
sudo ninja install

# tomlplusplus
cd ~/HyprSource/tomlplusplus
mkdir ./build &&
cd    ./build &&
meson setup --prefix=/usr --buildtype=release &&
ninja
sudo ninja install

# libdrm
cd ~/HyprSource/libdrm
mkdir ./build &&
cd    ./build &&
meson setup --prefix=/usr --buildtype=release &&
ninja
sudo ninja install

# hyprlang
cd ~/HyprSource/hyprlang
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
cmake --build ./build --config Release --target hyprlang -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
sudo cmake --install ./build

# hyprcursor
cd ~/HyprSource/hyprcursor
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
sudo cmake --install ./build

if [ "${UBUNTU_VERSION}" = "${OLD_UBUNTU_VERSION}" ]; then
    # pixman
    cd ~/HyprSource/pixman
    mkdir ./build &&
    cd    ./build &&
    meson setup --prefix=/usr --buildtype=release &&
    ninja
    sudo ninja install

    # xcb-proto
    cd ~/HyprSource/xcb-proto
    ./autogen.sh
    ./configure &&
    make
    sudo make install

    # libxcb
    cd ~/HyprSource/libxcb
    ./autogen.sh
    ./configure &&
    make
    sudo make install
fi

# hyprland
cd ~/HyprSource/hyprland
sed -i 's/\/usr\/local/\/usr/g' Makefile
mkdir ./build &&
cd    ./build &&
meson setup --prefix=/usr --buildtype=release &&
ninja
sudo ninja install

## back to home directory
cd ~

echo "NOW YOU HAVE HYPRLAND INSTALLED!!!"
