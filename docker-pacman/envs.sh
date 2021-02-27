source "${HOME}/utils.sh"

[ "${0##*/}" = "${BASH_SOURCE[0]##*/}" ] && { panic "Do not execute ${0##*/} directly" 1; }

[ -z "${REPO_OS}" ]        && { panic "Environment variable REPO_OS must be specified" 1; }
[ -z "${REPO_ROOT_PATH}" ] && { panic "Environment variable REPO_ROOT_PATH must be specified" 1; }

export REPO_ARCH="x86_64"
export REPO_SUBPATH="${REPO_OS}/${REPO_ARCH}"
export REPO_PATH="${REPO_ROOT_PATH}/${REPO_SUBPATH}"
export REPO_DB="${REPO_PATH}/yaul-${REPO_OS}.db.tar.xz"

set -x
