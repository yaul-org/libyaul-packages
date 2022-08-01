#!/bin/bash
{
source "${REPO_BASEPATH}/scripts/envs.sh"

[ -z "${REPO_PACKAGE}" ]  && { panic "environment variable REPO_PACKAGE MUST be specified" 1; }
[ -z "${REPO_DIR}" ]      && { panic "Environment variable REPO_DIR must be specified" 1; }
[ -z "${REPO_DB}" ]       && { panic "Environment variable REPO_DB must be specified" 1; }
[ -z "${REPO_ROOTPATH}" ] && { panic "Environment variable REPO_ROOTPATH must be specified" 1; }
[ -z "${REPO_SUBPATH}" ]  && { panic "Environment variable REPO_SUBPATH must be specified" 1; }

PKGVER="${1}"

[ ${#} -eq 1 ] || { panic "Usage: ${0##*/} pkgver" 1; }
[ -z "${PKGVER}" ] && { panic "Argument PKGVER is invalid" 1; }

trap '/bin/rm '"${REPO_ROOTPATH}/${REPO_PACKAGE}-${PKGVER}"'-*.pkg.tar.zst' 1

mapfile -t files < <(/usr/bin/find "${REPO_ROOTPATH}" -type f \( -regex "${REPO_PACKAGE}-*-[0-9]+\.pkg\.tar\.zst" -a \! -name "*${PKGVER}*" \))

/bin/rm -f ${files[@]}

if ! [ ${#files[@]} -eq 0 ]; then
    /usr/sbin/repo-remove "${REPO_DB}" "${REPO_PACKAGE}" || { panic "Unable to remove '${file}' from the repository" 1; }
fi

if ! package_exists "${REPO_PACKAGE}" "${PKGVER}"; then
    /bin/cp ${REPO_PACKAGE}-"${PKGVER}"-*.pkg.tar.zst "${REPO_ROOTPATH}"/
    /usr/sbin/repo-add "${REPO_DB}" "${REPO_ROOTPATH}/${REPO_PACKAGE}-${PKGVER}"-*.pkg.tar.zst || { panic "Unable to add file to repository" 1; }

    if ! /usr/bin/git diff --exit-code --name-only PKGBUILD >/dev/null 2>&1; then
        /usr/bin/git commit PKGBUILD -m "Update package version for ${REPO_PACKAGE} ${PKGVER}" || { panic "Unable to commit changes" 1; }
        /usr/bin/git push origin -u master || { panic "Unable to push commits" 1; }
    fi
fi

/bin/bash -x "${REPO_BASEPATH}/scripts/s3sync.sh" "${REPO_SUBPATH}" || exit 1
}
