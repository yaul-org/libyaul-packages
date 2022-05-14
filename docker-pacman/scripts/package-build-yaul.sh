#!/bin/bash

set -x

source "${HOME}/envs.sh"

export REPO_PACKAGE="yaul-git"
export REPO_DIR="yaul"

linux_makepkg() {
    # XXX: Unfortunately, there's a bug in the libftdi package. See:
    #      <https://bugs.archlinux.org/task/69115>.
    install_pkg libftdi pkg-config
    sudo /bin/sed -E -i 's/libftdipp1/libftdi1/g' /usr/lib/pkgconfig/libftdi1.pc

    make_pkg -sC
}

mingw_w64_makepkg() {
    # Use the same PKGBUILD that's used for MinGW, but on Linux. In order for
    # this to be possible, the BUILD_CROSS ENV must be set, as Yaul tools depend
    # on it.
    #
    # A possible "better" solution would be to create a cross-compilation Yaul
    # PKGBUILD that explicitly depends on mingw-w64-gcc and sets BUILD_CROSS
    # directly to make.
    BUILD_CROSS=1 make_pkg -sC
}

/bin/bash -x "${HOME}/s3mirror.sh" "${REPO_SUBPATH}" || exit 1
clone_repository

# This will catch a bad REPO_OS value
cd "repository/pacman/${REPO_OS}/${REPO_DIR}" || { panic "Directory path pacman/${REPO_OS}/${REPO_DIR} doesn't exist" 1; }

sync_pacman

# Force install the tool-chain for Linux
install_pkg yaul-linux/yaul-tool-chain-git

case "${REPO_OS}" in
    "linux")
        linux_makepkg
        ;;
    "mingw-w64")
        mingw_w64_makepkg
        ;;
esac

# There might be a better way, but makepkg updates PKGBUILD's pkgver
new_pkgver=$(extract_pkgver_file "PKGBUILD")

/bin/bash "${HOME}/update-repo.sh" "${new_pkgver}" || exit 1
