# 🤖 Diretrizes de Contribuição de IA para ProxmoxVE

> **Esta documentação destina-se a todos os assistentes de IA (GitHub Copilot, Claude, ChatGPT, etc.) que contribuem para este projeto.**

## 🎯 Princípios Fundamentais

### 1. **Uso Máximo das Funções `tools.func`**

Possuímos uma extensa biblioteca de funções auxiliares. **NUNCA** implemente suas próprias soluções quando uma função já existir!

### 2. **Sem Variáveis ​​Desnecessárias**

Crie variáveis ​​somente quando:

- Forem usadas várias vezes
- Melhorarem a legibilidade
- Forem destinadas à configuração

### 3. **Estrutura de Scripts Consistente**

Todos os scripts seguem uma estrutura idêntica. Desvios não são aceitáveis.

### 4. **Instalação Bare-Metal**

NÃO utilizamos Docker para nossos scripts de instalação. Todos os aplicativos são instalados diretamente no sistema.

---

## 📁 Tipos de Script e sua Estrutura

### Script CT (`ct/NomeDoAplicativo.sh`)

```bash
#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: AuthorName (GitHubUsername)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://application-url.com

APP="AppName"
var_tags="${var_tags:-tag1;tag2;tag3}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
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

  if [[ ! -d /opt/appname ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "appname" "YourUsername/YourRepo"; then
    msg_info "Stopping Service"
    systemctl stop appname
    msg_ok "Stopped Service"

    msg_info "Backing up Data"
    cp -r /opt/appname/data /opt/appname_data_backup
    msg_ok "Backed up Data"

    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "appname" "owner/repo" "tarball" "latest" "/opt/appname"

    # Build steps...

    msg_info "Restoring Data"
    cp -r /opt/appname_data_backup/. /opt/appname/data
    rm -rf /opt/appname_data_backup
    msg_ok "Restored Data"

    msg_info "Starting Service"
    systemctl start appname
    msg_ok "Started Service"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:PORT${CL}"
```

### Script de Instalação (`install/NomeDoAplicativo-install.sh`)

```bash
#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: AuthorName (GitHubUsername)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://application-url.com

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  dependency1 \
  dependency2
msg_ok "Installed Dependencies"

# Runtime Setup (ALWAYS use our functions!)
NODE_VERSION="22" setup_nodejs
# or
PG_VERSION="16" setup_postgresql
# or
setup_uv
# etc.

fetch_and_deploy_gh_release "appname" "owner/repo" "tarball" "latest" "/opt/appname"

msg_info "Setting up Application"
cd /opt/appname
# Build/Setup Schritte...
msg_ok "Set up Application"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/appname.service
[Unit]
Description=AppName Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/appname
ExecStart=/path/to/executable
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now appname
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
```

---

## 🔧 Funções Auxiliares Disponíveis

### Gerenciamento de Releases

| Função                        | Descrição                           | Exemplo                                                                 |
| ----------------------------- | ----------------------------------- | ----------------------------------------------------------------------- |
| `fetch_and_deploy_gh_release` | Busca e instala a Release do GitHub | `fetch_and_deploy_gh_release "app" "owner/repo"`                        |
| `check_for_gh_release`        | Verifica se há uma nova versão      | `if check_for_gh_release "app" "SeuNomeDeUsuário/SeuRepositório"; then` |

**Modos para `fetch_and_deploy_gh_release`:**

```bash
# Tarball/Source (Standard)
fetch_and_deploy_gh_release "appname" "owner/repo"

# Binary (.deb)
fetch_and_deploy_gh_release "appname" "owner/repo" "binary"

# Prebuilt Archive
fetch_and_deploy_gh_release "appname" "owner/repo" "prebuild" "latest" "/opt/appname" "filename.tar.gz"

# Single Binary
fetch_and_deploy_gh_release "appname" "owner/repo" "singlefile" "latest" "/opt/appname" "binary-linux-amd64"
```

**Flag de Instalação Limpa:**

```bash
CLEAN_INSTALL=1 fetch_and_deploy_gh_release "appname" "owner/repo"
```

