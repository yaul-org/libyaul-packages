#!/bin/bash
{
set -x

source "${REPO_BASEPATH}/scripts/envs.sh" || exit 1

build_kronos() {
    export REPO_PACKAGE="yaul-emulator-kronos-git"
    export REPO_DIR="yaul-emulator-kronos"
    pushd "${REPO_BASEPATH}/repository/pacman/${REPO_DIR}" || { panic "Directory path pacman/${REPO_DIR} doesn't exist" 1; }
    make_pkg -sC
    new_pkgver=$(extract_pkgver_file "PKGBUILD")
    new_pkgrel=$(extract_pkgrel_file "PKGBUILD")
    update_repo "${REPO_PACKAGE}" "${new_pkgver}" "${new_pkgrel}"
    popd || exit 1
}

build_mednafen() {
    export REPO_PACKAGE="yaul-emulator-mednafen"
    export REPO_DIR="yaul-emulator-mednafen"
    pushd "${REPO_BASEPATH}/repository/pacman/${REPO_DIR}" || { panic "Directory path pacman/${REPO_DIR} doesn't exist" 1; }
    make_pkg -sC
    new_pkgver=$(extract_pkgver_file "PKGBUILD")
    new_pkgrel=$(extract_pkgrel_file "PKGBUILD")
    update_repo "${REPO_PACKAGE}" "${new_pkgver}" "${new_pkgrel}"
    popd || exit 1
}

cd "${REPO_BASEPATH}" || exit 1

s3mirror
clone_repository "${REPO_BRANCH}"
sync_pacman

build_kronos
build_mednafen
}
