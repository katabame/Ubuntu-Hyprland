#!/usr/bin/bash
set -e

XORG_MACROS_TAG='util-macros-1.20.1'
WAYLAND_TAG='1.22.92'
WAYLAND_PROTOCOLS_TAG='1.36'
HYPRLANG_TAG='v0.5.1'
HYPRCURSOR_TAG='v0.1.8'
HYPRLAND_PROTOCOLS_TAG='v0.2'
XDG_DESKTOP_PORTAL_HYPRLAND_TAG='v1.3.1'
HYPRWAYLAND_SCANNER_TAG='v0.3.6'
HYPRLAND_TAG='v0.40.0'


## -- TRAP!!
codename=$(grep ^UBUNTU_CODENAME /etc/os-release | cut -d '=' -f2)
if [ "${codename}" != 'noble' ]; then
    echo 'Please upgrade your Ubuntu version to noble first!'
    exit 1
fi

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

# 02 additonal dependencies
# cf. https://gist.github.com/Vertecedoc4545/6e54487f07a1888b656b656c0cdd9764
# cf. https://gist.github.com/katabame/e368988c968278c83c19bd5f5b60f407
# those should be sorted (which package required by what)
apt_install \
    gettext gettext-base fontconfig libfontconfig-dev \
    libxkbcommon-x11-dev libxkbregistry-dev seatd libvulkan-dev \
    libvulkan-volk-dev libvkfft-dev libgulkan-dev libegl1-mesa-dev \
    glslang-tools libinput-bin libavutil-dev libavcodec-dev \
    libavformat-dev vulkan-utility-libraries-dev

## 70 xorg-macros
git clone --depth 1 -b ${XORG_MACROS_TAG} https://gitlab.freedesktop.org/xorg/util/macros.git
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

## 80 execinfo
## 81 epoll-shim
#git clone https://github.com/jiixyj/epoll-shim.git
#cmake -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
#cmake --build ./build -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
#sudo cmake --install ./build

# 90 hyprlang
git clone --depth 1 -b ${HYPRLANG_TAG} https://github.com/hyprwm/hyprlang.git
cd ./hyprlang
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target hyprlang -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource

# 91 hyprcursor
git clone --depth 1 -b ${HYPRCURSOR_TAG} https://github.com/hyprwm/hyprcursor.git
cd ./hyprcursor
    apt_install libzip-dev librsvg2-dev libtomlplusplus-dev
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource

# 92 wayland
git clone --depth 1 -b ${WAYLAND_TAG} https://gitlab.freedesktop.org/wayland/wayland.git
cd ./wayland
    apt_install libxml2-dev
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release -Ddocumentation=false
    ninja
    ensure_root ninja install
cd ~/hyprsource

# 93 wayland-protocols
git clone --depth 1 -b ${WAYLAND_PROTOCOLS_TAG} https://gitlab.freedesktop.org/wayland/wayland-protocols.git
cd ./wayland-protocols
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release
    ninja
    ensure_root ninja install
cd ~/hyprsource

# 94 hyprland-protocols
git clone --depth 1 -b ${HYPRLAND_PROTOCOLS_TAG} https://github.com/hyprwm/hyprland-protocols.git
cd ./hyprland-protocols
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release
    ensure_root ninja install
cd ~/hyprsource

# 95 xdg-desktop-portal-hyprland
git clone --depth 1 -b ${XDG_DESKTOP_PORTAL_HYPRLAND_TAG} --recurse-submodules https://github.com/hyprwm/xdg-desktop-portal-hyprland.git
cd ./xdg-desktop-portal-hyprland
    apt_install libpipewire-0.3-dev libsdbus-c++-dev qt6-base-dev libdrm-dev libgbm-dev
    cmake -DCMAKE_INSTALL_LIBEXECDIR:PATH=/usr/lib -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource

# 96 hyprwayland-scanner
git clone --depth 1 -b ${HYPRWAYLAND_SCANNER_TAG} https://github.com/hyprwm/hyprwayland-scanner.git
cd ./hyprwayland-scanner
    apt_install libpugixml-dev
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource

# 99 Hyprland
git clone --depth 1 -b ${HYPRLAND_TAG} --recurse-submodules https://github.com/hyprwm/hyprland.git
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