### Configuração de Ambiente de Execução/Linguagem

| Função         | Variável(is)                  | Exemplo                                              |
| -------------- | ----------------------------- | ---------------------------------------------------- |
| `setup_nodejs` | `NODE_VERSION`, `NODE_MODULE` | `NODE_VERSION="22" setup_nodejs`                     |
| `setup_uv`     | `PYTHON_VERSION`              | `PYTHON_VERSION="3.12" setup_uv`                     |
| `setup_go`     | `GO_VERSION`                  | `GO_VERSION="1.22" setup_go`                         |
| `setup_rust`   | `RUST_VERSION`, `RUST_CRATES` | `RUST_CRATES="monolith" setup_rust`                  |
| `setup_ruby`   | `RUBY_VERSION`                | `RUBY_VERSION="3.3" setup_ruby`                      |
| `setup_java`   | `JAVA_VERSION`                | `JAVA_VERSION="21" setup_java`                       |
| `setup_php`    | `PHP_VERSION`, `PHP_MODULES`  | `PHP_VERSION="8.3" PHP_MODULES="redis,gd" setup_php` |

### Configuração do Banco de Dados

| Função             | Variável(is)                         | Exemplo                                   |
| ------------------ | ------------------------------------ | ----------------------------------------- | --- | --------------------- | -------------------------- | ----------------------------------------------------------- |
| `setup_postgresql` | `PG_VERSION`, `PG_MODULES`           | `PG_VERSION="16" setup_postgresql`        |     | `setup_postgresql_db` | `PG_DB_NAME`, `PG_DB_USER` | `PG_DB_NAME="mydb" PG_DB_USER="myuser" setup_postgresql_db` |
| `setup_mariadb_db` | `MARIADB_DB_NAME`, `MARIADB_DB_USER` | `MARIADB_DB_NAME="mydb" setup_mariadb_db` |
| `setup_mysql`      | `MYSQL_VERSION`                      | `setup_mysql`                             |
| `setup_mongodb`    | `MONGO_VERSION`                      | `setup_mongodb`                           |
| `setup_clickhouse` | -                                    | `setup_clickhouse`                        |

### Ferramentas e Utilitários

| Função              | Descrição                                              |
| ------------------- | ------------------------------------------------------ |
| `setup_adminer`     | Instala o Adminer para gerenciamento de banco de dados |
| `setup_composer`    | Instalar o PHP Composer                                |
| `setup_ffmpeg`      | Instalar o FFmpeg                                      |
| `setup_imagemagick` | Instalar o ImageMagick                                 |
| `setup_gs`          | Instalar o Ghostscript                                 |
| `setup_hwaccel`     | Configurar aceleração de hardware                      |

### Utilitários auxiliares

| Função                        | Descrição                       | Exemplo                                   |
| ----------------------------- | ------------------------------- | ----------------------------------------- |
| `import_local_ip`             | Define a variável `$LOCAL_IP`   | `import_local_ip`                         |
| `ensure_dependencies`         | Verifica/instala dependências   | `ensure_dependencies curl jq`             |
| `install_packages_with_retry` | Instalação do APT com repetição | `install_packages_with_retry nginx redis` |

---

## ❌ Antipadrões (NUNCA use!)

### 1. Variáveis ​​sem propósito

```bash
# ❌ WRONG - unnecessary variables
APP_NAME="myapp"
APP_DIR="/opt/${APP_NAME}"
APP_USER="root"
APP_PORT="3000"
cd $APP_DIR

# ✅ CORRECT - use directly
cd /opt/myapp
```

### 2. Lógica de download personalizada

```bash
# ❌ WRONG - custom wget/curl logic
RELEASE=$(curl -s https://api.github.com/repos/YourUsername/YourRepo/releases/latest | jq -r '.tag_name')
wget https://github.com/YourUsername/YourRepo/archive/${RELEASE}.tar.gz
tar -xzf ${RELEASE}.tar.gz
mv repo-${RELEASE} /opt/myapp

# ✅ CORRECT - use our function
fetch_and_deploy_gh_release "myapp" "YourUsername/YourRepo" "tarball" "latest" "/opt/myapp"
```

