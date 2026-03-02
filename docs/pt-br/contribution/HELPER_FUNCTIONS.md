# 🛠️ Referência de Funções Auxiliares

**Referência rápida para todas as funções auxiliares disponíveis em `tools.func`**

> Essas funções estão automaticamente disponíveis em scripts de instalação através de `$FUNCTIONS_FILE_PATH`

---

## 📋 Sumário

- [Scripts para Observar](#scripts-to-watch)
- [Configuração de Ambiente de Execução e Idioma](#runtime--language-setup)
- [Configuração de Banco de Dados](#database-setup)
- [Auxiliares de Lançamento do GitHub](#github-release-helpers)
- [Ferramentas e Utilitários](#tools--utilities)
- [SSL/TLS](#ssltls)
- [Funções Utilitárias](#utility-functions)
- [Gerenciamento de Pacotes](#package-management)

---

## 📚 Scripts para Observar

**Aprenda com Scripts reais e bem implementados. Cada aplicativo requer DOIS arquivos que funcionam em conjunto:**

| Arquivo                  | Localização                  | Finalidade                                                               |
| ------------------------ | ---------------------------- | ------------------------------------------------------------------------ |
| **Script CT**            | `ct/appname.sh`              | Executa no **host Proxmox** - cria o contêiner, contém `update_script()` |
| **Script de Instalação** | `install/appname-install.sh` | Executa **dentro do contêiner** - instala e configura o aplicativo       |

> ⚠️ **Ambos os arquivos são SEMPRE necessários!** O script CT chama o script de instalação automaticamente durante a criação do contêiner.

Os scripts de instalação **não** são executados diretamente pelos usuários; eles são invocados pelo script CT dentro do contêiner.

### Node.js + PostgreSQL

**Koel** - Streaming de música com PHP + Node.js + PostgreSQL | Arquivo | Link | | ----------------- | -------------------------------------------------------- | | CT (lógica de atualização) |
[ct/koel.sh](../../ct/koel.sh) | | Instalar | [install/koel-install.sh](../../install/koel-install.sh) |

**Orçamento Real** - Aplicativo financeiro com instalação global via npm | Arquivo | Link | | ----------------- | ------------------------------------------------------------------------ | | CT
(lógica de atualização) | [ct/actualbudget.sh](../../ct/actualbudget.sh) | | Instalar | [install/actualbudget-install.sh](../../install/actualbudget-install.sh) |

### Python + uv

**MeTube** - Baixador de vídeos do YouTube com Python uv + Node.js + Deno | Arquivo | Link | | ----------------- | ------------------------------------------------------------ | | CT (lógica de
atualização) | [ct/metube.sh](../../ct/metube.sh) | | Instalar | [install/metube-install.sh](../../install/metube-install.sh) |

**Endurain** - Rastreador de atividades físicas com Python uv + PostgreSQL/PostGIS | Arquivo | Link | | ----------------- | ---------------------------------------------------------------- | | CT
(lógica de atualização) | [ct/endurain.sh](../../ct/endurain.sh) | | Instalar | [install/endurain-install.sh](../../install/endurain-install.sh) |

### Java + Gradle

**BookLore** - Gerenciamento de livros com Java 21 + Gradle + MariaDB + Nginx | Arquivo | Link | | ----------------- | -------------------------------------------------------------- | | CT (lógica de
atualização) | [ct/booklore.sh](../../ct/booklore.sh) | | Instalar | [install/booklore-install.sh](../../install/booklore-install.sh) |

## Pnpm + Meilisearch

**KaraKeep** - Gerenciador de favoritos com Pnpm + Meilisearch + Puppeteer | Arquivo | Link | | ----------------- | -------------------------------------------------------------- | | CT (lógica de
atualização) | [ct/karakeep.sh](../../ct/karakeep.sh) | | Instalar | [install/karakeep-install.sh](../../install/karakeep-install.sh) |

## PHP + MariaDB/MySQL

**Wallabag** - Leia mais tarde com PHP + MariaDB + Redis + Nginx | Arquivo | Link | | ----------------- | ---------------------------------------------------------------- | | CT (lógica de
atualização) | [ct/wallabag.sh](../../ct/wallabag.sh) | | Instalar | [install/wallabag-install.sh](../../install/wallabag-install.sh) |

**InvoiceNinja** - Faturamento com PHP + MariaDB + Supervisor | Arquivo | Link | | ----------------- | ------------------------------------------------------------------------ | | CT (lógica de
atualização) | [ct/invoiceninja.sh](../../ct/invoiceninja.sh) | | Instalar | [install/invoiceninja-install.sh](../../install/invoiceninja-install.sh) |

**BookStack** - Wiki/Documentação com PHP + MariaDB + Apache | Arquivo | Link | | ----------------- | ------------------------------------------------------------------ | | CT (lógica de atualização)
| [ct/bookstack.sh](../../ct/bookstack.sh) | | Instalar | [install/bookstack-install.sh](../../install/bookstack-install.sh) |

### PHP + SQLite (Simples)

**Rastreador de Speedtest** - Teste de velocidade com PHP + SQLite + Nginx | Arquivo | Link | | ----------------- | ---------------------------------------------------------------------------------- |
| CT (lógica de atualização) | [ct/speedtest-tracker.sh](../../ct/speedtest-tracker.sh) | | Instalar | [install/speedtest-tracker-install.sh](../../install/speedtest-tracker-install.sh) |

---

## Configuração de Ambiente de Execução e Linguagem

### `setup_nodejs`

Instale o Node.js a partir do repositório NodeSource.

```bash
# Default (Node.js 24)
setup_nodejs

# Specific version
NODE_VERSION="20" setup_nodejs
NODE_VERSION="22" setup_nodejs
NODE_VERSION="24" setup_nodejs
```

### `setup_go`

Instale a linguagem de programação Go (versão estável mais recente).

```bash
setup_go

# Use in script
setup_go
cd /opt/myapp
$STD go build -o myapp .
```

### `setup_rust`

Instale o Rust via rustup.

```bash
setup_rust

# Use in script
setup_rust
source "$HOME/.cargo/env"
$STD cargo build --release
```

### `setup_uv`

Instala o gerenciador de pacotes uv do Python (substituto rápido para pip/venv).

```bash
# Default
setup_uv

# Install a specific Python version
PYTHON_VERSION="3.12" setup_uv

# Use in script
setup_uv
cd /opt/myapp
$STD uv sync --locked
```

### `setup_ruby`

Instala o Ruby a partir dos repositórios oficiais.

```bash
setup_ruby
```

### `setup_php`

Instala o PHP com módulos configuráveis ​​e suporte a FPM/Apache.

```bash
# Basic PHP
setup_php

# Full configuration
PHP_VERSION="8.4" \
PHP_MODULE="mysqli,gd,curl,mbstring,xml,zip,ldap" \
PHP_FPM="YES" \
PHP_APACHE="YES" \
setup_php
```

**Variáveis ​​de Ambiente:**

| Variável      | Padrão | Descrição                              |
| ------------- | ------ | -------------------------------------- |
| `PHP_VERSION` | `8.4`  | Versão do PHP a ser instalada          |
| `PHP_MODULE`  | `""`   | Lista de módulos separados por vírgula |
| `PHP_FPM`     | `NO`   | Instalar PHP-FPM                       |
| `PHP_APACHE`  | `NÃO`  | Instalar módulo Apache                 |

### `setup_composer`

Instalar o gerenciador de pacotes PHP Composer.

```bash
setup_php
setup_composer

# Use in script
$STD composer install --no-dev
```

### `setup_java`

Instalar o Java (OpenJDK).

```bash
# Default (Java 21)
setup_java

# Specific version
JAVA_VERSION="17" setup_java
JAVA_VERSION="21" setup_java
```

---

## Configuração do Banco de Dados

### `setup_mariadb`

Instalar o servidor MariaDB.

```bash
setup_mariadb
```

### `setup_mariadb_db`

Criar um banco de dados e um usuário MariaDB. Definir `$MARIADB_DB_PASS` com a senha gerada.

```bash
setup_mariadb
MARIADB_DB_NAME="myapp_db" MARIADB_DB_USER="myapp_user" setup_mariadb_db

# After calling, these variables are available:
# $MARIADB_DB_NAME - Database name
# $MARIADB_DB_USER - Database user
# $MARIADB_DB_PASS - Generated password (saved to ~/[appname].creds)
```

### `setup_mysql`

Instalar o servidor MySQL.

```bash
setup_mysql
```

### `setup_postgresql`

Instala o servidor PostgreSQL.

```bash
# Default (PostgreSQL 16)
setup_postgresql

# Specific version
PG_VERSION="16" setup_postgresql
PG_VERSION="16" setup_postgresql
```

### `setup_postgresql_db`

Cria um banco de dados e um usuário PostgreSQL. Define `$PG_DB_PASS` com a senha gerada.

```bash
PG_VERSION="17" setup_postgresql
PG_DB_NAME="myapp_db" PG_DB_USER="myapp_user" setup_postgresql_db

# After calling, these variables are available:
# $PG_DB_NAME - Database name
# $PG_DB_USER - Database user
# $PG_DB_PASS - Generated password (saved to ~/[appname].creds)
```

### `setup_mongodb`

Instala o servidor MongoDB.

```bash
setup_mongodb
```

### `setup_clickhouse`

Instala o banco de dados de análise do ClickHouse.

```bash
setup_clickhouse
```

---

## Gerenciamento Avançado de Repositórios

### `setup_deb822_repo`

O padrão moderno (Debian 12+) para adicionar repositórios externos. Lida automaticamente com chaves GPG e fontes.

```bash
setup_deb822_repo \
  "nodejs" \
  "https://deb.nodesource.com/gpgkey/nodesource.gpg.key" \
  "https://deb.nodesource.com/node_22.x" \
  "bookworm" \
  "main"
```

### `prepare_repository_setup`

Um auxiliar de alto nível que executa três tarefas críticas antes de adicionar um novo repositório:

1. Limpa arquivos de repositório antigos que correspondam aos nomes fornecidos.

2. Remove chaves GPG antigas de todos os locais padrão.

3. Garante que o APT esteja funcionando corretamente (corrige bloqueios, executa atualizações).

```bash
# Clean up old mysql/mariadb artifacts before setup
prepare_repository_setup "mariadb" "mysql"
```

### `cleanup_tool_keyrings`

Remove à força as chaves GPG de ferramentas específicas dos diretórios `/usr/share/keyrings/`, `/etc/apt/keyrings/` e `/etc/apt/trusted.gpg.d/`.

```bash
cleanup_tool_keyrings "docker" "kubernetes"
```

---

## Auxiliares de Lançamento do GitHub

> **Nota:** `fetch_and_deploy_gh_release` é o **método preferencial** para baixar versões do GitHub. Ele gerencia o controle de versão automaticamente. Use `get_latest_github_release` somente se
> precisar do número da versão separadamente.

### `fetch_and_deploy_gh_release`

**Método principal** para baixar e extrair versões do GitHub. Gerencia o controle de versão automaticamente.

```bash
# Basic usage - downloads tarball to /opt/appname
fetch_and_deploy_gh_release "appname" "owner/repo"

# With explicit parameters
fetch_and_deploy_gh_release "appname" "owner/repo" "tarball" "latest" "/opt/appname"

# Pre-built release with specific asset pattern
fetch_and_deploy_gh_release "koel" "koel/koel" "prebuild" "latest" "/opt/koel" "koel-*.tar.gz"

# Clean install (removes old directory first) - used in update_script
CLEAN_INSTALL=1 fetch_and_deploy_gh_release "appname" "owner/repo" "tarball" "latest" "/opt/appname"
```

**Parâmetros:** | Parâmetro | Padrão | Descrição | | --------------- | ------------- | ----------------------------------------------------------------- | | `name` | obrigatório | Nome do aplicativo
(para controle de versão) | | `repo` | obrigatório | Repositório do GitHub (`owner/repo`) | | `type` | `tarball` | Tipo de lançamento: `tarball`, `zipball`, `prebuild`, `binary` | | `version` |
`latest` | Tag da versão ou `latest` | | `dest` | `/opt/[name]` | Diretório de destino | | `asset_pattern` | `""` | Para `prebuild`: padrão glob para corresponder ao recurso (ex.: `app-*.tar.gz`) |

**Variáveis ​​de Ambiente:**

| Variável          | Descrição                                                          |
| ----------------- | ------------------------------------------------------------------ |
| `CLEAN_INSTALL=1` | Remover diretório de destino antes da extração (para atualizações) |

### `check_for_gh_release`

Verifica se uma versão mais recente está disponível. Retorna 0 se uma atualização for necessária, 1 se já estiver na versão mais recente. **Use na função `update_script()`.**

```bash
# In update_script() function in ct/appname.sh
if check_for_gh_release "appname" "owner/repo"; then
  msg_info "Updating..."
  # Stop services, backup, update, restore, start
  CLEAN_INSTALL=1 fetch_and_deploy_gh_release "appname" "owner/repo"
  msg_ok "Updated successfully!"
fi
```

### `get_latest_github_release`

Obtém a versão mais recente de um repositório do GitHub. **Use somente se precisar do número da versão separadamente** (por exemplo, para download manual ou exibição).

```bash
RELEASE=$(get_latest_github_release "owner/repo")
echo "Latest version: $RELEASE"
```

---

## Ferramentas e Utilitários

### `setup_meilisearch`

Instala o Meilisearch, um mecanismo de busca extremamente rápido.

```bash
setup_meilisearch

# Use in script
$STD php artisan scout:sync-index-settings
```

### `setup_yq`

Instala o processador YAML yq.

```bash
setup_yq

# Use in script
yq '.server.port = 8080' -i config.yaml
```

### `setup_ffmpeg`

Instala o FFmpeg com codecs comuns.

```bash
setup_ffmpeg
```

### `setup_hwaccel`

Configura a aceleração de hardware da GPU (Intel/AMD/NVIDIA).

```bash
# Only runs if GPU passthrough is detected (/dev/dri, /dev/nvidia0, /dev/kfd)
setup_hwaccel
```

### `setup_imagemagick`

Instala o ImageMagick 7 a partir do código-fonte.

```bash
setup_imagemagick
```

### `setup_docker`

Instala o Docker Engine.

```bash
setup_docker
```

### `setup_adminer`

Instala o Adminer para gerenciamento de banco de dados.

```bash
setup_mariadb
setup_adminer

# Access at http://IP/adminer
```

---

## SSL/TLS

### `create_self_signed_cert`

Cria um certificado SSL autoassinado.

```bash
create_self_signed_cert

# Creates files at:
# /etc/ssl/[appname]/[appname].key
# /etc/ssl/[appname]/[appname].crt
```

---

## Funções de Utilidade

### `verify_tool_version`

Valida se a versão principal instalada corresponde à versão esperada. Útil durante atualizações ou solução de problemas.

```bash
# Verify Node.js is version 22
verify_tool_version "nodejs" "22" "$(node -v | grep -oP '^v\K[0-9]+')"
```

### `get_lxc_ip`

Define a variável `$LOCAL_IP` com o endereço IP do contêiner.

```bash
get_lxc_ip
echo "Container IP: $LOCAL_IP"

# Use in config files
sed -i "s/localhost/$LOCAL_IP/g" /opt/myapp/config.yaml
```

### `ensure_dependencies`

Verifica se os pacotes estão instalados (instala se estiverem faltando).

```bash
ensure_dependencies "jq" "unzip" "curl"
```

### `msg_info` / `msg_ok` / `msg_error` / `msg_warn`

Exibe mensagens formatadas.

```bash
msg_info "Installing application..."
# ... do work ...
msg_ok "Installation complete"

msg_warn "Optional feature not available"
msg_error "Installation failed"
```

---

## Gerenciamento de Pacotes

### `cleanup_lxc`

Função de limpeza final - chamada ao final do script de instalação.

```bash
# At the end of your install script
motd_ssh
customize
cleanup_lxc  # Handles autoremove, autoclean, cache cleanup
```

### `install_packages_with_retry`

Instala pacotes com nova tentativa automática em caso de falha.

```bash
install_packages_with_retry "package1" "package2" "package3"
```

### `prepare_repository_setup`

Prepara o sistema para adicionar novos repositórios (limpa repositórios antigos e chaveiros).

```bash
prepare_repository_setup "mariadb" "mysql"
```

---

## Exemplos Completos

### Exemplo 1: Aplicativo Node.js com PostgreSQL (script de instalação)

```bash
#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: YourUsername
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/example/myapp

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y nginx
msg_ok "Installed Dependencies"

# Setup runtimes and databases FIRST
NODE_VERSION="22" setup_nodejs
PG_VERSION="16" setup_postgresql
PG_DB_NAME="myapp" PG_DB_USER="myapp" setup_postgresql_db
get_lxc_ip

# Download app using fetch_and_deploy (handles version tracking)
fetch_and_deploy_gh_release "myapp" "example/myapp" "tarball" "latest" "/opt/myapp"

msg_info "Setting up MyApp"
cd /opt/myapp
$STD npm ci --production
msg_ok "Setup MyApp"

msg_info "Configuring MyApp"
cat <<EOF >/opt/myapp/.env
DATABASE_URL=postgresql://${PG_DB_USER}:${PG_DB_PASS}@localhost/${PG_DB_NAME}
HOST=${LOCAL_IP}
PORT=3000
EOF
msg_ok "Configured MyApp"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/myapp.service
[Unit]
Description=MyApp
After=network.target postgresql.service

[Service]
Type=simple
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/node /opt/myapp/server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now myapp
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
```

### Exemplo 2: Script de Contêiner Correspondente (script ct)

```bash
#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: YourUsername
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/example/myapp

APP="MyApp"
var_tags="${var_tags:-webapp}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-6}"
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

  if [[ ! -d /opt/myapp ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  # check_for_gh_release returns true if update available
  if check_for_gh_release "myapp" "example/myapp"; then
    msg_info "Stopping Service"
    systemctl stop myapp
    msg_ok "Stopped Service"

    msg_info "Creating Backup"
    cp /opt/myapp/.env /tmp/myapp_env.bak
    msg_ok "Created Backup"

    # CLEAN_INSTALL=1 removes old dir before extracting
    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "myapp" "example/myapp" "tarball" "latest" "/opt/myapp"

    msg_info "Restoring Config & Rebuilding"
    cp /tmp/myapp_env.bak /opt/myapp/.env
    rm /tmp/myapp_env.bak
    cd /opt/myapp
    $STD npm ci --production
    msg_ok "Restored Config & Rebuilt"

    msg_info "Starting Service"
    systemctl start myapp
    msg_ok "Started Service"

    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3000${CL}"
```

### Exemplo 3: Aplicativo PHP com MariaDB (script de instalação)

```bash
#!/usr/bin/env bash

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y nginx
msg_ok "Installed Dependencies"

# PHP with FPM and common modules
PHP_VERSION="8.4" PHP_FPM="YES" PHP_MODULE="bcmath,curl,gd,intl,mbstring,mysql,xml,zip" setup_php
setup_composer
setup_mariadb
MARIADB_DB_NAME="myapp" MARIADB_DB_USER="myapp" setup_mariadb_db
get_lxc_ip

# Download pre-built release (with asset pattern)
fetch_and_deploy_gh_release "myapp" "example/myapp" "prebuild" "latest" "/opt/myapp" "myapp-*.tar.gz"

msg_info "Configuring MyApp"
cd /opt/myapp
cp .env.example .env
sed -i "s|APP_URL=.*|APP_URL=http://${LOCAL_IP}|" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=${MARIADB_DB_NAME}|" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=${MARIADB_DB_USER}|" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${MARIADB_DB_PASS}|" .env
$STD composer install --no-dev --no-interaction
$STD php artisan key:generate --force
$STD php artisan migrate --force
chown -R www-data:www-data /opt/myapp
msg_ok "Configured MyApp"

# ... nginx config, service creation ...

motd_ssh
customize
cleanup_lxc
```
