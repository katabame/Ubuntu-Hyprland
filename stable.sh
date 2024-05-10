#!/usr/bin/bash
set -e

HYPRLAND_VERSION='0.39.1'
HYPRLANG_VERSION='0.5.1'
HYPRCURSOR_VERSION='0.1.8'
WAYLAND_VERSION='1.22.92'
WAYLAND_PROTOCOLS_VERSION='1.36'


## ensure_root <command>
function ensure_root() {
    if [[ `groups` =~ "root" ]]; then
            "$@"
    else
            sudo "$@"
    fi
}

## apt_install <packages>
function apt_install() {
    ensure_root apt-get install -y --no-install-recommends "$@"
}

## download_tarball <name> <url>
function download_tarball() {
    wget -O $1.tar.gz $2
    mkdir ~/hyprsource/$1
    tar -xzf $1.tar.gz -C ~/hyprsource/$1 --strip-components 1
    rm $1.tar.gz
    cd ~/hyprsource/$1
}

## -- TRAP!!
codename=$(grep ^UBUNTU_CODENAME /etc/os-release | cut -d '=' -f2)
if [ "${codename}" != 'noble' ]; then
    echo 'Please upgrade your Ubuntu version to noble first!'
    exit 1
fi


## 00 change working directory
if [ -d ~/hyprsource ]; then
    rm -rf ~/hyprsource
fi
mkdir ~/hyprsource
cd ~/hyprsource


## 01 basic build tools
ensure_root apt-get update
apt_install \
    ca-certificates meson jq cmake-extras \
    git wget automake build-essential


## 80 wayland
download_tarball wayland "https://gitlab.freedesktop.org/wayland/wayland/-/archive/${WAYLAND_VERSION}/wayland-${WAYLAND_VERSION}.tar.gz"
    apt_install libffi-dev libexpat1-dev libxml2-dev
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release -Ddocumentation=false
    ninja
    ensure_root ninja install
cd ~/hyprsource

## 81 wayland-protocols
download_tarball wayland-protocols "https://gitlab.freedesktop.org/wayland/wayland-protocols/-/archive/${WAYLAND_PROTOCOLS_VERSION}/wayland-protocols-${WAYLAND_PROTOCOLS_VERSION}.tar.gz"
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release
    ninja
    ensure_root ninja install
cd ~/hyprsource

## 90 hyprlang
download_tarball hyprlang "https://github.com/hyprwm/hyprlang/archive/refs/tags/v${HYPRLANG_VERSION}.tar.gz"
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target hyprlang -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource

## 91 hyprcursor
download_tarball hyprcursor "https://github.com/hyprwm/hyprcursor/archive/refs/tags/v${HYPRCURSOR_VERSION}.tar.gz"
    apt_install libzip-dev librsvg2-dev libtomlplusplus-dev
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource

## 99 hyprland
download_tarball hyprland "https://github.com/hyprwm/Hyprland/releases/download/v${HYPRLAND_VERSION}/source-v${HYPRLAND_VERSION}.tar.gz"
    apt_install \
        libdrm-dev libxkbcommon-dev libxkbcommon-x11-dev \
        libpixman-1-dev libegl-dev libgbm-dev libgles-dev \
        libcairo2-dev libinput-dev libinput-bin libpango1.0-dev
    sed -i 's/\/usr\/local/\/usr/g' Makefile
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release
    ninja
cd ~/hyprsource