### 3. Lógica de verificação de versão personalizada

```bash
# ❌ WRONG - custom version check
CURRENT=$(cat /opt/myapp/version.txt)
LATEST=$(curl -s https://api.github.com/repos/YourUsername/YourRepo/releases/latest | jq -r '.tag_name')
if [[ "$CURRENT" != "$LATEST" ]]; then
  # update...
fi

# ✅ CORRECT - use our function
if check_for_gh_release "myapp" "YourUsername/YourRepo"; then
  # update...
fi
```

### 4. Instalação baseada em Docker

```bash
# ❌ WRONG - using Docker
docker pull myapp/myapp:latest
docker run -d --name myapp myapp/myapp:latest

# ✅ CORRECT - Bare-Metal Installation
fetch_and_deploy_gh_release "myapp" "YourUsername/YourRepo"
npm install && npm run build
```

### 5. Instalação de tempo de execução personalizada

```bash
# ❌ WRONG - custom Node.js installation
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

# ✅ CORRECT - use our function
NODE_VERSION="22" setup_nodejs
```

### 6. Instruções echo redundantes

```bash
# ❌ WRONG - custom logging messages
echo "Installing dependencies..."
apt install -y curl
echo "Done!"

# ✅ CORRECT - use msg_info/msg_ok
msg_info "Installing Dependencies"
$STD apt install -y curl
msg_ok "Installed Dependencies"
```

### 7. Ausência de uso de $STD

```bash
# ❌ WRONG - apt without $STD
apt install -y nginx

# ✅ CORRECT - with $STD for silent output
$STD apt install -y nginx
```

### 8. Envolvimento de funções `tools.func` em msg Blocos

```bash
# ❌ WRONG - tools.func functions have their own msg_info/msg_ok!
msg_info "Installing Node.js"
NODE_VERSION="22" setup_nodejs
msg_ok "Installed Node.js"

msg_info "Updating Application"
CLEAN_INSTALL=1 fetch_and_deploy_gh_release "appname" "owner/repo" "tarball" "latest" "/opt/appname"
msg_ok "Updated Application"

# ✅ CORRECT - call directly without msg wrapper
NODE_VERSION="22" setup_nodejs

CLEAN_INSTALL=1 fetch_and_deploy_gh_release "appname" "owner/repo" "tarball" "latest" "/opt/appname"
```

**Funções com mensagens integradas (NUNCA as envolva em blocos msg):**

- `fetch_and_deploy_gh_release`
- `check_for_gh_release`
- `setup_nodejs`
- `setup_postgresql` / `setup_postgresql_db`
- `setup_mariadb` / `setup_mariadb_db`
- `setup_mongodb`
- `setup_mysql`
- `setup_ruby`
- `setup_go`
- `setup_java`
- `setup_php`
- `setup_uv`
- `setup_rust`
- `setup_composer`
- `setup_ffmpeg`
- `setup_imagemagick`
- `setup_gs`
- `setup_adminer`
- `setup_hwaccel`

### 9. Criação de usuários de sistema desnecessários

```bash
# ❌ WRONG - LXC containers run as root, no separate user needed
useradd -m -s /usr/bin/bash appuser
chown -R appuser:appuser /opt/appname
sudo -u appuser npm install

# ✅ CORRECT - run directly as root
cd /opt/appname
$STD npm install
```

### 10. Uso de `export` em arquivos .env

```bash
# ❌ WRONG - export is unnecessary in .env files
cat <<EOF >/opt/appname/.env
export DATABASE_URL=postgres://...
export SECRET_KEY=abc123
export NODE_ENV=production
EOF

# ✅ CORRECT - simple KEY=VALUE format (files are sourced with set -a)
cat <<EOF >/opt/appname/.env
DATABASE_URL=postgres://...
SECRET_KEY=abc123
NODE_ENV=production
EOF
```

### 11. Uso de scripts shell externos

