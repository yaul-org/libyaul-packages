#!/bin/bash
{
source "${BUILD_BASEPATH}/scripts/envs.sh" || exit 1

export PKG_NAME="yaul-tool-chain-git"
export PKG_SUBPATH="pacman/yaul-tool-chain"

cd "${BUILD_BASEPATH}" || exit 1

mirror_repo
clone_repository "${GIT_BRANCH}"
sync_pacman

cd "${BUILD_BASEPATH}/repository/${PKG_SUBPATH}" || { panic "Directory path ${PKG_SUBPATH} doesn't exist" 1; }
make_pkg -sC

new_pkgver=$(extract_pkgver_file "PKGBUILD")
new_pkgrel=$(extract_pkgrel_file "PKGBUILD")

update_repo "${PKG_NAME}" "${new_pkgver}" "${new_pkgrel}"
}
