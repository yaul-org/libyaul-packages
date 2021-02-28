#!/bin/bash
{
source "${HOME}/envs.sh"


mount_share
clone_repository
sync_pacman

# This will catch a bad REPO_OS value
cd "repository/pacman/${REPO_OS}" || { panic "Directory path pacman/${REPO_OS} doesn't exist" 1; }

export REPO_PACKAGE="yaul-emulator-mednafen"
export REPO_DIR="yaul-emulator-mednafen"
pushd ${REPO_DIR} || { panic "Directory ${REPO_DIR} doesn't exist" 1; }
make_pkg
pkgver=$(extract_pkgver_file "PKGBUILD")
/bin/bash "${HOME}/update-repo.sh" "${pkgver}" || exit 1
popd || exit 1

# XXX: For now, this isn't supported
[[ "${REPO_OS}" != "mingw-w64" ]] && exit 0

export REPO_PACKAGE="yaul-emulator-yabause"
export REPO_DIR="yaul-emulator-yabause"
pushd ${REPO_DIR} || { panic "Directory ${REPO_DIR} doesn't exist" 1; }
make_pkg
pkgver=$(extract_pkgver_file "PKGBUILD")
/bin/bash "${HOME}/update-repo.sh" "${pkgver}" || exit 1
popd || exit 1
}
