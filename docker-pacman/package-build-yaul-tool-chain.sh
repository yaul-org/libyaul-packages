#!/bin/bash

set -x

source "${HOME}/envs.sh"

export REPO_PACKAGE="yaul-tool-chain"
export REPO_DIR="yaul-tool-chain"

linux_makepkg() {
    make_pkg
}

mingw_w64_makepkg() {
    make_pkg
}

mount_share
clone_repository

# This will catch a bad REPO_OS value
cd "repository/pacman/${REPO_OS}/${REPO_DIR}" || { panic "Directory path pacman/${REPO_OS}/${REPO_DIR} doesn't exist" 1; }

sync_pacman

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
