#!/bin/bash
{
source "${REPO_BASEPATH}/scripts/envs.sh"

PKGNAME="${1}"
PKGVER="${2}"
PKGREL="${3}"

[ ${#} -eq 3 ] || { panic "Usage: ${0##*/} package pkgver" 1; }

[ -z "${PKGNAME}" ] && { panic "Argument PKGNAME is invalid" 1; }
[ -z "${PKGVER}" ]  && { panic "Argument PKGVER is invalid" 1; }
[ -z "${PKGREL}" ]  && { panic "Argument PKGREL is invalid" 1; }

trap '/bin/rm '"${REPO_ROOTPATH}/${PKGNAME}-${PKGVER}-${PKGREL}"'-*.pkg.tar.zst' 1

mapfile -t files < <(/usr/bin/find "${REPO_ROOTPATH}" -type f \( -regex "${PKGNAME}-*-[0-9]+\.pkg\.tar\.zst" -a \! -name "*${PKGVER}*" \))

/bin/rm -f ${files[@]}

if ! [ ${#files[@]} -eq 0 ]; then
    /usr/sbin/repo-remove "${REPO_DB}" "${PKGNAME}" || { panic "Unable to remove ${PKGNAME} from the repository" 1; }
fi

if ! package_exists "${PKGNAME}" "${PKGVER}" "${PKGREL}"; then
    /bin/cp ${PKGNAME}-"${PKGVER}-${PKGREL}"-*.pkg.tar.zst "${REPO_ROOTPATH}"/
    /usr/sbin/repo-add "${REPO_DB}" "${REPO_ROOTPATH}/${PKGNAME}-${PKGVER}-${PKGREL}"-*.pkg.tar.zst || { panic "Unable to add file to repository" 1; }

    if ! /usr/bin/git diff --exit-code --name-only PKGBUILD >/dev/null 2>&1; then
        /usr/bin/git commit PKGBUILD -m "Update package version for ${PKGNAME} ${PKGVER}-${PKGREL}" || { panic "Unable to commit changes" 1; }
        /usr/bin/git push origin -u master || { panic "Unable to push commits" 1; }
    fi
fi

/bin/bash -x "${REPO_BASEPATH}/scripts/s3sync.sh" "${REPO_SUBPATH}" || exit 1
}
