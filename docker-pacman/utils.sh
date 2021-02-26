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
    sudo /usr/sbin/pacman -Syy || { panic "Unable to sync" 1; }
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
make_pkg() {
    /usr/sbin/makepkg -sC --noconfirm || { panic "Unable to build package" 1; }
}

# Extract package version (pkgver variable) from a given file.
#
# Error checking is performed.
#
# $1 - The file to read
extract_pkgver_file() {
    local _file="${1}"

    /bin/sed -n -E 's/^pkgver=(.*)$/\1/pg' "${_file}" || { panic "Unable to extract package version from ${_file}" 1; } 
}

[ "${0##*/}" = "${BASH_SOURCE[0]##*/}" ] && { panic "Do not execute ${0##*/} directly" 1; }
