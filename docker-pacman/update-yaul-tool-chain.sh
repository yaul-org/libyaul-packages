#!/bin/bash

set -x

[ -z "$(docker images -q yaul-packages:latest 2>/dev/null)" ] && { printf -- "Image \"yaul-packages\" doesn't exist\n"; exit 1; }

set -e

for os in "linux" "mingw-w64"; do
    docker run -it --rm --privileged -e REPO_OS="${os}" yaul-packages:latest ./package-build-yaul-tool-chain.sh
done
