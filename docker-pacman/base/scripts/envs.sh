[ -z "${REPO_BASEPATH}" ] && { panic "Environment variable REPO_BASEPATH must be specified" 1; }

source "${REPO_BASEPATH}/scripts/utils.sh"

[ "${0##*/}" = "${BASH_SOURCE[0]##*/}" ] && { panic "Do not execute ${0##*/} directly" 1; }

[ -z "${REPO_OS}" ]     && { panic "Environment variable REPO_OS must be specified" 1; }
[ -z "${REPO_BRANCH}" ] && { panic "Environment variable REPO_BRANCH must be specified" 1; }

export REPO_ARCH="x86_64"
export REPO_SUBPATH="${REPO_OS}/${REPO_ARCH}"
export REPO_ROOTPATH="${REPO_BASEPATH}/s3/${REPO_SUBPATH}"
export REPO_DB="${REPO_ROOTPATH}/yaul-${REPO_OS}.db.tar.xz"

set -x
