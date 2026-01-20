#!/usr/bin/env bash
# ============================================================
# VERSÃO DE TESTE - Para testar antes de submeter PR
# Aponte para seu fork ao invés do repositório oficial
# ============================================================

# Use seu fork para testes (mude para community-scripts após aprovação do PR)
GITHUB_USER="nicolasaigner"
GITHUB_BRANCH="main"

source <(curl -fsSL https://raw.githubusercontent.com/${GITHUB_USER}/ProxmoxVE/${GITHUB_BRANCH}/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: nicolasaigner
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/jokob-sk/NetAlertX

# App Default Values
APP="NetAlertX"
var_tags="${var_tags:-network;monitoring}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /app ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Stopping Services"
  systemctl stop netalertx
  msg_ok "Stopped Services"

  msg_info "Updating NetAlertX"
  cd /app || exit
  $STD git fetch origin
  $STD git reset --hard origin/main
  source /opt/myenv/bin/activate
  $STD pip install -r /app/install/proxmox/requirements.txt
  msg_ok "Updated NetAlertX"

  msg_info "Starting Services"
  systemctl start netalertx
  msg_ok "Started Services"

  msg_ok "Updated successfully!"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:20211${CL}"
