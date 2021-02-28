#!/bin/bash
{
source "${HOME}/utils.sh"

PATH=$(echo "${1}" | /bin/sed -E 's/^[\/]+//g;s/[\/]+$//g' 2>/dev/null)

[ ${#} -eq 1 ] || { panic "Usage: ${0##*/} path" 1; }
[ -n "${PATH}" ] || { panic "Invalid path argument" 1; }

/usr/sbin/s3cmd sync --follow-symlinks --delete-removed --acl-public "${HOME}/SMB/${PATH}/" "s3://packages.yaul.org/${PATH}/" || { panic "Unable to sync directory" 1; }
}
