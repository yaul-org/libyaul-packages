TOOL_CHAIN_ROOT="/opt/tool-chains/sh2eb-elf"
[ -d "${TOOL_CHAIN_ROOT}/bin" ] && PATH="${PATH}:${TOOL_CHAIN_ROOT}/bin"

[ -d "/opt/emulators/mednafen" ] && PATH="${PATH}:/opt/emulators/mednafen"
[ -d "/opt/emulators/kronos" ] && PATH="${PATH}:/opt/emulators/kronos"

export PATH

YAUL_ENV_IN="${TOOL_CHAIN_ROOT}/yaul.env.in"
YAUL_ENV="${HOME}/.yaul.env"

if [ -f "${YAUL_ENV_IN}" ]; then
    ! [ -f "${YAUL_ENV}" ] && cp "${YAUL_ENV_IN}" "${YAUL_ENV}"
    . "${YAUL_ENV}"
fi
