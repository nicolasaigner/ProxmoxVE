#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/nicolasaigner/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: nicolasaigner
# License: MIT | https://github.com/nicolasaigner/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/nicolasaigner/mcp-hub

APP="MCP-Hub"
var_tags="${var_tags:-ai;mcp}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-32}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/mcp-hub ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  CURRENT_VERSION=$(node -p "require('/opt/mcp-hub/package.json').version" 2>/dev/null || echo "unknown")

  msg_info "Checking for updates (nicolasaigner/mcp-hub)"
  cd /opt/mcp-hub || exit
  UPSTREAM=$(git ls-remote origin HEAD 2>/dev/null | cut -f1)
  LOCAL=$(git rev-parse HEAD 2>/dev/null)

  if [[ "$UPSTREAM" == "$LOCAL" ]]; then
    msg_ok "Already up to date (${CURRENT_VERSION})"
    exit
  fi

  msg_info "Stopping Service"
  systemctl stop mcphub
  msg_ok "Stopped Service"

  msg_info "Backing up Configuration"
  cp /opt/mcp-hub/global.json /tmp/mcphub_global.json.bak 2>/dev/null || true
  msg_ok "Backed up Configuration"

  msg_info "Pulling updates"
  $STD git pull --rebase origin main
  msg_ok "Pulled updates"

  msg_info "Building MCP Hub"
  $STD npm install
  $STD npm run build
  $STD npm prune --omit=dev
  NEW_VERSION=$(node -p "require('/opt/mcp-hub/package.json').version" 2>/dev/null || echo "unknown")
  msg_ok "Built MCP Hub ${NEW_VERSION}"

  msg_info "Restoring Configuration"
  cp /tmp/mcphub_global.json.bak /opt/mcp-hub/global.json 2>/dev/null || true
  rm -f /tmp/mcphub_global.json.bak
  msg_ok "Restored Configuration"

  msg_info "Starting Service"
  systemctl start mcphub
  msg_ok "Started Service"
  msg_ok "Updated successfully! ${CURRENT_VERSION} → ${NEW_VERSION}"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:37373${CL}"