```bash
# ❌ WRONG - external script that gets executed
cat <<'EOF' >/opt/appname/install_script.sh
#!/bin/bash
cd /opt/appname
npm install
npm run build
EOF
chmod +x /opt/appname/install_script.sh
$STD bash /opt/appname/install_script.sh
rm -f /opt/appname/install_script.sh

# ✅ CORRECT - run commands directly
cd /opt/appname
$STD npm install
$STD npm run build
```

### 12. Uso de `sudo` em contêineres LXC

```bash
# ❌ WRONG - sudo is unnecessary in LXC (already root)
sudo -u postgres psql -c "CREATE DATABASE mydb;"
sudo -u appuser npm install

# ✅ CORRECT - use functions or run directly as root
PG_DB_NAME="mydb" PG_DB_USER="myuser" setup_postgresql_db

cd /opt/appname
$STD npm install
```

### 13. `systemctl daemon-reload` desnecessário

```bash
# ❌ WRONG - daemon-reload is only needed when MODIFYING existing services
cat <<EOF >/etc/systemd/system/appname.service
# ... service config ...
EOF
systemctl daemon-reload  # Unnecessary for new services!
systemctl enable -q --now appname

# ✅ CORRECT - new services don't need daemon-reload
cat <<EOF >/etc/systemd/system/appname.service
# ... service config ...
EOF
systemctl enable -q --now appname
```

### 14. Criação de arquivos de credenciais personalizados

```bash
# ❌ WRONG - custom credentials file is not part of the standard template
msg_info "Saving Credentials"
cat <<EOF >~/appname.creds
Database User: ${DB_USER}
Database Pass: ${DB_PASS}
EOF
msg_ok "Saved Credentials"

# ✅ CORRECT - credentials are stored in .env or shown in final message only
# If you use setup_postgresql_db / setup_mariadb_db, a standard ~/[appname].creds is created automatically
```

### 15. Rodapé incorreto Padrão

```bash
# ❌ WRONG - old cleanup pattern with msg blocks
motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

# ✅ CORRECT - use cleanup_lxc function
motd_ssh
customize
cleanup_lxc
```

### 16. Criação manual de banco de dados em vez de funções

```bash
# ❌ WRONG - manual database creation
DB_USER="myuser"
DB_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | cut -c1-13)
$STD sudo -u postgres psql -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASS';"
$STD sudo -u postgres psql -c "CREATE DATABASE mydb WITH OWNER $DB_USER;"
$STD sudo -u postgres psql -d mydb -c "CREATE EXTENSION IF NOT EXISTS postgis;"

# ✅ CORRECT - use setup_postgresql_db function
# This sets PG_DB_USER, PG_DB_PASS, PG_DB_NAME automatically
PG_DB_NAME="mydb" PG_DB_USER="myuser" PG_DB_EXTENSIONS="postgis" setup_postgresql_db
```

### 17. Gravação de arquivos sem heredocs

```bash
# ❌ WRONG - echo / printf / tee
echo "# Config" > /opt/app/config.yml
echo "port: 3000" >> /opt/app/config.yml

printf "# Config\nport: 3000\n" > /opt/app/config.yml
cat config.yml | tee /opt/app/config.yml
```

```bash
# ✅ CORRECT - always use a single heredoc
cat <<EOF >/opt/app/config.yml
# Config
port: 3000
EOF
```

---

## 📝 Regras importantes

### Declarações de variáveis ​​(Script CT)

```bash
# Standard declarations (ALWAYS present)
APP="AppName"
var_tags="${var_tags:-tag1;tag2}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
```

### Padrão de script de atualização

