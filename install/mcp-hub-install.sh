#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: nicolasaigner
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/nicolasaigner/mcp-hub

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  make \
  g++
msg_ok "Installed Dependencies"

NODE_VERSION="22" setup_nodejs

fetch_and_deploy_gh_release "mcp-hub" "ravitemer/mcp-hub" "tarball" "latest" "/opt/mcp-hub"

msg_info "Building MCP Hub"
cd /opt/mcp-hub || exit
$STD npm install
$STD npm run build
$STD npm prune --omit=dev
msg_ok "Built MCP Hub"

msg_info "Configuring MCP Hub"
cat <<EOF >/opt/mcp-hub/global.json
{
  "mcpServers": {}
}
EOF
msg_ok "Configured MCP Hub"

msg_info "Creating Service"
mkdir -p /root/.mcp-hub
cat <<EOF >/etc/systemd/system/mcphub.service
[Unit]
Description=MCP Hub Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/mcp-hub
ExecStart=/usr/bin/node /opt/mcp-hub/dist/cli.js --port 37373 --config /opt/mcp-hub/global.json --watch
Restart=always
RestartSec=10
Environment="NODE_ENV=production"
Environment="HOME=/root"

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now mcphub
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
