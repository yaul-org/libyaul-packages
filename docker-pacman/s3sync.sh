#!/bin/bash

panic () {
    printf -- "Error: %s\\n" "${1}" >&2

    exit "${2}"
}

PATH=$(echo "${1}" | sed -E 's/^[\/]+//g;s/[\/]+$//g')

[ -n "${PATH}" ] || { panic "Invalid path argument\n" 1; }

/usr/sbin/s3cmd sync --follow-symlinks --delete-removed --acl-public "${HOME}/SMB/${PATH}/" "s3://packages.yaul.org/${PATH}/" || { panic "Unable to sync directory\\n" 1; }
