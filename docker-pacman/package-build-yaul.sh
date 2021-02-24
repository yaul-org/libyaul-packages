#!/bin/bash

set -x

REPO_SUBPATH="${REPO_OS}/x86_64"
REPO_PATH="${REPO_ROOT_PATH}/${REPO_SUBPATH}"
REPO_DB="${REPO_PATH}/yaul-packages.db.tar.xz"

panic() {
    printf -- "Error: %s\\n" "${1}" >&2

    exit "${2}"
}

linux_fix_libftdi() {
    # Unfortunately, there's a bug in the libftdi package. See:
    # <https://bugs.archlinux.org/task/69115>.
    sudo /usr/sbin/pacman -S --noconfirm libftdi pkg-config
    sudo /bin/sed -E -i 's/libftdipp1/libftdi1/g' /usr/lib/pkgconfig/libftdi1.pc
}

linux_makepkg() {
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

pushd yaul || { panic "Package yaul doesn't exist" 1; }

# Force install the tool-chain for Linux
sudo /usr/sbin/pacman -S --noconfirm yaul-linux/yaul-tool-chain || { panic "Unable to install yaul-tool-chain" 1; }

case "${REPO_OS}" in
    "linux")
        linux_fix_libftdi
        linux_makepkg
        ;;
    "mingw-w64")
        mingw_w64_makepkg
        ;;
esac

if ! /usr/bin/git diff --exit-code --name-only PKGBUILD >/dev/null 2>&1; then
    # There might be a better way, but makepkg updates PKGBUILD's pkgver
    pkgver=$(sed -n -E 's/^pkgver=(.*)$/\1/pg' PKGBUILD)
    [ -n "${pkgver}" ] || { panic "Unable to fetch package version" 1; }

    mapfile -t files < <(/usr/bin/find "${REPO_PATH}" -type f -name "yaul-git-*.pkg.tar.zst")

    trap '/bin/rm '"${REPO_PATH}/yaul-git-${pkgver}"'-*.pkg.tar.zst' 1

    for file in "${files[@]}"; do
        /usr/sbin/repo-remove "${REPO_DB}" "${file}" || { panic "Unable to remove '${file}' from the repository\n" 1; }
        /bin/rm -f "${file}"
    done

    /bin/cp yaul-git-"${pkgver}"-*.pkg.tar.zst "${REPO_PATH}/"
    /usr/sbin/repo-add "${REPO_DB}" "${REPO_PATH}/yaul-git-${pkgver}"-*.pkg.tar.zst || { panic "Unable to add file to repository" 1; }

    /bin/bash -x "${HOME}/s3sync.sh" "${REPO_SUBPATH}" || exit 1

    /usr/bin/git commit PKGBUILD -m "Update package version for yaul-git ${pkgver}" || { panic "Unable to commit changes" 1; }
    /usr/bin/git push origin -u master || { panic "Unable to push commits" 1; }
fi
popd || exit 1
