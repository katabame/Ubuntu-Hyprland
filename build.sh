#!/usr/bin/bash
set -e

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
echo "::group::Install basic dependencies"
ensure_root apt-get update
apt_install \
    ca-certificates meson jq cmake-extras \
    git wget automake build-essential curl
echo "::endgroup::"

# 02 additional dependencies
# cf. https://gist.github.com/Vertecedoc4545/6e54487f07a1888b656b656c0cdd9764
# cf. https://gist.github.com/katabame/e368988c968278c83c19bd5f5b60f407
# those should be sorted (which package required by what)
echo "::group::Install additional dependencies"
apt_install \
    gettext gettext-base fontconfig libfontconfig-dev \
    libxkbcommon-x11-dev libxkbregistry-dev seatd libvulkan-dev \
    libvulkan-volk-dev libvkfft-dev libgulkan-dev libegl1-mesa-dev \
    glslang-tools libinput-bin libavutil-dev libavcodec-dev \
    libavformat-dev vulkan-utility-libraries-dev
echo "::endgroup::"

# 03 determine repository tag
case "$1" in
    nightly)
        echo "Build target: nightly"
        XORG_MACROS_TAG='master'
        WAYLAND_TAG='main'
        WAYLAND_PROTOCOLS_TAG='main'
        HYPRLANG_TAG='main'
        HYPRCURSOR_TAG='main'
        HYPRLAND_PROTOCOLS_TAG='main'
        XDG_DESKTOP_PORTAL_HYPRLAND_TAG='master'
        HYPRWAYLAND_SCANNER_TAG='main'
        HYPRLAND_TAG='main'
    ;;
    canary)
        echo "Build target: canary"
        XORG_MACROS_TAG=`curl https://gitlab.freedesktop.org/api/v4/projects/798/repository/tags | jq -r '.[0].name'`
        WAYLAND_TAG=`curl https://gitlab.freedesktop.org/api/v4/projects/121/repository/tags | jq -r '.[0].name'`
        WAYLAND_PROTOCOLS_TAG=`curl https://gitlab.freedesktop.org/api/v4/projects/2891/repository/tags | jq -r '.[0].name'`
        HYPRLANG_TAG=`curl https://api.github.com/repos/hyprwm/hyprlang/releases/latest | jq -r '.tag_name'`
        HYPRCURSOR_TAG=`curl https://api.github.com/repos/hyprwm/hyprcursor/releases/latest | jq -r '.tag_name'`
        HYPRLAND_PROTOCOLS_TAG=`curl https://api.github.com/repos/hyprwm/hyprland-protocols/releases/latest | jq -r '.tag_name'`
        XDG_DESKTOP_PORTAL_HYPRLAND_TAG=`curl https://api.github.com/repos/hyprwm/xdg-desktop-portal-hyprland/releases/latest | jq -r '.tag_name'`
        HYPRWAYLAND_SCANNER_TAG=`curl https://api.github.com/repos/hyprwm/hyprwayland-scanner/releases/latest | jq -r '.tag_name'`
        HYPRLAND_TAG=`curl https://api.github.com/repos/hyprwm/hyprland/releases/latest | jq -r '.tag_name'`
    ;;
    *)
        echo "Build target: stable"
        # Build successful versions as of 2024-05-11 02:00 PM GMT+9
        XORG_MACROS_TAG='util-macros-1.20.1'     # 2024-04-17 05:06 AM GMT+9
        WAYLAND_TAG='1.22.92'                    # 2024-05-09 11:53 PM GMT+9
        WAYLAND_PROTOCOLS_TAG='1.36'             # 2024-04-26 08:41 PM GMT+9
        HYPRLANG_TAG='v0.5.1'                    # 2024-04-15 04:04 AM GMT+9
        HYPRCURSOR_TAG='v0.1.8'                  # 2024-04-26 05:38 AM GMT+9
        HYPRLAND_PROTOCOLS_TAG='v0.2'            # 2023-04-27 05:32 AM GMT+9
        XDG_DESKTOP_PORTAL_HYPRLAND_TAG='v1.3.1' # 2024-01-06 12:01 AM GMT+9
        HYPRWAYLAND_SCANNER_TAG='v0.3.4'         # 2024-05-04 02:01 AM GMT+9
        HYPRLAND_TAG='v0.40.0'                   # 2024-05-05 12:56 AM GMT+9
    ;;
