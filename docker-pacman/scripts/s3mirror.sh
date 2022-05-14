#!/bin/bash
{
source "${HOME}/utils.sh"

/usr/sbin/s3cmd sync --acl-public "s3://packages.yaul.org/${REPO_OS}" "${HOME}/s3/" || { panic "Unable to sync directory" 1; }
}
