#!/bin/bash
{
source "${HOME}/envs.sh"

export REPO_PACKAGE="yaul-examples-git"
export REPO_DIR="yaul-examples"

mount_share
clone_repository
sync_pacman

cd "repository/pacman/${REPO_DIR}" || { panic "Directory pacman/${REPO_DIR} doesn't exist" 1; }

old_pkgver=$(extract_pkgver_file "PKGBUILD")

if ! package_exists "${REPO_PACKAGE}" "${old_pkgver}"; then
    make_pkg

    pkgver=$(extract_pkgver_file "PKGBUILD")

    /bin/bash "${HOME}/update-repo.sh" "${pkgver}" || exit 1
fi
}
