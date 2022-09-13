#!/bin/bash
# ========== Ar-Ray-code Linux Desktop app template ========== #
# License : MIT
# Author : Ar-Ray-code
# Website : https://github.com/Ar-Ray-code
# ========================================================= #


# Argument -----------------------------------------------------------------
# https://qiita.com/s-wakaba/items/5939906417d0f98fcb10
args_source="$(mktemp -u)"
PROGNAME="$0" ARGS_SOURCE="${args_source}" python - "$@" <<'__EOF__' || exit $?
from argparse import ArgumentParser
from os import environ
p = ArgumentParser(prog=environ['PROGNAME'])

p.add_argument('--entry_bash', '-e', type=str, help="Entry point bash file")
p.add_argument('--icon', '-i', type=str, help="Icon path")
p.add_argument('--terminal', '-t', action='store_true', help="Open terminal flag (if enabled, terminal true)")
p.add_argument('--uninstall', '-u', action='store_true', help="Uninstall flag")
p.add_argument('--bin_path', '-b', type=str, help="Install bin path (default: /usr/local/bin/)")
p.add_argument('--install_path', '-p', type=str, help="Install path (default: /home/USER/.app/)")

def py2bash(v):
    if type(v) is list:
        return '('+' '.join(map(py2bash, v))+')'
    elif type(v) is bool:
        return f'/bin/{repr(v).lower()}'
    else:
        return "$'"+''.join(f'\\{c:03o}' for c in str(v).encode())+"'"
a = p.parse_args()
with open(environ['ARGS_SOURCE'], 'x') as fp:
    for k, v in vars(a).items():
        if v is None: continue
        print(f'{k}={py2bash(v)}', file=fp)
__EOF__
test -e "${args_source}" || exit 0 # printing --help
source "${args_source}"
unset PROGNAME args_source
# ---------------------------------------------------------------------------

# icon found (not \n only)
ICON_PATH=`realpath ${icon}`
ENTRY_POINT_PATH=`realpath ${entry_bash}`
INSTALL_PATH=`realpath ${install_path}`

APP_BIN_PATH=${bin_path}

SCRIPT_DIR=`dirname ${ENTRY_POINT_PATH}`
SCRIPT_USER=`stat -c %U ${SCRIPT_DIR}`

if [ -z ${APP_BIN_PATH} ]; then
    APP_BIN_PATH="/usr/local/bin"
fi

if [ -z ${INSTALL_PATH} ]; then
    INSTALL_PATH=/home/${SCRIPT_USER}/".app"
fi

if [ -z ${ICON_PATH} ]; then
    ICON_PATH=${SCRIPT_DIR}/icon.png
fi

if [ "${uninstall}" = "/bin/true" ]; then
    UNINSTALL_FLAG="uninstall"
fi

if [ "${terminal}" = "/bin/true" ]; then
    TERMINAL_FLAG="true"
else
    TERMINAL_FLAG="false"
fi


# automatic setting env -----------------------------------------
ENTRYPOINT_BASENAME=`basename ${ENTRY_POINT_PATH}`
APP_NAME=${ENTRYPOINT_BASENAME%.*}
APPLICATION_DIR=${INSTALL_PATH}/${APP_NAME}

APPLICATION_ENTRY_DIR=/home/${SCRIPT_USER}/.local/share/applications/
SHORTCUT_LINK_ENTRY_POINT=/home/${SCRIPT_USER}/Desktop/${APP_NAME}.desktop
ENTRY_POINT=${APPLICATION_DIR}/${ENTRYPOINT_BASENAME}
DOT_DESKTOP=${APPLICATION_ENTRY_DIR}${APP_NAME}.desktop

## Exit ---------------------------------------------------
# permission check ----------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

if [ "$(uname)" != 'Linux' ]; then
    echo "This script is only for Linux"
    exit 1
fi

# arg : uninstall ------------------------------------------------
if [ "${UNINSTALL_FLAG}" = "uninstall" ]; then
    echo "Uninstalling..."
    rm -rf ${APPLICATION_ENTRY_DIR} ${SHORTCUT_LINK_ENTRY_POINT} ${APPLICATION_DIR}
    echo "Uninstalled."
    exit 0
fi