```bash
function update_script() {
  header_info
  check_container_storage
  check_container_resources

  # 1. Check if installation exists
  if [[ ! -d /opt/appname ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  # 2. Check for update
  if check_for_gh_release "appname" "YourUsername/YourRepo"; then
    # 3. Stop service
    msg_info "Stopping Service"
    systemctl stop appname
    msg_ok "Stopped Service"

    # 4. Backup data (if present)
    msg_info "Backing up Data"
    cp -r /opt/appname/data /opt/appname_data_backup
    msg_ok "Backed up Data"

    # 5. Perform clean install
    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "appname" "owner/repo" "tarball" "latest" "/opt/appname"

    # 6. Rebuild (if needed)
    cd /opt/appname
    $STD npm install
    $STD npm run build

    # 7. Restore data
    msg_info "Restoring Data"
    cp -r /opt/appname_data_backup/. /opt/appname/data
    rm -rf /opt/appname_data_backup
    msg_ok "Restored Data"

    # 8. Start service
    msg_info "Starting Service"
    systemctl start appname
    msg_ok "Started Service"
    msg_ok "Updated successfully!"
  fi
  exit  # IMPORTANT: Always end with exit!
}
```

### Padrão de serviço Systemd

```bash
msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/appname.service
[Unit]
Description=AppName Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/appname
Environment=NODE_ENV=production
ExecStart=/usr/bin/node /opt/appname/server.js
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now appname
msg_ok "Created Service"
```

### Rodapé do script de instalação

```bash
# ALWAYS at the end of the install script:
motd_ssh
customize
cleanup_lxc
```

---

## 📖 Referência: Bons exemplos de scripts

Veja estes exemplos recentes Aplicações bem implementadas como referência:

### Scripts de Contêiner (Versões 10 mais recentes)

- [ct/thingsboard.sh](../ct/thingsboard.sh) - Plataforma IoT com script de atualização adequado
- [ct/unifi-os-server.sh](../ct/unifi-os-server.sh) - Configuração complexa com podman
- [ct/trip.sh](../ct/trip.sh) - Aplicativo Ruby simples
- [ct/fladder.sh](../ct/fladder.sh) - Aplicativo de mídia com banco de dados
- [ct/qui.sh](../ct/qui.sh) - Utilitário leve
- [ct/kutt.sh](../ct/kutt.sh) - Node.js com PostgreSQL
- [ct/flatnotes.sh](../ct/flatnotes.sh) - Aplicativo de notas em Python
- [ct/investbrain.sh](../ct/investbrain.sh) - Aplicativo financeiro
- [ct/gwn-manager.sh](../ct/gwn-manager.sh) - Gerenciamento de rede
- [ct/sportarr.sh](../ct/sportarr.sh) - Variante especializada do \*Arr

### Scripts de Instalação (Mais recentes)

- [install/unifi-os-server-install.sh](../install/unifi-os-server-install.sh) - Configuração complexa com integração de API
- [install/trip-install.sh](../install/trip-install.sh) - Configuração de aplicativo Rails
- [install/mail-archiver-install.sh](../install/mail-archiver-install.sh) - Serviço relacionado a e-mail

**Pontos importantes a observar:**

- Tratamento adequado de erros com `catch_errors`
- Uso de `check_for_gh_release` e ​​`fetch_and_deploy_gh_release`
- Padrões corretos de backup/restauração em `update_script`
- O rodapé sempre termina com `motd_ssh`, `customize`, `cleanup_lxc`
- Arquivos de metadados JSON criados para cada aplicativo

---

## Arquivos de Metadados JSON

Todo aplicativo requer um arquivo de metadados JSON em `frontend/public/json/<nome_do_aplicativo>.json`.

### Estrutura JSON

```json
{
  "name": "AppName",
  "slug": "appname",
  "categories": [1],
  "date_created": "2026-01-16",
  "type": "ct",
  "updateable": true,
  "privileged": false,
  "interface_port": 3000,
  "documentation": "https://docs.appname.com/",
  "website": "https://appname.com/",
  "logo": "https://cdn.jsdelivr.net/gh/selfhst/icons@main/webp/appname.webp",
  "config_path": "/opt/appname/.env",
  "description": "Short description of the application and its purpose.",
  "install_methods": [
    {
      "type": "default",
      "script": "ct/appname.sh",
      "resources": {
        "cpu": 2,
        "ram": 2048,
        "hdd": 8,
        "os": "Debian",
        "version": "13"
      }
    }
  ],
  "default_credentials": {
    "username": null,
    "password": null
  },
  "notes": []
}
```

