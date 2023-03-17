#!/bin/bash
{
set -x

source "${REPO_BASEPATH}/scripts/envs.sh" || exit 1

export REPO_PACKAGE="yaul"
export REPO_DIR="yaul"

cd "${REPO_BASEPATH}" || exit 1

s3mirror
clone_repository "${REPO_BRANCH}"
sync_pacman

cd "${REPO_BASEPATH}/repository/pacman/${REPO_DIR}" || { panic "Directory path pacman/${REPO_DIR} doesn't exist" 1; }
make_pkg -sC

new_pkgver=$(extract_pkgver_file "PKGBUILD")
new_pkgrel=$(extract_pkgrel_file "PKGBUILD")

update_repo "${REPO_PACKAGE}" "${new_pkgver}" "${new_pkgrel}"
}
