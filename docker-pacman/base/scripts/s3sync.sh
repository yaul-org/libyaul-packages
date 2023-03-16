#!/bin/bash
{
source "${REPO_BASEPATH}/scripts/utils.sh"

SYNC_PATH=$(echo "${1}" | /bin/sed -E 's/^[\/]+//g;s/[\/]+$//g' 2>/dev/null)

[ ${#} -eq 1 ] || { panic "Usage: ${0##*/} path" 1; }
[ -n "${SYNC_PATH}" ] || { panic "Invalid path argument" 1; }

/usr/sbin/s3cmd sync --follow-symlinks --delete-removed --acl-public "${REPO_BASEPATH}/s3/${SYNC_PATH}/" "s3://packages.yaul.org/${SYNC_PATH}/" || { panic "Unable to sync directory" 1; }
}
