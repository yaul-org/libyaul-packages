#!/bin/bash

set -x

panic () {
    printf -- "Error: %s\\n" "${1}" >&2

    exit "${2}"
}

/bin/mount "${REPO_ROOT_PATH}" || { panic "Unable to mount repository mount point" 1; }

/usr/bin/git clone "git@github.com:ijacquez/libyaul-packages" repository || { panic "Unable to clone repository" 1; }

cd repository/pacman/linux || { panic "Directory path pacman/linux doesn't exist" 1; }

sudo /usr/sbin/pacman -Syy || { panic "Unable to sync" 1; }

pushd yaul || { panic "Package yaul doesn't exist" 1; }
# Unfortunately, there's a bug in the libftdi package. See:
# <https://bugs.archlinux.org/task/69115>.
sudo /usr/sbin/pacman -S --noconfirm libftdi pkg-config
sudo /bin/sed -E -i 's/libftdipp1/libftdi1/g' /usr/lib/pkgconfig/libftdi1.pc

# Build package
/usr/sbin/makepkg -sC --noconfirm || { panic "Unable to build package" 1; }

if ! /usr/bin/git diff --exit-code --name-only PKGBUILD >/dev/null 2>&1; then
    # There might be a better way, but makepkg updates PKGBUILD's pkgver
    pkgver=$(sed -n -E 's/^pkgver=(.*)$/\1/pg' PKGBUILD)
    [ -n "${pkgver}" ] || { panic "Unable to fetch package version" 1; }

    mapfile -t files < <(/usr/bin/find "${REPO_PATH}" -type f -name "yaul-git-*.pkg.tar.zst")

    trap '/bin/rm '"${REPO_PATH}/yaul-git-${pkgver}"'-*.pkg.tar.zst' 1

    for file in "${files[@]}"; do
        /usr/sbin/repo-remove "${REPO_DB}" "${file}" || { panic "Unable to remove '%s' from the repository\n" "${file}" 1; }
        /bin/rm -f "${file}"
    done

    /bin/cp yaul-git-"${pkgver}"-*.pkg.tar.zst "${REPO_PATH}/"
    /usr/sbin/repo-add "${REPO_DB}" "${REPO_PATH}/yaul-git-${pkgver}"-*.pkg.tar.zst || { panic "Unable to add file to repository" 1; }

    /bin/bash -x "${HOME}/s3sync.sh" repo/x86_64 || exit 1

    /usr/bin/git commit PKGBUILD -m "Update package version for yaul-git ${pkgver}" || { panic "Unable to commit changes" 1; }
    /usr/bin/git push origin -u master || { panic "Unable to push commits" 1; }
fi
popd || exit 1
