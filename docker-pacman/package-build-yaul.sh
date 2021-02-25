#!/bin/bash

set -x

source "${HOME}/envs.sh"

export REPO_PACKAGE="yaul-git"
export REPO_DIR="yaul"

linux_makepkg() {
    # Unfortunately, there's a bug in the libftdi package. See:
    # <https://bugs.archlinux.org/task/69115>.
    install_pkg libftdi pkg-config
    sudo /bin/sed -E -i 's/libftdipp1/libftdi1/g' /usr/lib/pkgconfig/libftdi1.pc

    make_pkg
}

mingw_w64_makepkg() {
    # Use the same PKGBUILD that's used for MinGW, but on Linux. In order for
    # this to be possible, the BUILD_CROSS ENV must be set, as Yaul tools depend
    # on it.
    #
    # A possible "better" solution would be to create a cross-compilation Yaul
    # PKGBUILD that explicitly depends on mingw-w64-gcc and sets BUILD_CROSS
    # directly to make.
    BUILD_CROSS=1 make_pkg
}

mount_share
clone_repository

# This will catch a bad REPO_OS value
cd "repository/pacman/${REPO_OS}" || { panic "Directory path pacman/${REPO_OS} doesn't exist" 1; }

sync_pacman

cd ${REPO_DIR} || { panic "Directory ${REPO_DIR} doesn't exist" 1; }

# Force install the tool-chain for Linux
install_pkg yaul-linux/yaul-tool-chain

case "${REPO_OS}" in
    "linux")
        linux_makepkg
        ;;
    "mingw-w64")
        mingw_w64_makepkg
        ;;
    *)
        panic "Unknown REPO_OS value" 1
        ;;
esac

# There might be a better way, but makepkg updates PKGBUILD's pkgver
pkgver=$(extract_pkgver_file "PKGBUILD")

/bin/bash "${HOME}/update-repo.sh" "${pkgver}" || exit 1
