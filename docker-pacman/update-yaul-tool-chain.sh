#!/bin/bash

set -x

[ -z "$(docker images -q ijacquez/yaul-packages:latest 2>/dev/null)" ] && { printf -- "Image \"ijacquez/yaul-packages\" doesn't exist\n"; exit 1; }

set -e

REPO_BRANCH=${1}
REPO_BRANCH="${REPO_BRANCH:=master}"

# Sanity checks
[ -f "base/.s3cfg" ]      || { printf -- "File \"base/.s3cfg\" does not exist\n" >&2; exit 1; }
[ -f "base/.ssh/id_rsa" ] || { printf -- "File \"base/.ssh/id_rsa\" does not exist\n" >&2; exit 1; }

for os in "linux" "mingw-w64"; do
    docker run -it --rm --privileged -e REPO_OS="${os}" -e REPO_BRANCH="${REPO_BRANCH}" -e REPO_BASEPATH="/home/builder" --mount type=bind,source="${PWD}/base",target=/home/builder ijacquez/yaul-packages:latest ./scripts/package-build-yaul-tool-chain.sh
done