# check Desktop folder exists ------------------------------
if [ ! -d /home/${SCRIPT_USER}/Desktop ]; then
    echo "Desktop folder (/home/${SCRIPT_USER}/Desktop) not found."
    exit 1
fi

echo ""
echo "==================================================="
echo "        APP Name : ${APP_NAME}"
echo "---------------------------------------------------"
echo "ICON_PATH: ${ICON_PATH} -> ${APPLICATION_DIR}/`basename ${ICON_PATH}`"
echo "ENTRY_POINT_PATH: ${ENTRY_POINT_PATH}"
echo "APP_BIN_PATH: ${APP_BIN_PATH}"
echo ""
echo "--------- Desktop entry ---------------------------"
echo ".desktop app   : ${DOT_DESKTOP}"
echo "~/Desktop app  : ${SHORTCUT_LINK_ENTRY_POINT}"
echo "CLI entry point: ${ENTRY_POINT} -> ${APP_BIN_PATH}/${APP_NAME} (symlink)"
echo ""
echo "COPY: ${SCRIPT_DIR}/* -> ${APPLICATION_DIR}/*"
echo ""
echo "-------------- flags ------------------------------"
echo "UNINSTALL_FLAG: ${UNINSTALL_FLAG}"
echo "TERMINAL_FLAG: ${TERMINAL_FLAG}"
echo "==================================================="
echo ""

# if not found
if [ ! -f ${ICON_PATH} ]; then
    echo "===== Icon not found ====="
    PAPER_PNG="https://1.bp.blogspot.com/-z-Fj7jStrFA/X9w89_xgmhI/AAAAAAABc_8/AuabFNLnpLQsrsnptghJHI2NwRANjsR1gCNcBGAsYHQ/s593/document_paper_mekure.png"
    wget -O ${ICON_PATH} ${PAPER_PNG}
    echo "Downloaded icon. Please replace it if you want setting your own icon."
fi
if [ ! -f ${ENTRY_POINT_PATH} ]; then
    echo "===== Entry point not found ====="
    echo "Please check ENTRY_POINT_PATH variable in install.bash"
    exit 1
fi

# create application dir and copy to it ------------------------------
mkdir -p ${APPLICATION_ENTRY_DIR} ${APPLICATION_DIR}
cp -r ${SCRIPT_DIR}/* ${APPLICATION_DIR}/

# create simbolic link (if it exists, remove and recreate) ------------------------------
if [ -f ${APP_BIN_PATH}/${APP_NAME} ]; then
    sudo unlink ${APP_BIN_PATH}/${APP_NAME}
fi
chmod +x ${ENTRY_POINT}
sudo ln -s ${ENTRY_POINT} ${APP_BIN_PATH}/${APP_NAME}

rm ${DOT_DESKTOP}
# create .desktop file ------------------------------------
echo "#!/usr/bin/env xdg-open"                          >> ${DOT_DESKTOP}
echo "[Desktop Entry]"                                  >> ${DOT_DESKTOP}
echo "Version=1.0"                                      >> ${DOT_DESKTOP}
echo "Type=Application"                                 >> ${DOT_DESKTOP}
echo "Encoding=UTF-8"                                   >> ${DOT_DESKTOP}
echo "Categories=Application;"                          >> ${DOT_DESKTOP}
echo "Terminal=${TERMINAL_FLAG}"                        >> ${DOT_DESKTOP}
echo "Name=${APP_NAME}"                                 >> ${DOT_DESKTOP}
echo "Comment=${APP_NAME} app"                          >> ${DOT_DESKTOP}
echo "Icon=${APPLICATION_DIR}/`basename ${ICON_PATH}`"  >> ${DOT_DESKTOP}
echo "Exec=${ENTRY_POINT}"                              >> ${DOT_DESKTOP}
echo "Path=${APPLICATION_DIR}/"                         >> ${DOT_DESKTOP}


cp ${DOT_DESKTOP} ${SHORTCUT_LINK_ENTRY_POINT}

# allow launching
chmod a+x ${SHORTCUT_LINK_ENTRY_POINT} ${DOT_DESKTOP}
gio set ${SHORTCUT_LINK_ENTRY_POINT} metadata::trusted yes
echo ""
echo "Installed"
