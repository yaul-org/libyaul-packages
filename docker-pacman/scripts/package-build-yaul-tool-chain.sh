#!/bin/bash

set -x

source "${HOME}/envs.sh"

export REPO_PACKAGE="yaul-tool-chain-git"
export REPO_DIR="yaul-tool-chain"

linux_makepkg() {
    # XXX: Kludge: There's an error with wget:
    #              wget: /usr/lib/libc.so.6: version `GLIBC_2.34' not found (required by wget)
    #
    #              This error is fixed by running upgrade_pacman. In order to
    #              avoid this error, we must explicitly install the package
    #              dependencies here, then upgrade. Once this issue is resolved,
    #              we can remove this Wa
    install_pkg make gcc unzip help2man wget
    upgrade_pacman

    make_pkg -sC
}

mingw_w64_makepkg() {
    install_pkg make gcc unzip help2man wget
    upgrade_pacman

    /usr/bin/git clone --recurse-submodules "git@github.com:ijacquez/libyaul-build-scripts" || { panic "Unable to clone repository" 1; }

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

    commit_count=$(git rev-list --count HEAD)
    commit_hash=$(git rev-parse HEAD | sed -r 's/(.{7}).*/\1/')

    popd || exit 1

    cat > PKGBUILD.tmp <<EOF
pkgname=${REPO_PACKAGE}
pkgver=rx.y
pkgrel=1
pkgdesc="Tool-chain for Yaul"
arch=('x86_64')
url="https://yaul.org/"
license=('GPLv3')
depends=("gawk" "sed" "make" "mingw-w64-x86_64-libwinpthread-git")
source=("local://yaul.sh")
sha256sums=('SKIP')
options=('!strip' '!buildflags' 'staticlibs' 'debug')

pkgver() {
  printf -- "r%s.%s" "${commit_count}" "${commit_hash}"
}

package() {
  # It's important that all symbolic links are dereferenced
  /bin/cp -r -L "${PWD}/libyaul-build-scripts/opt" "\${pkgdir}/"

  /usr/bin/mkdir -p "\${pkgdir}/etc/profile.d"
  /usr/bin/install -m 644 "yaul.sh" "\${pkgdir}/etc/profile.d/yaul.sh"
}
EOF

    # Avoid installing any dependencies since this is specifically for mingw-w64
    make_pkg -dC -p PKGBUILD.tmp

    # Extract the pkgver from the generated PKGBUILD and set it in the real
    # PKGBUILD
    pkgver=$(extract_pkgver_file "PKGBUILD.tmp")

    rm -f PKGBUILD.tmp

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
esac

# There might be a better way, but makepkg updates PKGBUILD's pkgver
new_pkgver=$(extract_pkgver_file "PKGBUILD")

/bin/bash "${HOME}/update-repo.sh" "${new_pkgver}" || exit 1
