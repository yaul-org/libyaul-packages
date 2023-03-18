#!/bin/bash
{
source "${BUILD_BASEPATH}/scripts/envs.sh" || exit 1

[ ${#} -eq 1 ] || { panic "Usage: ${0##*/} path" 1; }

# Strip leading and trailing '/'s from the sync path
SYNC_PATH=$(echo "${1}" | /bin/sed -E 's/^[\/]+//g;s/[\/]+$//g' 2>/dev/null)

[ -z "${SYNC_PATH}" ] && { panic "Invalid path argument" 1; }

/usr/sbin/s3cmd --exclude=.gitignore sync --follow-symlinks --delete-removed --acl-public "${BUILD_BASEPATH}/s3/${SYNC_PATH}/" "s3://packages.yaul.org/${SYNC_PATH}/" || { panic "Unable to sync directory" 1; }
}
