# Panic.
#
# $1 - The error message
# $2 - The exit code
panic() {
    printf -- "Error: %s\\n" "${1}" >&2

    exit "${2}"
}

# Mount the share where the local Pacman repository is stored.
#
# Error checking is performed.
mount_share() {
    /bin/mount "${REPO_ROOT_PATH}" || { panic "Unable to mount repository mount point" 1; }
}

# Clone the libyaul-packages repo.
#
# Error checking is performed.
clone_repository() {
    /usr/bin/git clone "git@github.com:ijacquez/libyaul-packages" repository || { panic "Unable to clone repository" 1; }
}

# Sync Pacman repositories
#
# Error checking is performed.
sync_pacman() {
    sudo /usr/sbin/pacman -Syyu || { panic "Unable to sync" 1; }
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

# Determine if the package exists in the repo.
#
# $1 - The package name, $pkgname
# $2 - The package version, $pkgver
package_exists() {
    local _package="${1}"
    local _pkgver="${2}"
    # XXX: $pkgrel is hard coded
    local _pkgrel=1

    [ -z "${_package}" ] && { panic "package_exists: Invalid argument \$1" 1; }
    [ -z "${_pkgver}" ]  && { panic "package_exists: Invalid argument \$2" 1; }

    [ -f "${REPO_PATH}/${_package}-${_pkgver}-${_pkgrel}-${REPO_ARCH}.pkg.tar.zst" ]
}

[ "${0##*/}" = "${BASH_SOURCE[0]##*/}" ] && { panic "Do not execute ${0##*/} directly" 1; }
