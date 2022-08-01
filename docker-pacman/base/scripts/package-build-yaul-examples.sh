#!/bin/bash
{
set -x

source "${REPO_BASEPATH}/scripts/envs.sh" || exit 1

export REPO_PACKAGE="yaul-examples-git"
export REPO_DIR="yaul-examples"

mkdir -p "${REPO_BASEPATH}/s3"

cd "${REPO_BASEPATH}" || exit 1
/bin/bash -x "${REPO_BASEPATH}/scripts/s3mirror.sh" "${REPO_SUBPATH}" || exit 1
clone_repository "${REPO_BRANCH}"
sync_pacman

cd "${REPO_BASEPATH}/repository/pacman/${REPO_DIR}" || { panic "Directory pacman/${REPO_DIR} doesn't exist" 1; }

make_pkg -sC

pkgver=$(extract_pkgver_file "PKGBUILD")

/bin/bash "${REPO_BASEPATH}/scripts/update-repo.sh" "${pkgver}" || exit 1
}
