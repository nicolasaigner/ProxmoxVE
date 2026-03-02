# 🚀 **Scripts de Contêiner de Aplicativos (ct/AppName.sh)**

**Guia Moderno para Criar Scripts de Instalação de Contêineres LXC**

> **Atualizado**: Dezembro de 2025
> **Contexto**: Totalmente integrado com build.func, assistente de configurações avançadas e sistema de padrões
> **Exemplos Utilizados**: `/ct/pihole.sh`, `/ct/docker.sh`

---

## 📋 Sumário

- [Visão Geral](#overview)
- [Arquitetura e Fluxo](#architecture--flow)
- [Estrutura de Arquivos](#file-structure)
- [Modelo de Script Completo](#complete-script-template)
- [Referência de Funções](#function-reference)
- [Recursos Avançados](#advanced-features)
- [Exemplos Reais](#real-examples)
- [Solução de problemas](#troubleshooting)
- [Lista de verificação de contribuição](#contribution-checklist)

---

## Visão geral

### Objetivo

Os scripts de contêiner (`ct/AppName.sh`) são **pontos de entrada para a criação de contêineres LXC** com aplicativos específicos pré-instalados. Eles:

1. Definem os valores padrão do contêiner (CPU, RAM, disco, SO)
2. Chamam o orquestrador de compilação principal (`build.func`)
3. Implementam mecanismos de atualização específicos da aplicação
4. Fornecem mensagens de sucesso para o usuário

### Contexto de Execução

```
Proxmox Host
    ↓
ct/AppName.sh sourced (runs as root on host)
    ↓
build.func: Creates LXC container + runs install script inside
    ↓
install/AppName-install.sh (runs inside container)
    ↓
Container ready with app installed
```

### Principais Pontos de Integração

- **build.func** - Orquestrador principal (criação de contêiner, armazenamento, gerenciamento de variáveis)
- **install.func** - Configuração específica do contêiner (atualização do SO, gerenciamento de pacotes)
- **tools.func** - Auxiliares de instalação de ferramentas (repositórios, versões do GitHub)
- **core.func** - Funções de interface do usuário/mensagens (cores, indicadores de carregamento, validação)
- **error_handler.func** - Tratamento de erros e gerenciamento de sinais

---

## Arquitetura e Fluxo

### Fluxo de Criação de Contêiner

```
START: bash ct/pihole.sh
  ↓
[1] Set APP, var_*, defaults
  ↓
[2] header_info() → Display ASCII art
  ↓
[3] variables() → Parse arguments & load build.func
  ↓
[4] color() → Setup ANSI codes
  ↓
[5] catch_errors() → Setup trap handlers
  ↓
[6] install_script() → Show mode menu (5 options)
  ↓
  ├─ INSTALL_MODE="0" (Default)
  ├─ INSTALL_MODE="1" (Advanced - 19-step wizard)
  ├─ INSTALL_MODE="2" (User Defaults)
  ├─ INSTALL_MODE="3" (App Defaults)
  └─ INSTALL_MODE="4" (Settings Menu)
  ↓
[7] advanced_settings() → Collect user configuration (if mode=1)
  ↓
[8] start() → Confirm or re-edit settings
  ↓
[9] build_container() → Create LXC + execute install script
  ↓
[10] description() → Set container description
  ↓
[11] SUCCESS → Display access URL
  ↓
END
```

### Valores Padrão Precedência

```
Priority 1 (Highest): Environment Variables (var_cpu, var_ram, etc.)
Priority 2: App-Specific Defaults (/defaults/AppName.vars)
Priority 3: User Global Defaults (/default.vars)
Priority 4 (Lowest): Built-in Defaults (in build.func)
```

---

## Estrutura de Arquivos

### Modelo Mínimo ct/AppName.sh

```
#!/usr/bin/env bash                          # [1] Shebang
                                             # [2] Copyright/License
source <(curl -s .../misc/build.func)        # [3] Import functions
                                             # [4] APP metadata
APP="AppName"                                # [5] Default values
var_tags="tag1;tag2"
var_cpu="2"
var_ram="2048"
...

header_info "$APP"                           # [6] Display header
variables                                    # [7] Process arguments
color                                        # [8] Setup colors
catch_errors                                 # [9] Setup error handling

function update_script() { ... }             # [10] Update function (optional)

start                                        # [11] Launch container creation
build_container
description
msg_ok "Completed successfully!\n"
```

---

## Modelo de Script Completo

### 1. Cabeçalho e Importações do Arquivo

```bash
#!/usr/bin/env bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: YourUsername
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/example/project

# Import main orchestrator
source <(curl -fsSL https://git.community-scripts.org/community-scripts/ProxmoxVE/raw/branch/main/misc/build.func)
```

> **⚠️ IMPORTANTE**: Antes de abrir um PR, altere a URL para o repositório `community-scripts`!

### 2. Metadados da Aplicação

```bash
# Application Configuration
APP="ApplicationName"
var_tags="tag1;tag2;tag3"      # Max 3-4 tags, no spaces, semicolon-separated

# Container Resources
var_cpu="2"                    # CPU cores
var_ram="2048"                 # RAM in MB
var_disk="10"                  # Disk in GB

# Container Type & OS
var_os="debian"                # Options: alpine, debian, ubuntu
var_version="12"               # Alpine: 3.20+, Debian: 11-13, Ubuntu: 20.04+
var_unprivileged="1"           # 1=unprivileged (secure), 0=privileged (rarely needed)
```

**Convenção de Nomenclatura de Variáveis**:

- Variáveis ​​expostas ao usuário: `var_*` (ex.: `var_cpu`, `var_hostname`, `var_ssh`)
- Variáveis ​​internas: minúsculas (ex.: `container_id`, `app_version`)

### 3. Exibição e Inicialização

```bash
# Display header ASCII art
header_info "$APP"

# Process command-line arguments and load configuration
variables

# Setup ANSI color codes and formatting
color

# Initialize error handling (trap ERR, EXIT, INT, TERM)
catch_errors
```

### 4. Função de Atualização (Altamente Recomendada)

```bash
function update_script() {
  header_info

  # Always start with these checks
  check_container_storage
  check_container_resources

  # Verify app is installed
  if [[ ! -d /opt/appname ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  # Get latest version from GitHub
  RELEASE=$(curl -fsSL https://api.github.com/repos/user/repo/releases/latest | \
    grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')

  # Compare with saved version
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Updating ${APP} to v${RELEASE}"

    # Backup user data
    cp -r /opt/appname /opt/appname-backup

    # Perform update
    cd /opt
    wget -q "https://github.com/user/repo/releases/download/v${RELEASE}/app-${RELEASE}.tar.gz"
    tar -xzf app-${RELEASE}.tar.gz

    # Restore user data
    cp /opt/appname-backup/config/* /opt/appname/config/

    # Cleanup
    rm -rf app-${RELEASE}.tar.gz /opt/appname-backup

    # Save new version
    echo "${RELEASE}" > /opt/${APP}_version.txt

    msg_ok "Updated ${APP} to v${RELEASE}"
  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}."
  fi

  exit
}
```

### 5. Execução de Script

```bash
# Start the container creation workflow
start

# Build the container with selected configuration
build_container

# Set container description/notes in Proxmox UI
description

# Display success message
msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"
```

---

## Referência de Funções

### Funções Principais (De build.func)

#### `variables()`

**Finalidade**: Inicializar variáveis ​​do contêiner, carregar argumentos do usuário, configurar Orquestração

**Acionado por**: Chamado automaticamente ao iniciar o script

**Comportamento**:

1. Analisar argumentos da linha de comando (se houver)
2. Gerar UUID aleatório para rastreamento de sessão
3. Carregar o armazenamento do contêiner do Proxmox
4. Inicializar os padrões específicos do aplicativo
5. Configurar SSH/ambiente

#### `start()`

**Finalidade**: Abrir o menu de criação de contêiner com 5 modos de instalação

**Opções do Menu**:

```
1. Default Installation (Quick setup, predefined settings)
2. Advanced Installation (19-step wizard with full control)
3. User Defaults (Load ~/.community-scripts/default.vars)
4. App Defaults (Load /defaults/AppName.vars)
5. Settings Menu (Interactive mode selection)
```

#### `build_container()`

**Finalidade**: Orquestrador principal para a criação de contêineres LXC

**Operações**:

1. Validar todas as variáveis
2. Criar um contêiner LXC via `pct create`
3. Executar `install/AppName-install.sh` dentro do contêiner
4. Monitorar o progresso da instalação
5. Tratar erros e reverter em caso de falha

#### `description()`

**Objetivo**: Exibir a descrição/notas do contêiner na interface do Proxmox

---

## Recursos Avançados

### 1. Menus de Configuração Personalizados

Se seu aplicativo tiver configurações adicionais além das variáveis ​​padrão:

```bash
custom_app_settings() {
  CONFIGURE_DB=$(whiptail --title "Database Setup" \
    --yesno "Would you like to configure a custom database?" 8 60)

  if [[ $? -eq 0 ]]; then
    DB_HOST=$(whiptail --inputbox "Database Host:" 8 60 3>&1 1>&2 2>&3)
    DB_PORT=$(whiptail --inputbox "Database Port:" 8 60 "3306" 3>&1 1>&2 2>&3)
  fi
}

custom_app_settings
```

### 2. Padrões de Função de Atualização

Salvar a versão instalada para verificações de atualização

### 3. Funções de Verificação de Saúde

Adicionar validação personalizada:

```bash
function health_check() {
  header_info

  if [[ ! -d /opt/appname ]]; then
    msg_error "Application not found!"
    exit 1
  fi

  if ! systemctl is-active --quiet appname; then
    msg_error "Application service not running"
    exit 1
  fi

  msg_ok "Health check passed"
}
```

---

## Exemplos Reais

### Exemplo 1: Aplicativo Web Simples (baseado em Debian)

```bash
#!/usr/bin/env bash
source <(curl -fsSL https://git.community-scripts.org/community-scripts/ProxmoxVE/raw/branch/main/misc/build.func)

APP="Homarr"
var_tags="dashboard;homepage"
var_cpu="2"
var_ram="1024"
var_disk="5"
var_os="debian"
var_version="12"
var_unprivileged="1"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  # Update logic here
}

start
build_container
description
msg_ok "Completed successfully!\n"
```

---

## Solução de Problemas

### Falha na Criação do Contêiner

**Sintoma**: `pct create` é encerrado com código de erro 209

**Solução**:

```bash
# Check existing containers
pct list | grep CTID

# Remove conflicting container
pct destroy CTID

# Retry ct/AppName.sh
```

### A função de atualização não detecta a nova versão

**Depuração**:

```bash
# Check version file
cat /opt/AppName_version.txt

# Test GitHub API
curl -fsSL https://api.github.com/repos/user/repo/releases/latest | grep tag_name
```

---

## Lista de verificação para contribuições

Antes de enviar um PR:

### Estrutura do script

- [ ] Shebang é `#!/usr/bin/env bash`
- [ ] Importa `build.func` do repositório community-scripts
- [ ] Cabeçalho de direitos autorais com autor e URL de origem
- [ ] A variável APP corresponde ao nome do arquivo
- [ ] `var_tags` são separadas por ponto e vírgula (sem espaços)

### Valores padrão

- [ ] `var_cpu` configurado adequadamente (2-4 para a maioria dos aplicativos)
- [ ] `var_ram` configurado adequadamente (1024-4096 MB no mínimo)
- [ ] `var_disk` suficiente para aplicativo + dados (5-20 GB)
- [] `var_os` é realista

### Funções

- [ ] `update_script()` implementado
- [ ] A função de atualização verifica se o aplicativo está instalado
- [ ] Tratamento de erros adequado com `msg_error`

### Testes

- [ ] Script testado com instalação padrão
- [ ] Script testado com instalação avançada (19 etapas)
- [ ] Função de atualização testada em instalação existente

---

## Boas Práticas

### ✅ FAÇA:

1. **Use valores padrão significativos**
2. **Implemente controle de versão**
3. **Trate casos extremos**
4. **Use mensagens adequadas com msg_info/msg_ok/msg_error**

### ❌ NÃO FAÇA:

1. **Codifique versões diretamente no código**
2. **Use códigos de cores personalizados** (use variáveis ​​internas)
3. **Ignore o tratamento de erros**
4. **Deixe arquivos temporários**

---

**Última atualização**: Dezembro de 2025
**Compatibilidade**: ProxmoxVE com build.func v3+
