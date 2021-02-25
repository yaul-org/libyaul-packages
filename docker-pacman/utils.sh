panic() {
    printf -- "Error: %s\\n" "${1}" >&2

    exit "${2}"
}

[ "${0##*/}" = "${BASH_SOURCE[0]##*/}" ] && { panic "Do not execute ${0##*/} directly" 1; }
