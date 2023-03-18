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

new_pkgver=$(extract_pkgver "PKGBUILD")
new_pkgrel=$(extract_pkgrel "PKGBUILD")

update_repo_db "${PKG_NAME}" "${new_pkgver}" "${new_pkgrel}"
sync_repo "${REPO_SUBPATH}"
}
