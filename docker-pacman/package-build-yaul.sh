#!/bin/bash

set -x

export REPO_SUBPATH="${REPO_OS}/x86_64"
export REPO_PATH="${REPO_ROOT_PATH}/${REPO_SUBPATH}"
export REPO_DB="${REPO_PATH}/yaul-${REPO_OS}.db.tar.xz"
export REPO_PACKAGE="yaul-git"
export REPO_DIR="yaul"

source "${HOME}/utils.sh"

linux_makepkg() {
    # Unfortunately, there's a bug in the libftdi package. See:
    # <https://bugs.archlinux.org/task/69115>.
    sudo /usr/sbin/pacman -S --noconfirm libftdi pkg-config
    sudo /bin/sed -E -i 's/libftdipp1/libftdi1/g' /usr/lib/pkgconfig/libftdi1.pc

    /usr/sbin/makepkg -sC --noconfirm || { panic "Unable to build package" 1; }
}

mingw_w64_makepkg() {
    # Use the same PKGBUILD that's used for MinGW, but on Linux. In order for
    # this to be possible, the BUILD_CROSS ENV must be set, as Yaul tools depend
    # on it.
    #
    # A possible "better" solution would be to create a cross-compilation Yaul
    # PKGBUILD that explicitly depends on mingw-w64-gcc and sets BUILD_CROSS
    # directly to make.
    sudo /usr/sbin/pacman -S --noconfirm community/mingw-w64-gcc || { panic "Unable to install community/mingw-w64-gcc" 1; }

    BUILD_CROSS=1 /usr/sbin/makepkg -sC --noconfirm || { panic "Unable to build package" 1; }
}

[ -z "${REPO_OS}" ] && { panic "Environment variable REPO_OS must be specified" 1; } 

/bin/mount "${REPO_ROOT_PATH}" || { panic "Unable to mount repository mount point" 1; }

/usr/bin/git clone "git@github.com:ijacquez/libyaul-packages" repository || { panic "Unable to clone repository" 1; }

# This will catch a bad REPO_OS value
cd "repository/pacman/${REPO_OS}" || { panic "Directory path pacman/${REPO_OS} doesn't exist" 1; }

sudo /usr/sbin/pacman -Syy || { panic "Unable to sync" 1; }

pushd ${REPO_DIR} || { panic "Package ${REPO_DIR} doesn't exist" 1; }

# Force install the tool-chain for Linux
sudo /usr/sbin/pacman -S --noconfirm yaul-linux/yaul-tool-chain || { panic "Unable to install yaul-tool-chain" 1; }

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
pkgver=$(sed -n -E 's/^pkgver=(.*)$/\1/pg' PKGBUILD 2>/dev/null)

/bin/bash "${HOME}/update-repo.sh" "${pkgver}" || exit 1
popd || exit 1
