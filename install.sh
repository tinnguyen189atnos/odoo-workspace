odoo_default_workspace_dir () {
  printf %s "/opt/odoo"
}

odoo_worksapce_install_dir () {
  if [ -n "$ODOO_WORKSPACE_INSTALL_DIR" ]; then
    echo "$ODOO_WORKSPACE_INSTALL_DIR"
  else
    odoo_default_workspace_dir
  fi
}

odoo_install_odoo () {
  local INSTALL_DIR;
  ODOO_SOURCE_LOCAL="https://raw.githubusercontent.com/tinnguyen189atnos/odoo-workspace/master/odoo.sh"
  INSTALL_DIR="$(odoo_worksapce_install_dir)"
  mkdir -p "$INSTALL_DIR"
  if [ -f "$INSTALL_DIR/odoo.sh" ]; then
    echo "=> odoo is already installed in $INSTALL_DIR, trying to update the script"
  else
    echo "=> Downloading odoo as script to '$INSTALL_DIR'"
  fi
  curl --fail --compressed -q -s "$ODOO_SOURCE_LOCAL" -o "$INSTALL_DIR/odoo.sh"
}

odoo_workspace_dir () {
  if [ -n "$ODOO_WORKSPACE_DIR" ]; then
    echo "$ODOO_WORKSPACE_DIR"
  else
    odoo_default_workspace_dir
  fi
}

odoo_try_profile() {
  if [ -z "${1-}" ] || [ ! -f "${1}" ]; then
    return 1
  fi
  echo "${1}"
}

odoo_detect_profile () {
  local DETECTED_PROFILE
  DETECTED_PROFILE=''

  if [ "${SHELL#*bash}" != "$SHELL" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    fi
  elif [ "${SHELL#*zsh}" != "$SHELL" ]; then
    if [ -f "$HOME/.zshrc" ]; then
      DETECTED_PROFILE="$HOME/.zshrc"
    elif [ -f "$HOME/.zprofile" ]; then
      DETECTED_PROFILE="$HOME/.zprofile"
    fi
  fi

  if [ -z "$DETECTED_PROFILE" ]; then
    for EACH_PROFILE in ".profile" ".bashrc" ".bash_profile" ".zprofile" ".zshrc"
    do
      if DETECTED_PROFILE="$(odoo_try_profile "${HOME}/${EACH_PROFILE}")"; then
        break
      fi
    done
  fi

  if [ -n "$DETECTED_PROFILE" ]; then
    echo "$DETECTED_PROFILE"
  fi
}

odoo_do_install () {
  ODOO_PROFILE="$(odoo_detect_profile)"
  ODOO_WORKSPACE_DIR="$(odoo_workspace_dir)"
  ODOO_CONF_DIR="$(odoo_workspace_dir)/conf.d"
  ODOO_VENV_DIR="$(odoo_workspace_dir)/venv.d"
  ODOO_PROJECT_DIR="$(odoo_workspace_dir)/projects"
  ODOO_JUPYTER_LAB_DIR="$(odoo_workspace_dir)/projects/jupyterlab"
  ODOO_UTILS_DIR="$(odoo_workspace_dir)/odoo_utils"

  # mkdir -p

  odoo_install_odoo
  
  SOURCE_STR="export ODOO_WORKSPACE_DIR="${ODOO_WORKSPACE_DIR}"
export ODOO_CONF_DIR="${ODOO_CONF_DIR}"
export ODOO_VENV_DIR="${ODOO_VENV_DIR}"
export ODOO_PROJECT_DIR="${ODOO_PROJECT_DIR}"
export ODOO_JUPYTER_LAB_DIR="${ODOO_JUPYTER_LAB_DIR}"
export ODOO_UTILS_DIR="${ODOO_UTILS_DIR}"
[ -s \"$ODOO_WORKSPACE_DIR/odoo.sh\" ] && \. \"$ODOO_WORKSPACE_DIR/odoo.sh\"
"
  
  if ! grep -qc '/odoo.sh' "$ODOO_PROFILE"; then
    echo "=> Appending odoo source string to $ODOO_PROFILE"
    printf "${SOURCE_STR}" >> "$ODOO_PROFILE"
  else
    echo "=> odoo source string already in ${ODOO_PROFILE}"
  fi
}

odoo_do_install
