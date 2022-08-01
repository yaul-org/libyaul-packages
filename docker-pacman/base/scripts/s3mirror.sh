#!/bin/bash
{
source "${REPO_BASEPATH}/scripts/utils.sh"

/usr/sbin/s3cmd sync --acl-public "s3://packages.yaul.org/${REPO_OS}" "${REPO_BASEPATH}/s3/" || { panic "Unable to sync directory" 1; }
}
