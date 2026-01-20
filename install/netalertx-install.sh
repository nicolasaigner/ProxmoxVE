#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Nicolas (contribuição)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/jokob-sk/NetAlertX

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# Variables
INSTALL_DIR="/app"
WEB_UI_DIR="/var/www/html/netalertx"
NGINX_CONFIG="/etc/nginx/conf.d/netalertx.conf"
PORT=20211

msg_info "Installing Dependencies"
$STD apt-get install -y \
  ca-certificates \
  lsb-release \
  curl \
  gnupg \
  git \
  snmp \
  libwww-perl \
  arp-scan \
  perl \
  apt-utils \
  cron \
  sudo \
  sqlite3 \
  dnsutils \
  net-tools \
  mtr \
  iproute2 \
  nmap \
  fping \
  zip \
  usbutils \
  traceroute \
  nbtscan \
  avahi-daemon \
  avahi-utils \
  build-essential \
  debian-archive-keyring
msg_ok "Installed Dependencies"

msg_info "Installing Python Dependencies"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv
msg_ok "Installed Python Dependencies"

msg_info "Installing PHP Dependencies"
$STD apt-get install -y \
  php \
  php-cgi \
  php-fpm \
  php-sqlite3 \
  php-curl
msg_ok "Installed PHP Dependencies"

msg_info "Installing NGINX"
$STD apt-get install -y nginx
systemctl enable -q nginx
msg_ok "Installed NGINX"

msg_info "Cloning NetAlertX Repository"
mkdir -p "$INSTALL_DIR"
$STD git clone https://github.com/jokob-sk/NetAlertX.git "$INSTALL_DIR/"
if [ ! -f "$INSTALL_DIR/front/buildtimestamp.txt" ]; then
  date +%s > "$INSTALL_DIR/front/buildtimestamp.txt"
fi
msg_ok "Cloned NetAlertX Repository"

msg_info "Setting up Python Virtual Environment"
$STD python3 -m venv /opt/myenv
source /opt/myenv/bin/activate
$STD pip install --upgrade pip
$STD pip install -r "${INSTALL_DIR}/install/proxmox/requirements.txt"
msg_ok "Setup Python Virtual Environment"

msg_info "Configuring NGINX"
# Backup and remove default site
if [ -L /etc/nginx/sites-enabled/default ]; then
  rm /etc/nginx/sites-enabled/default
elif [ -f /etc/nginx/sites-enabled/default ]; then
  mv /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default.bkp_netalertx
fi

# Setup web directory
mkdir -p /var/www/html
rm -rf "$WEB_UI_DIR" 2>/dev/null || true
ln -sfn "${INSTALL_DIR}/front" "$WEB_UI_DIR"

# Copy and configure NGINX
mkdir -p "${INSTALL_DIR}/config"
cp "${INSTALL_DIR}/install/proxmox/netalertx.conf" "${INSTALL_DIR}/config/netalertx.conf"
sed -i "s/listen 20211;/listen ${PORT};/g" "${INSTALL_DIR}/config/netalertx.conf"
ln -sfn "${INSTALL_DIR}/config/netalertx.conf" "${NGINX_CONFIG}"

# Start PHP-FPM
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
systemctl enable -q "php${PHP_VERSION}-fpm"
systemctl restart -q "php${PHP_VERSION}-fpm"
systemctl restart -q nginx
msg_ok "Configured NGINX"

msg_info "Setting up NetAlertX Files"
# Create log and api directories with tmpfs
mkdir -p "${INSTALL_DIR}/log" "${INSTALL_DIR}/api"

# Create log files
touch ${INSTALL_DIR}/log/{app.log,execution_queue.log,app_front.log,app.php_errors.log,stderr.log,stdout.log,db_is_locked.log}
touch ${INSTALL_DIR}/api/user_notifications.json

# Setup database and config
mkdir -p "${INSTALL_DIR}/config" "${INSTALL_DIR}/db"
cp -u "${INSTALL_DIR}/back/app.conf" "${INSTALL_DIR}/config/app.conf" 2>/dev/null || true
cp -u "${INSTALL_DIR}/back/app.db" "${INSTALL_DIR}/db/app.db" 2>/dev/null || true

# Set permissions
chgrp -R www-data "$INSTALL_DIR"
chmod -R ug+rwX,o-rwx "$INSTALL_DIR"
chown -R www-data:www-data "${INSTALL_DIR}/log" "${INSTALL_DIR}/api" "${INSTALL_DIR}/db" "${INSTALL_DIR}/config"
msg_ok "Setup NetAlertX Files"

msg_info "Creating Start Script"
LOCAL_IP=$(hostname -I | awk '{print $1}')
cat > "$INSTALL_DIR/start.netalertx.sh" << EOF
#!/usr/bin/env bash
source /opt/myenv/bin/activate
echo "Starting NetAlertX - navigate to http://${LOCAL_IP}:${PORT}"
python server/
EOF
chmod +x "$INSTALL_DIR/start.netalertx.sh"
msg_ok "Created Start Script"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/netalertx.service
[Unit]
Description=NetAlertX Service
After=network-online.target nginx.service
Wants=network-online.target

[Service]
Type=simple
User=www-data
Group=www-data
ExecStart=/app/start.netalertx.sh
WorkingDirectory=/app
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable -q --now netalertx.service
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
