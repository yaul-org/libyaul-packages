#!/bin/bash
{
source "${REPO_BASEPATH}/scripts/utils.sh"

[ -d "${REPO_BASEPATH}/s3" ] || { panic "Directory path ${REPO_BASEPATH}/s3 doesn't exist" 1; }

/usr/sbin/s3cmd sync --acl-public "s3://packages.yaul.org/pacman" "${REPO_BASEPATH}/s3/" || { panic "Unable to sync directory" 1; }
}
