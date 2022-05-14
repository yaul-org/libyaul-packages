#!/bin/bash
{
source "${HOME}/envs.sh"

export REPO_PACKAGE="yaul-examples-git"
export REPO_DIR="yaul-examples"

/bin/bash -x "${HOME}/s3mirror.sh" "${REPO_SUBPATH}" || exit 1
clone_repository
sync_pacman

cd "repository/pacman/${REPO_DIR}" || { panic "Directory pacman/${REPO_DIR} doesn't exist" 1; }

make_pkg -sC

pkgver=$(extract_pkgver_file "PKGBUILD")

/bin/bash "${HOME}/update-repo.sh" "${pkgver}" || exit 1
}
