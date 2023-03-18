[ -z "${BUILD_BASEPATH}" ] && { panic "Environment variable BUILD_BASEPATH must be specified" 1; }

source "${BUILD_BASEPATH}/scripts/utils.sh"

[ "${0##*/}" = "${BASH_SOURCE[0]##*/}" ] && { panic "Do not execute ${0##*/} directly" 1; }

[ -z "${GIT_BRANCH}" ] && { panic "Environment variable GIT_BRANCH must be specified" 1; }

export REPO_ARCH="x86_64"
export REPO_SUBPATH="pacman/${REPO_ARCH}"
export REPO_ROOTPATH="${BUILD_BASEPATH}/s3/${REPO_SUBPATH}"
export REPO_DB="${REPO_ROOTPATH}/yaul.db.tar.xz"

set -x