### Campos Obrigatórios

| Campo                 | Tipo    | Descrição                                                            |
| --------------------- | ------- | -------------------------------------------------------------------- |
| `name`                | string  | Nome de exibição do aplicativo                                       |
| `slug`                | string  | Minúsculas, sem espaços, usado para nomes de arquivos                |
| `categories`          | array   | ID(s) da(s) categoria(s) - veja a lista de categorias abaixo         |
| `date_created`        | string  | Data de criação (AAAA-MM-DD)                                         |
| `type`                | string  | `ct` para contêiner, `vm` para máquina virtual                       |
| `updateable`          | boolean | Indica se o script de atualização está implementado                  |
| `privileged`          | boolean | Indica se o contêiner precisa de modo privilegiado                   |
| `interface_port`      | number  | Porta da interface web principal (ou `null`)                         |
| `documentation`       | string  | Link para a documentação oficial                                     |
| `website`             | string  | Link para o site oficial                                             |
| `logo`                | string  | URL para o logotipo do aplicativo (preferencialmente ícones selfhst) |
| `config_path`         | string  | Caminho para o arquivo de configuração principal (ou string vazia)   |
| `description`         | string  | Breve descrição do aplicativo                                        |
| `install_methods`     | array   | Configurações de instalação                                          |
| `default_credentials` | object  | Nome de usuário/senha padrão (ou nulo)                               |
| `notes`               | array   | Observações/avisos adicionais                                        |

### Categorias

| ID  | Categoria                                         |
| --- | ------------------------------------------------- | --- | --- | -------------------- |
| 0   | Diversos                                          |
| 1   | Proxmox e Virtualização                           |
| 2   | Sistemas Operacionais                             |
| 3   | Contêineres e Docker                              |
| 4   | Rede e Firewall                                   |
| 5   | Adblock e DNS                                     |
| 6   | Autenticação e Segurança                          |
| 7   | Backup e Recuperação                              |
| 8   | Bancos de Dados                                   |
| 9   | Monitoramento e Análise                           |     | 10  | Painéis e Interfaces |
| 11  | Arquivos e Downloads                              |
| 12  | Documentos e Anotações                            |
| 13  | Mídia e Streaming                                 |
| 14  | Pacote \*Arr                                      |
| 15  | NVR e Câmeras                                     |
| 16  | IoT e Casa Inteligente                            |
| 17  | ZigBee, Z-Wave e Matter                           |
| 18  | MQTT e Mensagens                                  |
| 19  | Automação e Agendamento                           |
| 20  | IA / Programação e Ferramentas de Desenvolvimento |
| 21  | Servidores Web e Proxies                          |
| 22  | Bots e ChatOps                                    |
| 23  | Finanças e Orçamento                              |
| 24  | Jogos e Lazer                                     |
| 25  | Negócios e ERP                                    |

### Formato das Notas

```json
"notes": [
    {
        "text": "Change the default password after first login!",
        "type": "warning"
    },
    {
        "text": "Requires at least 4GB RAM for optimal performance.",
        "type": "info"
    }
]
```

**Tipos de notas:** `info`, `warning`, `error`

### Exemplos com Credenciais

```json
"default_credentials": {
    "username": "admin",
    "password": "admin"
}
```

Ou sem credenciais:

```json
"default_credentials": {
    "username": null,
    "password": null
}
```

---

## 🔍 Lista de Verificação Antes da Criação do PR

