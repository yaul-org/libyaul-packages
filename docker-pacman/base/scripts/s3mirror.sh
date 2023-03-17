#!/bin/bash
{
source "${BUILD_BASEPATH}/scripts/utils.sh"

[ -d "${BUILD_BASEPATH}/s3" ] || { panic "Directory path ${BUILD_BASEPATH}/s3 doesn't exist" 1; }

/usr/sbin/s3cmd --exclude=.gitignore sync --acl-public "s3://packages.yaul.org/pacman" "${BUILD_BASEPATH}/s3/" || { panic "Unable to sync directory" 1; }
}
