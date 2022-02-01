#!/bin/bash
{
source "${HOME}/envs.sh"

linux_build_kronos() {
    export REPO_PACKAGE="yaul-emulator-kronos-git"
    export REPO_DIR="yaul-emulator-kronos"
    pushd ${REPO_DIR} || { panic "Directory ${REPO_DIR} doesn't exist" 1; }
    make_pkg -sC
    new_pkgver=$(extract_pkgver_file "PKGBUILD")
    /bin/bash "${HOME}/update-repo.sh" "${new_pkgver}" || exit 1
    popd || exit 1
}

mingw_w64_build_yabause() {
    export REPO_PACKAGE="yaul-emulator-yabause"
    export REPO_DIR="yaul-emulator-yabause"
    pushd ${REPO_DIR} || { panic "Directory ${REPO_DIR} doesn't exist" 1; }
    old_pkgver=$(extract_pkgver_file "PKGBUILD")
    if ! package_exists "${REPO_PACKAGE}" "${old_pkgver}"; then
        make_pkg -sC
        new_pkgver=$(extract_pkgver_file "PKGBUILD")
        /bin/bash "${HOME}/update-repo.sh" "${new_pkgver}" || exit 1
    fi
    popd || exit 1
}

mount_share
clone_repository
sync_pacman

# This will catch a bad REPO_OS value
cd "repository/pacman/${REPO_OS}" || { panic "Directory path pacman/${REPO_OS} doesn't exist" 1; }

export REPO_PACKAGE="yaul-emulator-mednafen"
export REPO_DIR="yaul-emulator-mednafen"
pushd ${REPO_DIR} || { panic "Directory ${REPO_DIR} doesn't exist" 1; }
old_pkgver=$(extract_pkgver_file "PKGBUILD")
if ! package_exists "${REPO_PACKAGE}" "${old_pkgver}"; then
    make_pkg -sC
    new_pkgver=$(extract_pkgver_file "PKGBUILD")
    /bin/bash "${HOME}/update-repo.sh" "${new_pkgver}" || exit 1
fi
popd || exit 1

case "${REPO_OS}" in
    "linux")
        linux_build_kronos
        ;;
    "mingw-w64")
        mingw_w64_build_yabause
        ;;
esac
}
