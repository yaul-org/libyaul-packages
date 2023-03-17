#!/bin/bash
{
source "${BUILD_BASEPATH}/scripts/envs.sh" || exit 1

export PKG_NAME="ssshell"
export PKG_SUBPATH="pacman/ssshell"

apply_libftdi_fix() {
    # XXX: Unfortunately, there's a bug in the libftdi package. See:
    #      <https://bugs.archlinux.org/task/69115>.
    sudo /bin/sed -E -i 's/libftdipp1/libftdi1/g' /usr/lib/pkgconfig/libftdi1.pc
}

cd "${BUILD_BASEPATH}" || exit 1

mirror_repo
clone_repository "${GIT_BRANCH}"
sync_pacman

install_pkg libftdi pkg-config
apply_libftdi_fix
cd "${BUILD_BASEPATH}/repository/${PKG_SUBPATH}" || { panic "Directory path ${PKG_SUBPATH} doesn't exist" 1; }
make_pkg -sC

new_pkgver=$(extract_pkgver_file "PKGBUILD")
new_pkgrel=$(extract_pkgrel_file "PKGBUILD")

update_repo "${PKG_NAME}" "${new_pkgver}" "${new_pkgrel}"
}
