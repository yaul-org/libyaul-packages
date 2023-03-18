#!/bin/bash

[ -z "$(docker images -q ijacquez/yaul-packages:latest 2>/dev/null)" ] && { printf -- "Image \"ijacquez/yaul-packages\" doesn't exist\n"; exit 1; }

[ ${#} -eq 1 ] || { printf -- "Usage: ${0##*/} package-name\n" 2>&1; exit 1; }

PKGNAME="${1}"
GIT_BRANCH="${GIT_BRANCH:=master}"

# Sanity checks
[ -f "base/.s3cfg" ]      || { printf -- "File \"base/.s3cfg\" does not exist\n" >&2; exit 1; }
[ -f "base/.ssh/id_rsa" ] || { printf -- "File \"base/.ssh/id_rsa\" does not exist\n" >&2; exit 1; }

SCRIPT_RELPATH="scripts/package-build-${PKGNAME}.sh"

[ -f "base/${SCRIPT_RELPATH}" ] || { printf -- "Package \"%s\" does not exist\n" "${PKGNAME}" >&2; exit 1; }

docker run -it --rm --privileged -e GIT_BRANCH="${GIT_BRANCH}" -e BUILD_BASEPATH="/home/builder" --mount type=bind,source="${PWD}/base",target=/home/builder ijacquez/yaul-packages:latest "${SCRIPT_RELPATH}"
