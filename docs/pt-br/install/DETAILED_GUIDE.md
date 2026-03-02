# 🛠️ **Scripts de Instalação de Aplicativos (install/AppName-install.sh)**

**Guia Moderno para Escrever Scripts de Instalação em Contêineres**

> **Atualizado**: Dezembro de 2025 **Contexto**: Integrado com tools.func, error_handler.func e install.func **Exemplos Utilizados**: `/install/pihole-install.sh`, `/install/mealie-install.sh`

---

## 📋 Sumário

- [Visão Geral](#overview)
- [Contexto de Execução](#execution-context)
- [Estrutura de Arquivos](#file-structure)
- [Modelo de Script Completo](#complete-script-template)
- [Fases de Instalação](#installation-phases)
- [Referência de Funções](#function-reference)
- [Melhores Práticas](#best-practices)
- [Exemplos Reais](#real-examples)
- [Solução de Problemas](#troubleshooting)
- [Lista de Verificação de Contribuição](#contribution-checklist)

---

## Visão Geral

### Objetivo

Os scripts de instalação (`install/AppName-install.sh`) **são executados dentro do contêiner LXC** e são responsáveis ​​por:

1. Configurar o sistema operacional do contêiner (atualizações, pacotes)
2. Instalar as dependências do aplicativo
3. Baixar e configurar o aplicativo
4. Configurar serviços e unidades do systemd
5. Criar arquivos de controle de versão para atualizações
6. Gerar credenciais/configurações
7. Limpeza e validação final

### Fluxo de Execução

```
ct/AppName.sh (Proxmox Host)
       ↓
build_container()
       ↓
pct exec CTID bash -c "$(cat install/AppName-install.sh)"
       ↓
install/AppName-install.sh (Inside Container)
       ↓
Container Ready with App Installed
```

---

## Contexto de Execução

### Variáveis ​​de Ambiente Disponível

```bash
# From Proxmox/Container
CTID                    # Container ID (100, 101, etc.)
PCT_OSTYPE             # OS type (alpine, debian, ubuntu)
HOSTNAME               # Container hostname

# From build.func
FUNCTIONS_FILE_PATH    # Bash functions library (core.func + tools.func)
VERBOSE                # Verbose mode (yes/no)
STD                    # Standard redirection variable (silent/empty)

# From install.func
APP                    # Application name
NSAPP                  # Normalized app name (lowercase, no spaces)
METHOD                 # Installation method (ct/install)
RANDOM_UUID            # Session UUID for telemetry
```

---

## Estrutura de Arquivos

### Modelo de instalação mínima/AppName-install.sh

```bash
#!/usr/bin/env bash                          # [1] Shebang

# [2] Copyright/Metadata
# Copyright (c) 2021-2026 community-scripts ORG
# Author: YourUsername
# License: MIT
# Source: https://example.com

# [3] Load functions
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# [4] Installation steps
msg_info "Installing Dependencies"
$STD apt-get install -y package1 package2
msg_ok "Installed Dependencies"

# [5] Final setup
motd_ssh
customize
cleanup_lxc
```

---

## Modelo de Script Completo

### Fase 1: Cabeçalho e Inicialização

```bash
#!/usr/bin/env bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: YourUsername
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/application/repo

# Load all available functions (from core.func + tools.func)
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

# Initialize environment
color                   # Setup ANSI colors and icons
verb_ip6                # Configure IPv6 (if needed)
catch_errors           # Setup error traps
setting_up_container   # Verify OS is ready
network_check          # Verify internet connectivity
update_os              # Update packages (apk/apt)
```

### Fase 2: Instalação de Dependências

```bash
msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  wget \
  git \
  nano \
  build-essential \
  libssl-dev \
  python3-dev
msg_ok "Installed Dependencies"
```

### Fase 3: Configuração de Ferramentas (Usando tools.func)

```bash
# Setup specific tool versions
NODE_VERSION="22" setup_nodejs
PHP_VERSION="8.4" setup_php
PYTHON_VERSION="3.12" setup_uv
```

### Fase 4: Download e Configuração do Aplicativo

```bash
# Download from GitHub
RELEASE=$(curl -fsSL https://api.github.com/repos/user/repo/releases/latest | \
  grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')

wget -q "https://github.com/user/repo/releases/download/v${RELEASE}/app-${RELEASE}.tar.gz"
cd /opt
tar -xzf app-${RELEASE}.tar.gz
rm -f app-${RELEASE}.tar.gz
```

### Fase 5: Arquivos de Configuração

```bash
# Using cat << EOF (multiline)
cat <<'EOF' >/etc/nginx/sites-available/appname
server {
    listen 80;
    server_name _;
    root /opt/appname/public;
    index index.php index.html;
}
EOF

# Using sed for replacements
sed -i -e "s|^DB_HOST=.*|DB_HOST=localhost|" \
       -e "s|^DB_USER=.*|DB_USER=appuser|" \
       /opt/appname/.env
```

### Fase 6: Configuração do Banco de Dados (Se Necessário)

```bash
msg_info "Setting up Database"

DB_NAME="appname_db"
DB_USER="appuser"
DB_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)

# For MySQL/MariaDB
mysql -u root <<EOF
CREATE DATABASE ${DB_NAME};
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

msg_ok "Database setup complete"
```

### Fase 7: Permissões e Propriedade

```bash
msg_info "Setting permissions"

# Web applications typically run as www-data
chown -R www-data:www-data /opt/appname
chmod -R 755 /opt/appname
chmod -R 644 /opt/appname/*
chmod 755 /opt/appname/*/.*

msg_ok "Permissions set"
```

### Fase 8: Configuração do Serviço

```bash
# Enable systemd service
systemctl enable -q --now appname

# Or for OpenRC (Alpine)
rc-service appname start
rc-update add appname default

# Verify service is running
if systemctl is-active --quiet appname; then
  msg_ok "Service running successfully"
else
  msg_error "Service failed to start"
  journalctl -u appname -n 20
  exit 1
fi
```

### Fase 9: Controle de Versão

```bash
# Essential for update detection
echo "${RELEASE}" > /opt/${APP}_version.txt

# Or with additional metadata
cat > /opt/${APP}_version.txt <<EOF
Version: ${RELEASE}
InstallDate: $(date)
InstallMethod: ${METHOD}
EOF
```

### Fase 10: Configuração Final e Limpeza

```bash
# Display MOTD and enable autologin
motd_ssh

# Final customization
customize

# Clean up package manager cache
msg_info "Cleaning up"
apt-get -y autoremove
apt-get -y autoclean
msg_ok "Cleaned"

# Or for Alpine
apk cache clean
rm -rf /var/cache/apk/*

# System cleanup
cleanup_lxc
```

---

## Fases de Instalação

### Fase 1: Configuração do SO do Contêiner

- Interface de rede ativada e configurada
- Conectividade com a internet verificada
- Listas de pacotes atualizadas
- Todos os pacotes do SO atualizados para as versões mais recentes

### Fase 2: Dependências Básicas

```bash
msg_info "Installing Base Dependencies"
$STD apt-get install -y \
  curl wget git nano build-essential
msg_ok "Installed Base Dependencies"
```

### Fase 3: Instalação de Ferramentas

```bash
NODE_VERSION="22" setup_nodejs
PHP_VERSION="8.4" setup_php
```

### Fase 4: Configuração do Aplicativo

```bash
RELEASE=$(curl -fsSL https://api.github.com/repos/user/repo/releases/latest | \
  grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')
wget -q "https://github.com/user/repo/releases/download/v${RELEASE}/app.tar.gz"
```

### Fase 5: Configuração

Arquivos de configuração específicos do aplicativo e configuração do ambiente

### Fase 6: Registro de Serviços

Habilitar e verificar se os serviços do systemd estão em execução

---

## Referência de Funções

### Funções Principais de Mensagens

#### `msg_info(mensagem)`

Exibe uma mensagem informativa com animação de carregamento

```bash
msg_info "Installing application"
# Output: ⏳ Installing application (with spinning animation)
```

#### `msg_ok(mensagem)`

Exibe uma mensagem de sucesso com marca de seleção

```bash
msg_ok "Installation completed"
# Output: ✔️ Installation completed
```

#### `msg_error(mensagem)`

Exibe uma mensagem de erro e encerra

```bash
msg_error "Installation failed"
# Output: ✖️ Installation failed
```

### Gerenciamento de Pacotes

#### Variável `$STD`

Controla a saída verbosidade

```bash
# Silent mode (respects VERBOSE setting)
$STD apt-get install -y nginx
```

#### `update_os()`

Atualiza os pacotes do sistema operacional

```bash
update_os
# Runs: apt update && apt upgrade
```

### Funções de Instalação de Ferramentas

#### `setup_nodejs()`

Instala o Node.js com módulos globais opcionais

```bash
NODE_VERSION="22" setup_nodejs
NODE_VERSION="22" NODE_MODULE="yarn,@vue/cli" setup_nodejs
```

#### `setup_php()`

Instala o PHP com extensões opcionais

```bash
PHP_VERSION="8.4" PHP_MODULE="bcmath,curl,gd,intl,redis" setup_php
```

#### Outras Ferramentas

```bash
setup_mariadb     # MariaDB database
setup_mysql       # MySQL database
setup_postgresql  # PostgreSQL
setup_docker      # Docker Engine
setup_composer    # PHP Composer
setup_python      # Python 3
setup_ruby        # Ruby
setup_rust        # Rust
```

### Funções de Limpeza

#### `cleanup_lxc()`

Limpeza completa do contêiner

- Remove os caches do gerenciador de pacotes
- Limpa arquivos temporários
- Limpa os caches dos pacotes de linguagem
- Remove o journal do systemd logs

```bash
cleanup_lxc
# Output: ⏳ Cleaning up
#         ✔️ Cleaned
```

---

## Boas Práticas

### ✅ FAÇA:

1. **Sempre use $STD para comandos**

```bash
# ✅ Good: Respects VERBOSE setting
$STD apt-get install -y nginx
```

2. **Gere senhas aleatórias com segurança**

```bash
# ✅ Good: Alphanumeric only
DB_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)
```

3. **Verifique se o comando foi executado com sucesso**

```bash
# ✅ Good: Verify success
if ! wget -q "https://example.com/file.tar.gz"; then
  msg_error "Download failed"
  exit 1
fi
```

4. **Defina as permissões adequadas**

```bash
# ✅ Good: Explicit permissions
chown -R www-data:www-data /opt/appname
chmod -R 755 /opt/appname
```

5. **Salve a versão para verificações de atualização**

```bash
# ✅ Good: Version tracked
echo "${RELEASE}" > /opt/${APP}_version.txt
```

6. **Lide com as diferenças entre Alpine e Debian**

```bash
# ✅ Good: Detect OS
if grep -qi 'alpine' /etc/os-release; then
  apk add package
else
  apt-get install -y package
fi
```

### ❌ NÃO FAÇA:

1. **Codifique diretamente no código** Versões\*\*

```bash
# ❌ Bad: Won't auto-update
wget https://example.com/app-1.2.3.tar.gz
```

2. **Usar Root sem Senha**

```bash
# ❌ Bad: Security risk
mysql -u root
```

3. **Ignorar Tratamento de Erros**

```bash
# ❌ Bad: Silent failures
wget https://example.com/file
tar -xzf file
```

4. **Deixar Arquivos Temporários**

```bash
# ✅ Always cleanup
rm -rf /opt/app-${RELEASE}.tar.gz
```

---

## Exemplos Reais

### Exemplo 1: Aplicativo Node.js

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Node.js"
NODE_VERSION="22" setup_nodejs
msg_ok "Node.js installed"

msg_info "Installing Application"
cd /opt
RELEASE=$(curl -fsSL https://api.github.com/repos/user/repo/releases/latest | \
  grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')
wget -q "https://github.com/user/repo/releases/download/v${RELEASE}/app.tar.gz"
tar -xzf app.tar.gz
echo "${RELEASE}" > /opt/app_version.txt
msg_ok "Application installed"

systemctl enable --now app
cleanup_lxc
```

### Exemplo 2: Aplicativo PHP com Banco de Dados

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

color
catch_errors
setting_up_container
network_check
update_os

PHP_VERSION="8.4" PHP_MODULE="bcmath,curl,pdo_mysql" setup_php
setup_mariadb  # Uses distribution packages (recommended)
# Or for specific version: MARIADB_VERSION="11.4" setup_mariadb

# Database setup
DB_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)
mysql -u root <<EOF
CREATE DATABASE appdb;
CREATE USER 'appuser'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL ON appdb.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;
EOF

# App installation
cd /opt
wget -q https://github.com/user/repo/releases/latest/download/app.tar.gz
tar -xzf app.tar.gz

# Configuration
cat > /opt/app/.env <<EOF
DB_HOST=localhost
DB_NAME=appdb
DB_USER=appuser
DB_PASS=${DB_PASS}
EOF

chown -R www-data:www-data /opt/app
systemctl enable --now php-fpm
cleanup_lxc
```

---

## Solução de Problemas

### Instalação Travada

**Verificar conexão com a internet**:

```bash
ping -c 1 8.8.8.8
```

**Ativar modo detalhado**:

```bash
# In ct/AppName.sh, before running
VERBOSE="yes" bash install/AppName-install.sh
```

### Pacote Não encontrado

**Atualizar listas de pacotes**:

```bash
apt update
apt-cache search package_name
```

### Serviço não inicia

**Verificar logs**:

```bash
journalctl -u appname -n 50
systemctl status appname
```

---

## Lista de verificação de contribuição

Antes de enviar um PR:

### Estrutura

- [ ] Shebang é `#!/usr/bin/env bash`
- [ ] Carrega funções de `$FUNCTIONS_FILE_PATH`
- [ ] Cabeçalho de direitos autorais com o autor
- [ ] Limpa os comentários de fase

### Instalação

- [ ] `setting_up_container` chamado antecipadamente
- [ ] `network_check` antes dos downloads
- [ ] `update_os` antes da instalação do pacote
- [ ] Todos os erros verificados corretamente

### Funções

- [ ] Usa `msg_info/msg_ok/msg_error` para status
- [ ] Usa `$STD` para silenciar a saída do comando
- [ ] Versão salva em `/opt/${APP}_version.txt`
- [ ] Permissões definidas corretamente

### Limpeza

- [ ] `motd_ssh` chamado para a configuração final
- [ ] `customize` chamado para opções
- [ ] `cleanup_lxc` chamado ao final

### Teste

- [ ] Testado com as configurações padrão
- [ ] Testado com o modo avançado (19 etapas)
- [ ] O serviço inicia e executa corretamente

---

**Última atualização**: Dezembro de 2025 **Compatibilidade**: ProxmoxVE com install.func v3+
