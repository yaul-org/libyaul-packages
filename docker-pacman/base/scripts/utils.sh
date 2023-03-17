# Panic.
#
# $1 - The error message
# $2 - The exit code
panic() {
    printf -- "Error: %s\\n" "${1}" >&2

    exit "${2}"
}

# Clone the libyaul-packages repo.
#
# Error checking is performed.
# $1 - The branch
clone_repository() {
    local _branch="${1}"

    cd repository >/dev/null 2>&1 || /usr/bin/git clone -b "${_branch}" "git@github.com:ijacquez/libyaul-packages" repository || { panic "Unable to clone repository" 1; }
    cd repository >/dev/null 2>&1 || true
    git fetch origin -p
    git checkout -B "${_branch}"
    git reset --hard origin/"${_branch}"
    git clean -f -d -x
}

# Sync Pacman repositories.
#
# Error checking is performed.
sync_pacman() {
    sudo /usr/sbin/pacman -Syy || { panic "Unable to sync" 1; }
}

# Upgrade Pacman repositories
#
# Error checking is performed.
upgrade_pacman() {
    sudo /usr/sbin/pacman -Syyu --noconfirm || { panic "Unable to upgrade" 1; }
}

# Install package.
#
# Error checking is performed.
#
# $@ - List of packages to install
install_pkg() {
    sudo /usr/sbin/pacman -S --noconfirm ${@} || { panic "Unable to install package(s) ${@}" 1; }
}

# Make package.
#
# Error checking is performed.
#
# $@ - Options to makepkg
make_pkg() {
    /usr/sbin/makepkg ${@} --noconfirm || { panic "Unable to build package" 1; }
}

# Extract package version (pkgver variable) from a given file.
#
# Error checking is performed.
#
# $1 - The file to read
extract_pkgver_file() {
    local _file="${1}"

    [ -z "${_file}" ] && { panic "extract_pkgver_file: Invalid argument \$1" 1; }

    /bin/sed -n -E 's/^pkgver=(.*)$/\1/pg' "${_file}" || { panic "Unable to extract package version from ${_file}" 1; }
}

# Extract package release (pkgrel variable) from a given file.
#
# Error checking is performed.
#
# $1 - The file to read
extract_pkgrel_file() {
    local _file="${1}"

    [ -z "${_file}" ] && { panic "extract_pkgrel_file: Invalid argument \$1" 1; }

    /bin/sed -n -E 's/^pkgrel=(.*)$/\1/pg' "${_file}" || { panic "Unable to extract package release from ${_file}" 1; }
}

# Determine if the package exists in the repo.
#
# $1 - The package name, $pkgname
# $2 - The package version, $pkgver
# $3 - The package release, $pkgrel
package_exists() {
    local _package="${1}"
    local _pkgver="${2}"
    local _pkgrel="${3}"

    [ -z "${_package}" ] && { panic "package_exists: Invalid package argument \$1" 1; }
    [ -z "${_pkgver}" ]  && { panic "package_exists: Invalid pkgver argument \$2" 1; }
    [ -z "${_pkgrel}" ]  && { panic "package_exists: Invalid pkgrel argument \$3" 1; }

    [ -f "${REPO_ROOTPATH}/${_package}-${_pkgver}-${_pkgrel}-${REPO_ARCH}.pkg.tar.zst" ]
}

# Mirror S3 bucket.
mirror_repo() {
    /bin/bash "${BUILD_BASEPATH}/scripts/s3mirror.sh" || exit 1
}

# Update Pacman repo.
#
# Expects the package file to exist in the current directory.
#
# $1 - The package name
# $2 - The package version, $pkgver
# $3 - The package release, $pkgrel
update_repo() {
    local _pkgname="${1}"
    local _pkgver="${2}"
    local _pkgrel="${3}"

    [ -z "${_pkgname}" ] && { panic "update_repo: Invalid argument \$1" 1; }
    [ -z "${_pkgver}" ]  && { panic "update_repo: Invalid argument \$2" 1; }
    [ -z "${_pkgrel}" ]  && { panic "update_repo: Invalid argument \$3" 1; }

    /bin/bash "${BUILD_BASEPATH}/scripts/update-repo.sh" "${_pkgname}" "${_pkgver}" "${_pkgrel}" || exit 1
}

[ "${0##*/}" = "${BASH_SOURCE[0]##*/}" ] && { panic "Do not execute ${0##*/} directly" 1; }
