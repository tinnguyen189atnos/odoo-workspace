odoo_get_project_name () {
  local PROJECT_NAME
  if [ -z "${1-}" ] || [[ "${1}" == -* ]]; then
    PROJECT_NAME=$(basename "$PWD")
  else
    PROJECT_NAME=$(basename ${1})
  fi
  echo $PROJECT_NAME
}

odoo_get_project_odoo_bin () {
  local PROJECT_DIR ODOO_BIN
  PROJECT_DIR="$ODOO_PROJECT_DIR/${1:-$(odoo_get_project_name $@)}"
  
  # If not PROJECT_WORKSPACE, return
  if [[ ! -d "$PROJECT_DIR" ]]; then
      return
  fi
  
  ODOO_BIN="$PROJECT_DIR/odoo-bin"
  if [[ -f "$PROJECT_DIR/odoo/odoo-bin" ]]; then
      ODOO_BIN="$PROJECT_DIR/odoo/odoo-bin"
  fi
  # If ODOO_BIN does not exist, return
  if [[ ! -f "$ODOO_BIN" ]]; then
      return
  fi

  echo $ODOO_BIN
}

odoo_get_project_venv () {
  echo "$ODOO_VENV_DIR/${1:-$(odoo_get_project_name $@)}"
}

odoo_get_project_conf () {
  echo "$ODOO_CONF_DIR/${1:-$(odoo_get_project_name $@)}"
}

odoorc () {
  odoo_get_project_conf $@
}

__odoo () {
  PROJECT_NAME=$(odoo_get_project_name $@)
  ODOO_BIN=$(odoo_get_project_odoo_bin $PROJECT_NAME)
  PROJECT_VENV=$(odoo_get_project_venv $PROJECT_NAME)
  ODOO_CONFIG=$(odoo_get_project_conf $PROJECT_NAME)
  ERROR=""
  if [ -z "$PROJECT_VENV" ]; then
      ERROR="Project venv not found"
      return
  fi
  
  if [ -z "$ODOO_BIN" ]; then
      ERROR="odoo-bin not found"
      return
  fi
  
  if [ -z "$ODOO_CONFIG" ]; then
      ERROR="Odoo config not found"
      return
  fi
}

odoo () {
  local PROJECT_NAME ODOO_BIN PROJECT_VENV ODOO_CONF ERROR
  __odoo $@
  if [ ! -z "$ERROR" ];then
    echo $ERROR
    return
  fi
  if [ "$1" = "$PROJECT_NAME" ]; then
    shift
  fi
  "$PROJECT_VENV/bin/python" "$ODOO_BIN" -c "$ODOO_CONFIG" $@
}

odoo-init () {
  local PROJECT_NAME ODOO_BIN PROJECT_VENV ODOO_CONF ERROR
  __odoo $@
  if [ ! -z "$ERROR" ];then
    echo $ERROR
    return
  fi
  if [ "$1" = "$PROJECT_NAME" ]; then
    shift
  fi
  ODOO_RC="$ODOO_CONFIG" PYTHONPATH="$PYTHONPATH:$(dirname $ODOO_BIN):/opt/odoo/odoo_utils" "$PROJECT_VENV/bin/python" "$ODOO_CONFIG.py" -c "$ODOO_CONFIG" $@
}

odoo-shell () {
  local PROJECT_NAME ODOO_BIN PROJECT_VENV ODOO_CONF ERROR
  __odoo $@
  if [ ! -z "$ERROR" ];then
    echo $ERROR
    return
  fi
  if [ "$1" = "$PROJECT_NAME" ]; then
    shift
  fi
  PYTHONPATH="$PYTHONPATH:$ODOO_UTILS_DIR" "$PROJECT_VENV/bin/python" "$ODOO_BIN" shell -c "$ODOO_CONFIG" --no-http $@
}

odoo-lab () {
  local PROJECT_NAME ODOO_BIN PROJECT_VENV ODOO_CONF ERROR
  __odoo $@
  if [ ! -z "$ERROR" ];then
    echo $ERROR
    return
  fi
  if [ "$1" = "$PROJECT_NAME" ]; then
    shift
  fi
  source "$PROJECT_VENV/bin/activate"
  PYTHONPATH="$PYTHONPATH:$(dirname $ODOO_BIN):$ODOO_UTILS_DIR" ODOO_RC="$ODOO_CONFIG" "$ODOO_VENV_DIR/jupyterlab/bin/python" -m jupyter lab --no-browser "$ODOO_JUPYTER_LAB_DIR"
}
