#!/bin/bash
{
source "${BUILD_BASEPATH}/scripts/envs.sh" || exit 1

[ ${#} -eq 3 ] || { panic "Usage: ${0##*/} package pkgver" 1; }

PKGNAME="${1}"
PKGVER="${2}"
PKGREL="${3}"
PKGFILE="${PKGNAME}-${PKGVER}-${PKGREL}-${REPO_ARCH}.pkg.tar.zst"

[ -z "${PKGNAME}" ] && { panic "Argument PKGNAME is invalid" 1; }
[ -z "${PKGVER}" ]  && { panic "Argument PKGVER is invalid" 1; }
[ -z "${PKGREL}" ]  && { panic "Argument PKGREL is invalid" 1; }

trap '/bin/rm '"${REPO_ROOTPATH}/${PKGFILE}"'' 1

[ -f "${PKGFILE}" ] || { panic "Package file ${PKGFILE} does not exist in ${PWD}" 1; }

/bin/rm -f "${REPO_ROOTPATH}/${PKGFILE}"
/bin/cp "${PKGFILE}" "${REPO_ROOTPATH}"/ || { panic "Unable to copy package file to repository" 1; }

# Add package to repo. Only add packages that are not already in the database,
# remove old package file from disk after updating database, and do not add
# package to database if a newer version is already present
/usr/sbin/repo-add -n -R -p "${REPO_DB}" "${REPO_ROOTPATH}/${PKGFILE}" || { panic "Unable to add package file to repository" 1; }

# Commit changes to PKGBUILD. This happens when pkgver is updated
if ! /usr/bin/git diff --exit-code --name-only PKGBUILD >/dev/null 2>&1; then
    /usr/bin/git commit PKGBUILD -m "Update package version for ${PKGNAME} ${PKGVER}-${PKGREL}" || { panic "Unable to commit changes" 1; }
    /usr/bin/git push origin -u "${GIT_BRANCH}" || { panic "Unable to push commits" 1; }
fi
}