esac

## 70 xorg-macros
echo "::group::Build xorg-macros"
git clone --depth 1 --branch ${XORG_MACROS_TAG} https://gitlab.freedesktop.org/xorg/util/macros.git
cd ./macros
    ./autogen.sh
    ./configure
    ensure_root make install
cd ~/hyprsource
echo "::endgroup::"

# 90 hyprlang
echo "::group::Build hyprlang"
git clone --depth 1 --branch ${HYPRLANG_TAG} https://github.com/hyprwm/hyprlang.git
cd ./hyprlang
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target hyprlang -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource
echo "::endgroup::"

# 91 hyprcursor
echo "::group::Build hyprcursor"
git clone --depth 1 --branch ${HYPRCURSOR_TAG} https://github.com/hyprwm/hyprcursor.git
cd ./hyprcursor
    apt_install libzip-dev librsvg2-dev libtomlplusplus-dev
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource
echo "::endgroup::"

# 92 wayland
echo "::group::Build wayland"
git clone --depth 1 --branch ${WAYLAND_TAG} https://gitlab.freedesktop.org/wayland/wayland.git
cd ./wayland
    apt_install libxml2-dev
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release -Ddocumentation=false
    ninja
    ensure_root ninja install
cd ~/hyprsource
echo "::endgroup::"

# 93 wayland-protocols
echo "::group::Build wayland-protocols"
git clone --depth 1 --branch ${WAYLAND_PROTOCOLS_TAG} https://gitlab.freedesktop.org/wayland/wayland-protocols.git
cd ./wayland-protocols
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release
    ninja
    ensure_root ninja install
cd ~/hyprsource
echo "::endgroup::"

# 94 hyprland-protocols
echo "::group::Build hyprland-protocols"
git clone --depth 1 --branch ${HYPRLAND_PROTOCOLS_TAG} https://github.com/hyprwm/hyprland-protocols.git
cd ./hyprland-protocols
    mkdir ./build && cd ./build
    meson setup --prefix=/usr --buildtype=release
    ensure_root ninja install
cd ~/hyprsource
echo "::endgroup::"

# 95 xdg-desktop-portal-hyprland
echo "::group::Build xdg-desktop-portal-hyprland"
git clone --depth 1 --branch ${XDG_DESKTOP_PORTAL_HYPRLAND_TAG} --recurse-submodules https://github.com/hyprwm/xdg-desktop-portal-hyprland.git
cd ./xdg-desktop-portal-hyprland
    apt_install libpipewire-0.3-dev libsdbus-c++-dev qt6-base-dev libdrm-dev libgbm-dev
    mkdir ./build && cd ./build
    meson setup --libexecdir /usr/libexec --prefix /usr --buildtype=release
    ninja
    ensure_root ninja install
cd ~/hyprsource
echo "::endgroup::"

# 96 hyprwayland-scanner
echo "::group::Build hyprwayland-scanner"
git clone --depth 1 --branch ${HYPRWAYLAND_SCANNER_TAG} https://github.com/hyprwm/hyprwayland-scanner.git
cd ./hyprwayland-scanner
    apt_install libpugixml-dev
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    ensure_root cmake --install ./build
cd ~/hyprsource
echo "::endgroup::"

# 99 Hyprland
echo "::group::Build hyprland"
git clone --depth 1 --branch ${HYPRLAND_TAG} --recurse-submodules https://github.com/hyprwm/hyprland.git
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
echo "::endgroup::"
