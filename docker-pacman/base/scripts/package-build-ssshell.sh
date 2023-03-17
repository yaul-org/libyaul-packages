#!/bin/bash
{
set -x

source "${REPO_BASEPATH}/scripts/envs.sh" || exit 1

export REPO_PACKAGE="ssshell"
export REPO_DIR="ssshell"

apply_libftdi_fix() {
    # XXX: Unfortunately, there's a bug in the libftdi package. See:
    #      <https://bugs.archlinux.org/task/69115>.
    sudo /bin/sed -E -i 's/libftdipp1/libftdi1/g' /usr/lib/pkgconfig/libftdi1.pc
}

cd "${REPO_BASEPATH}" || exit 1

s3mirror
clone_repository "${REPO_BRANCH}"
sync_pacman

install_pkg libftdi pkg-config
apply_libftdi_fix
cd "${REPO_BASEPATH}/repository/pacman/${REPO_DIR}" || { panic "Directory path pacman/${REPO_DIR} doesn't exist" 1; }
make_pkg -sC

new_pkgver=$(extract_pkgver_file "PKGBUILD")
new_pkgrel=$(extract_pkgrel_file "PKGBUILD")

update_repo "${REPO_PACKAGE}" "${new_pkgver}" "${new_pkgrel}"
}
