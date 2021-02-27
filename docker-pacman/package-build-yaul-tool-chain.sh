#!/bin/bash

set -x

source "${HOME}/envs.sh"

export REPO_PACKAGE="yaul-tool-chain-git"
export REPO_DIR="yaul-tool-chain"

linux_makepkg() {
    make_pkg
}

mingw_w64_makepkg() {
    install_pkg make gcc unzip help2man wget

    /usr/bin/git clone --recursive "git@github.com:ijacquez/libyaul-build-scripts" || { panic "Unable to clone repository" 1; }

    pushd libyaul-build-scripts || exit 1

    /bin/cp sh2eb-elf/host-x86_64-w64-mingw32.config .config || exit 1 
    /bin/sed -i -E 's#^(CT_DEBUG_CT)=.*#\1=n#g' .config
    /bin/sed -i -E 's#^(CT_DEBUG_INTERACTIVE)=.*#\1=n#g' .config
    /bin/sed -i -E 's#^(CT_LOCAL_TARBALLS_DIR)=.*#\1='${PWD}'/tarballs#g' .config
    /bin/sed -i -E 's#^(CT_PREFIX_DIR)=.*$#\1="${CT_PREFIX:-'"${PWD}/opt/tool-chains"'}/${CT_TARGET}"#g' .config
    /bin/sed -i -E 's#^(CT_LOG_TO_FILE)=.*#\1=n#g' .config
    /bin/sed -i -E 's#^(CT_LOG_FILE_COMPRESS)=.*#\1=n#g' .config

    /bin/mkdir -p "${PWD}/tarballs" || exit 1
    /bin/mkdir -p "${PWD}/opt/tool-chains" || exit 1

    pushd crosstool-ng || exit 1
    ./bootstrap || exit 1
    ./configure --enable-local || exit 1
    /usr/bin/make || exit 1
    popd || exit 1

    crosstool-ng/ct-ng build || exit 1

    cat > PKGBUILD <<EOF
pkgname=${REPO_PACKAGE}
pkgver=rx.y
pkgrel=1
pkgdesc="Tool-chain for Yaul"
arch=('x86_64')
url="https://yaul.org/"
depends=("mingw-w64-x86_64-libwinpthread-git")
license=('MIT')
options=('!strip' '!buildflags' 'staticlibs' 'debug')

pkgver() {
  printf -- "r%s.%s" "\$(git rev-list --count HEAD)" "\$(git rev-parse HEAD | sed -r 's/(.{7}).*/\1/')"
}

package() {
  # It's important that all symbolic links are dereferenced
  /bin/cp -r -L "${PWD}/opt" "\${pkgdir}/"
}
EOF

    make_pkg

    # Extract the pkgver from the generated PKGBUILD and set it in the real
    # PKGBUILD
    pkgver=$(extract_pkgver_file "PKGBUILD")

    rm -f PKGBUILD

    /bin/mv "${REPO_PACKAGE}-"${pkgver}"-1-x86_64.pkg.tar.zst" ../

    popd || exit 1

    /bin/sed -E -i 's#^pkgver.*$#pkgver='${pkgver}'#g' PKGBUILD
}

mount_share
clone_repository

# This will catch a bad REPO_OS value
cd "repository/pacman/${REPO_OS}/${REPO_DIR}" || { panic "Directory path pacman/${REPO_OS}/${REPO_DIR} doesn't exist" 1; }

sync_pacman

case "${REPO_OS}" in
    "linux")
        linux_makepkg
        ;;
    "mingw-w64")
        mingw_w64_makepkg
        ;;
    *)
        panic "Unknown REPO_OS value" 1
        ;;
esac

# There might be a better way, but makepkg updates PKGBUILD's pkgver
pkgver=$(extract_pkgver_file "PKGBUILD")

/bin/bash "${HOME}/update-repo.sh" "${pkgver}" || exit 1
