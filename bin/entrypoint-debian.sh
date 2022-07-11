#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : 202202021753-git
# @Author        : Jason Hempstead
# @Contact       : jason@casjaysdev.com
# @License       : WTFPL
# @ReadME        : entrypoint.sh --help
# @Copyright     : Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @Created       : Wednesday, Feb 02, 2022 17:53 EST
# @File          : entrypoint.sh
# @Description   :
# @TODO          :
# @Other         :
# @Resource      :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="$(basename "$0")"
VERSION="202202021753-git"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"
SRC_DIR="${BASH_SOURCE%/*}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
if [[ "$1" == "--debug" ]]; then shift 1 && set -xo pipefail && export SCRIPT_OPTS="--debug" && export _DEBUG="on"; fi
trap 'exit $?' HUP INT QUIT TERM EXIT
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__exec_bash() { [ -n "$1" ] && exec /bin/bash -c "${@:-bash}" || exec /bin/bash || exit 10; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
CONFIG_DIR="$(ls /config/ 2>/dev/null | grep '^' || false)"
export TZ="${TZ:-America/New_York}"
export HOSTNAME="${HOSTNAME:-casjaysdev-alpine}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -n "${TZ}" ] && echo "${TZ}" >/etc/timezone
[ -n "${HOSTNAME}" ] && echo "${HOSTNAME}" >/etc/hostname
[ -n "${HOSTNAME}" ] && echo "127.0.0.1 $HOSTNAME localhost" >/etc/hosts
[ -f "/usr/share/zoneinfo/${TZ}" ] && ln -sf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[[ -d "/config/" ]] && rm -Rf "/config/.gitkeep"
[[ -d "/data/" ]] && rm -Rf "/data/.gitkeep"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -n "$CONFIG_DIR" ]; then
  for config in $CONFIG_DIR; do
    if [ -d "/config/$config" ]; then
      cp -Rf "/config/$config/." "/etc/$config/"
    elif [ -f "/config/$config" ]; then
      cp -Rf "/config/$config" "/etc/$config"
    fi
  done
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
case "$1" in
healthcheck)
  echo "$(uname -s) $(uname -m) is OK"
  exit $?
  ;;
sh | bash | shell | */bin/sh | */bin/bash)
  shift 1
  __exec_bash "$@"
  exit $?
  ;;
*)
  __exec_bash "$@"
  exit $?
  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit $?