- [ ] Nenhuma instalação do Docker utilizada
- [ ] `fetch_and_deploy_gh_release` utilizado para releases do GitHub
- [ ] `check_for_gh_release` utilizado para verificações de atualização
- [ ] Funções `setup_*` utilizadas para runtimes (nodejs, postgresql, etc.)
- [ ] **Funções `tools.func` NÃO envolvidas em blocos msg_info/msg_ok**
- [ ] Sem variáveis ​​redundantes (apenas quando utilizadas múltiplas vezes)
- [ ] `$STD` antes de todos os comandos apt/npm/build
- [ ] `msg_info`/`msg_ok`/`msg_error` para registro (somente para código personalizado)
- [ ] Estrutura de script correta seguida (consulte os modelos)
- [ ] Função de atualização presente e funcional (scripts CT)
- [ ] Backup de dados implementado na função de atualização (se aplicável)
- [ ] `motd_ssh`, `customize`, `cleanup_lxc` no final dos scripts de instalação
- [ ] Sem lógica personalizada de download/verificação de versão
- [ ] Todos os links apontam para `community-scripts/ProxmoxVE` (não `ProxmoxVED`!)
- [ ] Arquivo de metadados JSON criado em `frontend/public/json/<appname>.json`
- [ ] IDs de categoria válidos (0-25)
- [ ] A versão padrão do SO é Debian 13 ou mais recente (a menos que haja um requisito especial)
- [ Os recursos padrão são adequados para a aplicação.

---

## 💡 Dicas para Assistentes de IA

1. **SEMPRE pesquise `tools.func` primeiro** antes de implementar soluções personalizadas
2. **Use scripts recentes como referência** (Thingsboard, UniFi OS, Trip, Flatnotes, etc.)
3. **Pergunte quando estiver em dúvida** em vez de introduzir padrões incorretos
4. **Teste via GitHub** - envie para o seu fork e teste com curl (não com o bash local)

```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/myapp.sh)"
   # Wait 10-30 seconds after pushing - GitHub takes time to update files
```

5. **Consistência > Criatividade** - siga rigorosamente os padrões estabelecidos
6. **Verifique os modelos** - eles mostram a estrutura correta
7. **Não encapsule funções de tools.func** - elas gerenciam sua própria saída msg_info/msg_ok
8. **Variáveis ​​mínimas** - crie apenas variáveis ​​que sejam realmente reutilizadas várias vezes
9. **Sempre use $STD** - garante execução silenciosa/não interativa
10. **Consulte bons exemplos** - observe as adições recentes em cada categoria

---

## 🍒 Importante: Selecionando os arquivos necessários para o envio do seu PR

⚠️ **CRÍTICO**: Ao enviar seu PR, você deve usar o comando `git cherry-pick` para enviar APENAS seus 3 ou 4 arquivos!

Por quê? Porque o script `setup-fork.sh` modifica mais de 600 arquivos para atualizar os links. Se você enviar todas as alterações, seu PR não poderá ser aceito.

**Consulte**: [README.md - Seção Cherry-Pick](README.md#-cherry-pick-submitting-only-your-changes) para obter instruções completas sobre:

- Criar uma branch limpa para submissão
- Selecionar apenas os seus arquivos (ct/myapp.sh, install/myapp-install.sh, frontend/public/json/myapp.json)
- Verificar se o seu PR contém apenas 3 alterações de arquivos (e não mais de 600)

**Referência rápida**:

```bash
# Create clean branch from upstream
git fetch upstream
git checkout -b submit/myapp upstream/main

# Cherry-pick your commit(s) or manually add your 3-4 files
# Then push to your fork and create PR
```

---

## 📚 Documentação Adicional

- [CONTRIBUTING.md](CONTRIBUTING.md) - Diretrizes gerais de contribuição
- [GUIDE.md](GUIDE.md) - Documentação detalhada para desenvolvedores
- [HELPER_FUNCTIONS.md](HELPER_FUNCTIONS.md) - Referência completa de tools.func
- [README.md](README.md) - Guia de seleção de arquivos e instruções de fluxo de trabalho
- [../TECHNICAL_REFERENCE.md](../TECHNICAL_REFERENCE.md) - Análise técnica detalhada
- [../EXIT_CODES.md](../EXIT_CODES.md) - Referência de códigos de saída
- [templates_ct/](templates_ct/) - Modelos de script CT
- [templates_install/](templates_install/) - Modelos de script de instalação
- [templates_json/](templates_json/) - Modelos de metadados JSON
