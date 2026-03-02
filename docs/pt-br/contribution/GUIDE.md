# 🎯 **Guia de Contribuição do ProxmoxVE**

**Tudo o que você precisa saber para contribuir com o ProxmoxVE**

> **Última atualização**: Dezembro de 2025
> **Dificuldade**: Iniciante → Avançado
> **Tempo de configuração**: 15 minutos
> **Tempo de contribuição**: 1 a 3 horas

---

## 📋 Sumário

- [Início Rápido](#quick-start)
- [Estrutura do Repositório](#repository-structure)
- [Configuração de Desenvolvimento](#development-setup)
- [Criando Novos Aplicativos](#creating-new-applications)
- [Atualizando Aplicativos Existentes](#updating-existing-applications)
- [Padrões de Código](#code-standards)
- [Testando suas Alterações](#testing-your-changes)
- [Enviando um Pull Request](#testing-your-changes) [Solicitação](#submitting-a-pull-request)
- [Solução de Problemas](#troubleshooting)
- [Perguntas Frequentes](#faq)

---

## Início Rápido

### Configurar seu Fork (Apenas na Primeira Vez)

```bash
# 1. Fork the repository on GitHub
# Visit: https://github.com/community-scripts/ProxmoxVE
# Click: Fork (top right)

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/ProxmoxVE.git
cd ProxmoxVE

# 3. Run fork setup script (automatically configures everything)
bash docs/contribution/setup-fork.sh --full
# --full updates ct/, install/, vm/, docs/, misc/ links for fork testing

# 4. Read the git workflow tips
cat .git-setup-info
```

### 60 Segundos para a Primeira Contribuição

```bash
# 1. Create feature branch
git checkout -b add/my-awesome-app

# 2. Create application scripts from templates
cp docs/contribution/templates_ct/AppName.sh ct/myapp.sh
cp docs/contribution/templates_install/AppName-install.sh install/myapp-install.sh
cp docs/contribution/templates_json/AppName.json frontend/public/json/myapp.json

# 3. Edit your scripts
nano ct/myapp.sh
nano install/myapp-install.sh
nano frontend/public/json/myapp.json

# 4. Commit and push to your fork
git add ct/myapp.sh install/myapp-install.sh frontend/public/json/myapp.json
git commit -m "feat: add MyApp container and install scripts"
git push origin add/my-awesome-app

# 5. Test via curl from your fork (GitHub may take 10-30 seconds)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/myapp.sh)"

# 6. Use cherry-pick to submit only your files (see Cherry-Pick section)
# DO NOT submit the 600+ files modified by setup-fork.sh!

# 7. Open Pull Request on GitHub
# Create PR from: your-fork/add/my-awesome-app → community-scripts/ProxmoxVE/main
```

**💡 Dica**: Consulte `../FORK_SETUP.md` para obter detalhes sobre a configuração do fork e a solução de problemas

---

## Estrutura do Repositório

### Organização de Alto Nível

```
ProxmoxVE/
├── ct/                          # 🏗️  Container creation scripts (host-side)
│   ├── pihole.sh
│   ├── docker.sh
│   └── ... (40+ applications)
│
├── install/                     # 🛠️  Installation scripts (container-side)
│   ├── pihole-install.sh
│   ├── docker-install.sh
│   └── ... (40+ applications)
│
├── vm/                          # 💾 VM creation scripts
│   ├── ubuntu2404-vm.sh
│   ├── debian-vm.sh
│   └── ... (15+ operating systems)
│
├── misc/                        # 📦 Shared function libraries
│   ├── build.func               # Main orchestrator (3800+ lines)
│   ├── core.func                # UI/utilities
│   ├── error_handler.func       # Error management
│   ├── tools.func               # Tool installation
│   ├── install.func             # Container setup
│   ├── cloud-init.func          # VM configuration
│   ├── api.func                 # Telemetry
│   ├── alpine-install.func      # Alpine-specific
│   └── alpine-tools.func        # Alpine tools
│
├── docs/                        # 📚 Documentation
│   ├── ct/DETAILED_GUIDE.md     # Container script guide
│   ├── install/DETAILED_GUIDE.md # Install script guide
│   └── contribution/README.md   # Contribution overview
│
├── tools/                       # 🔧 Proxmox management tools
│   └── pve/
│
└── README.md                    # Project overview
```

### Convenções de Nomenclatura

```
Container Script:      ct/AppName.sh
Installation Script:   install/appname-install.sh
Defaults:             defaults/appname.vars
Update Script:        /usr/bin/update (inside container)

Examples:
  ct/pihole.sh                → install/pihole-install.sh
  ct/docker.sh                → install/docker-install.sh
  ct/nextcloud-vm.sh          → install/nextcloud-vm-install.sh
```

**Regras**:

- Nome do script do contêiner: **Primeira Letra Maiúscula** (Pi-hole, Docker, Nextcloud)
- Nome do script de instalação: **minúsculas** com **hífens** (pihole-install, docker-install)
- Deve corresponder: `ct/AppName.sh` ↔ `install/appname-install.sh`
- Nomes de diretórios: minúsculas (sempre)
- Nomes de variáveis: minúsculas (exceto a constante APP)

---

## Configuração de Desenvolvimento

### Pré-requisitos

1. **Proxmox VE 8.0+** com pelo menos:

- 4 núcleos de CPU
- 8 GB de RAM
- 50 GB de espaço em disco

- Ubuntu 20.04 / Debian 11+ no host

2. **Git** instalado

```bash
   apt-get install -y git
```

3. **Editor de Texto** (VS Code recomendado)

```bash
   # VS Code extensions:
   # - Bash IDE
   # - Shellcheck
   # - Markdown All in One
```

### Fluxo de Trabalho de Desenvolvimento Local

#### Opção A: Fork de Desenvolvimento (Recomendado)

```bash
# 1. Fork on GitHub (one-time)
# Visit: https://github.com/community-scripts/ProxmoxVE
# Click: Fork

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/ProxmoxVE.git
cd ProxmoxVE

# 3. Add upstream remote for updates
git remote add upstream https://github.com/community-scripts/ProxmoxVE.git

# 4. Create feature branch
git checkout -b feat/add-myapp

# 5. Make changes
# ... edit files ...

# 6. Keep fork updated
git fetch upstream
git rebase upstream/main

# 7. Push and open PR
git push origin feat/add-myapp
```

#### Opção B: Testando em um host Proxmox (ainda via curl)

```bash
# 1. SSH into Proxmox host
ssh root@192.168.1.100

# 2. Test via curl from your fork (CT script only)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/myapp.sh)"
# ⏱️ Wait 10-30 seconds after pushing - GitHub takes time to update
```

> **Observação:** Não edite URLs manualmente nem execute scripts de instalação diretamente. O script CT chama o script de instalação dentro do contêiner.

#### Opção C: Usando Curl (Recomendado para Testes Reais)

```bash
# Always test via curl from your fork (GitHub takes 10-30 seconds after push)
git push origin feature/myapp
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/myapp.sh)"
# This tests the actual GitHub URLs, not local files
```

#### Opção D: Verificações Estáticas (Sem Proxmox)

```bash
# You can validate syntax and linting locally (limited)
# Note: This does NOT replace real Proxmox testing

# Run ShellCheck
shellcheck ct/myapp.sh
shellcheck install/myapp-install.sh

# Syntax check
bash -n ct/myapp.sh
bash -n install/myapp-install.sh
```

---

## Criando Novos Aplicativos

### Passo 1: Escolha Seu Modelo

**Para Aplicativos Web Simples** (Node.js, Python, PHP):

```bash
cp ct/example.sh ct/myapp.sh
cp install/example-install.sh install/myapp-install.sh
```

**Para Aplicativos de Banco de Dados** (PostgreSQL, MariaDB, MongoDB):

Use os modelos padrão e as funções auxiliares de banco de dados de `tools.func` (sem Docker).

**Para aplicativos Alpine Linux** (leve):

```bash
# Use ct/alpine.sh as reference
# Edit install script to use Alpine packages (apk not apt)
```

### Etapa 2: Atualizar o script do contêiner

**Arquivo**: `ct/myapp.sh`

```bash
#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/misc/build.func)

# Update these:
APP="MyAwesomeApp"                    # Display name
var_tags="category;tag2;tag3"         # Max 3-4 tags
var_cpu="2"                          # Realistic CPU cores
var_ram="2048"                       # Min RAM needed (MB)
var_disk="10"                        # Min disk (GB)
var_os="debian"                      # OS type
var_version="12"                     # OS version
var_unprivileged="1"                 # Security (1=unprivileged)

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

  if check_for_gh_release "myapp" "owner/repo"; then
    msg_info "Stopping Service"
    systemctl stop myapp
    msg_ok "Stopped Service"

    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "myapp" "owner/repo" "tarball" "latest" "/opt/myapp"

    # ... update logic (migrations, rebuilds, etc.) ...

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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:PORT${CL}"
```

**Lista de verificação**:

- [ ] A variável APP corresponde ao nome do arquivo
- [ ] As tags de variáveis ​​são separadas por ponto e vírgula (sem espaços)
- [ ] Valores realistas de CPU/RAM/disco
- [ ] update_script() implementado
- [ ] Sistema operacional e versão corretos
- [ ] Mensagem de sucesso com URL de acesso

### Etapa 3: Atualizar o script de instalação

**Arquivo**: `install/myapp-install.sh`

```bash
#!/usr/bin/env bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: YourUsername
# License: MIT
# Source: https://github.com/example/myapp

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  build-essential
msg_ok "Installed Dependencies"

NODE_VERSION="22" setup_nodejs

fetch_and_deploy_gh_release "myapp" "owner/repo" "tarball" "latest" "/opt/myapp"

motd_ssh
customize
cleanup_lxc
```

**Lista de verificação**:

- [ ] Funções carregadas de `$FUNCTIONS_FILE_PATH`
- [ ] Todas as fases de instalação presentes (deps, tools, app, config, limpeza)
- [ ] Usando `$STD` para supressão de saída
- [ ] Arquivo de versão salvo
- [ ] Limpeza final com `cleanup_lxc`
- [ ] Sem versões codificadas (use a API do GitHub)

### Etapa 4: Criar cabeçalho ASCII (Opcional)

**Arquivo**: `ct/headers/myapp`

```
╔═══════════════════════════════════════╗
║                                       ║
║          🎉 MyAwesomeApp 🎉          ║
║                                       ║
║  Your app is being installed...       ║
║                                       ║
╚═══════════════════════════════════════╝
```

Salvar em: `ct/headers/myapp` (sem extensão)

### Etapa 5: Criar arquivo de valores padrão (Opcional)

**Arquivo**: `defaults/myapp.vars`

```bash
# Default configuration for MyAwesomeApp
var_cpu=4
var_ram=4096
var_disk=15
var_hostname=myapp-container
var_timezone=UTC
```

---

## Atualizando aplicativos existentes

### Etapa 1: Identificar o que mudou

```bash
# Check logs or GitHub releases
curl -fsSL https://api.github.com/repos/app/repo/releases/latest | jq '.'

# Review breaking changes
# Update dependencies if needed
```

### Etapa 2: Atualizar instalação Script

```bash
# Edit: install/existingapp-install.sh

# 1. Update version (if hardcoded)
RELEASE="2.0.0"

# 2. Update package dependencies (if any changed)
$STD apt-get install -y newdependency

# 3. Update configuration (if format changed)
# Update sed replacements or config files

# 4. Test thoroughly before committing
```

### Etapa 3: O Padrão de Atualização

A função `update_script()` em `ct/appname.sh` deve seguir um padrão robusto:

1. **Verificar atualizações**: Use `check_for_gh_release` para ignorar a lógica caso não exista uma nova versão.

2. **Parar serviços**: Pare todos os serviços relevantes (`systemctl stop appname`).

3. **Fazer backup da instalação existente**: Mova a pasta antiga (por exemplo, `mv /opt/app /opt/app_bak`).

4. **Implantar nova versão**: Use `CLEAN_INSTALL=1 fetch_and_deploy_gh_release`.

5. **Restaurar configuração**: Copie os arquivos `.env` ou de configuração de volta do backup.

6. **Reconstruir/Migrar**: Execute `npm install`, `composer install` ou migrações de banco de dados. 7. **Iniciar serviços**: Reinicie os serviços e limpe o backup.

**Exemplo de `ct/bookstack.sh`**:

```bash
function update_script() {
  if check_for_gh_release "bookstack" "BookStackApp/BookStack"; then
    msg_info "Stopping Services"
    systemctl stop apache2

    msg_info "Backing up data"
    mv /opt/bookstack /opt/bookstack-backup

    fetch_and_deploy_gh_release "bookstack" "BookStackApp/BookStack" "tarball"

    msg_info "Restoring backup"
    cp /opt/bookstack-backup/.env /opt/bookstack/.env
    # ... restore uploads ...

    msg_info "Configuring"
    cd /opt/bookstack
    $STD composer install --no-dev
    $STD php artisan migrate --force

    systemctl start apache2
    rm -rf /opt/bookstack-backup
    msg_ok "Updated successfully!"
  fi
}
```

---

## Padrões de código

### Guia de estilo Bash

#### Nomenclatura de variáveis

```bash
# ✅ Good
APP="MyApp"                 # Constants (UPPERCASE)
var_cpu="2"                # Configuration (var_*)
container_id="100"         # Local variables (lowercase)
DB_PASSWORD="secret"       # Environment-like (UPPERCASE)

# ❌ Bad
myapp="MyApp"              # Inconsistent
VAR_CPU="2"               # Wrong convention
containerid="100"         # Unclear purpose
```

#### Nomenclatura de funções

```bash
# ✅ Good
function setup_database() { }       # Descriptive
function check_version() { }        # Verb-noun pattern
function install_dependencies() { } # Clear action

# ❌ Bad
function setup() { }                # Too vague
function db_setup() { }             # Inconsistent pattern
function x() { }                    # Cryptic
```

#### Citação

```bash
# ✅ Good
echo "${APP}"                       # Always quote variables
if [[ "$var" == "value" ]]; then   # Use [[ ]] for conditionals
echo "Using $var in string"        # Variables in double quotes

# ❌ Bad
echo $APP                          # Unquoted variables
if [ "$var" = "value" ]; then      # Use [[ ]] instead
echo 'Using $var in string'        # Single quotes prevent expansion
```

#### Formatação de comandos

```bash
# ✅ Good: Multiline for readability
$STD apt-get install -y \
  package1 \
  package2 \
  package3

# ✅ Good: Complex commands with variables
if ! wget -q "https://example.com/${file}"; then
  msg_error "Failed to download"
  exit 1
fi

# ❌ Bad: Too long on one line
$STD apt-get install -y package1 package2 package3 package4 package5 package6

# ❌ Bad: No error checking
wget https://example.com/file
```

#### Tratamento de Erros

```bash
# ✅ Good: Check critical commands
if ! some_command; then
  msg_error "Command failed"
  exit 1
fi

# ✅ Good: Use catch_errors for automatic trapping
catch_errors

# ❌ Bad: Silently ignore failures
some_command || true
some_command 2>/dev/null

# ❌ Bad: Unclear what failed
if ! (cmd1 && cmd2 && cmd3); then
  msg_error "Something failed"
fi
```

### Padrões de Documentação

#### Comentários de Cabeçalho

```bash
#!/usr/bin/env bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: YourUsername
# Co-Author: AnotherAuthor (for collaborative work)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/app/repo
# Description: Brief description of what this script does
```

#### Comentários Inline

```bash
# ✅ Good: Explain WHY, not WHAT
# Use alphanumeric only to avoid shell escaping issues
DB_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)

# ✅ Good: Comment complex logic
# Detect if running Alpine vs Debian for proper package manager
if grep -qi 'alpine' /etc/os-release; then
  PKG_MGR="apk"
else
  PKG_MGR="apt"
fi

# ❌ Bad: Comment obvious code
# Set the variable
var="value"

# ❌ Bad: Outdated comments
# TODO: Fix this (written 2 years ago, not fixed)
```

### Organização de Arquivos

```bash
#!/usr/bin/env bash                  # [1] Shebang (first line)
# Copyright & Metadata               # [2] Comments
                                     # [3] Blank line
# Load functions                     # [4] Import section
source <(curl -fsSL ...)
                                     # [5] Blank line
# Configuration                      # [6] Variables/Config
APP="MyApp"
var_cpu="2"
                                     # [7] Blank line
# Initialization                     # [8] Setup
header_info "$APP"
variables
color
catch_errors
                                     # [9] Blank line
# Functions                          # [10] Function definitions
function update_script() { }
function custom_setup() { }
                                     # [11] Blank line
# Main execution                     # [12] Script logic
start
build_container
```

---

## Testando suas Alterações

### Testes Pré-Submissão

#### 1. Verificação de Sintaxe

```bash
# Verify bash syntax
bash -n ct/myapp.sh
bash -n install/myapp-install.sh

# If no output: ✅ Syntax is valid
# If error output: ❌ Fix syntax before submitting
```

#### 2. Análise Estática ShellCheck

```bash
# Install ShellCheck
apt-get install -y shellcheck

# Check scripts
shellcheck ct/myapp.sh
shellcheck install/myapp-install.sh

# Review warnings and fix if applicable
# Some warnings can be intentional (use # shellcheck disable=...)
```

#### 3. Proxmox Real Testes

```bash
# Best: Test on actual Proxmox system

# 1. SSH into Proxmox host
ssh root@YOUR_PROXMOX_IP

# 2. Test via curl from your fork (CT script only)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/myapp.sh)"
# ⏱️ Wait 10-30 seconds after pushing - GitHub takes time to update

# 3. Test interaction:
#    - Select installation mode
#    - Confirm settings
#    - Monitor installation

# 4. Verify container created
pct list | grep myapp

# 5. Log into container and verify app
pct exec 100 bash
```

#### 4. Teste de Casos Extremos

```bash
# Test with different settings:

# Test 1: Advanced (19-step) installation
# When prompted: Select "2" for Advanced

# Test 2: User Defaults
# Before running: Create ~/.community-scripts/default.vars
# When prompted: Select "3" for User Defaults

# Test 3: Error handling
# Simulate network outage (block internet)
# Verify script handles gracefully

# Test 4: Update function
# Create initial container (via curl from fork)
# Wait for new release
# Test update: bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/myapp.sh)"
# Verify it detects and applies update
```

### Lista de Verificação de Testes

Antes de enviar o PR:

```bash
# Code quality
- [ ] Syntax: bash -n passes
- [ ] ShellCheck: No critical warnings
- [ ] Naming: Follows conventions
- [ ] Formatting: Consistent indentation

# Functionality
- [ ] Container creation: Successful
- [ ] Installation: Completes without errors
- [ ] Access URL: Works and app responds
- [ ] Update function: Detects new versions
- [ ] Cleanup: No temporary files left

# Documentation
- [ ] Copyright header present
- [ ] App name matches filenames
- [ ] Default values realistic
- [ ] Success message clear and helpful

# Compatibility
- [ ] Works on Debian 12
- [ ] Works on Ubuntu 22.04
- [ ] (Optional) Works on Alpine 3.20
```

---

## Enviando um Pull Request

### Passo 1: Prepare sua Branch

```bash
# Update with latest changes
git fetch upstream
git rebase upstream/main

# If conflicts occur:
git rebase --abort
# Resolve conflicts manually then:
git add .
git rebase --continue
```

### Passo 2: Envie suas Alterações

```bash
git push origin feat/add-myapp

# If already pushed:
git push origin feat/add-myapp --force-with-lease
```

### Passo 3: Crie um Pull Request no GitHub

**Acesse**: https://github.com/community-scripts/ProxmoxVE/pulls

**Clique**: "Novo Pull Request"

**Selecione**: `community-scripts:main` ← `SEU_NOME_DE_USUÁRIO:feat/myapp`

### Etapa 4: Preencha a descrição da PR

Use este modelo:

```markdown
## Description

Brief description of what this PR adds/fixes

## Type of Change

- [ ] New application (ct/AppName.sh + install/appname-install.sh)
- [ ] Update existing application
- [ ] Bug fix
- [ ] Documentation update
- [ ] Other: **\_\_\_**

## Testing

- [ ] Tested on Proxmox VE 8.x
- [ ] Container creation successful
- [ ] Application installation successful
- [ ] Application is accessible at URL
- [ ] Update function works (if applicable)
- [ ] No temporary files left after installation

## Application Details (for new apps only)

- **App Name**: MyApp
- **Source**: https://github.com/app/repo
- **Default OS**: Debian 12
- **Recommended Resources**: 2 CPU, 2GB RAM, 10GB Disk
- **Tags**: category;tag2;tag3
- **Access URL**: http://IP:PORT/path

## Checklist

- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have tested the script via curl from my fork (after git push)
- [ ] GitHub had time to update (waited 10-30 seconds)
- [ ] ShellCheck shows no critical warnings
- [ ] Documentation is accurate and complete
- [ ] I have added/updated relevant documentation
```

### Etapa 5: Responda aos comentários da revisão

**Os mantenedores podem solicitar alterações**:

- Corrigir problemas de sintaxe/estilo
- Adicionar melhor tratamento de erros
- Otimizar o uso de recursos
- Atualizar a documentação

**Para abordar o feedback**:

```bash
# Make requested changes
git add .
git commit -m "Address review feedback: ..."
git push origin feat/add-myapp

# PR automatically updates!
# No need to create new PR
```

### Etapa 6: Comemore! 🎉

Após a integração, sua contribuição fará parte do ProxmoxVE e estará disponível para todos os usuários!

---

## Solução de Problemas

### "Repositório não encontrado" ao clonar

```bash
# Check your fork exists
# Visit: https://github.com/YOUR_USERNAME/ProxmoxVE

# If not there: Click "Fork" on original repo first
```

### "Permissão negada" ao enviar

```bash
# Setup SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub  # Copy this

# Add to GitHub: Settings → SSH Keys → New Key

# Or use HTTPS with token:
git remote set-url origin https://YOUR_TOKEN@github.com/YOUR_USERNAME/ProxmoxVE.git
```

### Erros de sintaxe no script

```bash
# Use ShellCheck to identify issues
shellcheck install/myapp-install.sh

# Common issues:
# - Unmatched quotes: "string' or 'string"
# - Missing semicolons before then: if [...]; then
# - Wrong quoting: echo $VAR instead of echo "${VAR}"
```

### A criação do contêiner falha imediatamente

```bash
# 1. Check Proxmox resources
free -h              # Check RAM
df -h                # Check disk space
pct list            # Check CTID availability

# 2. Check script URL
# Make sure curl -s in script points to your fork

# 3. Review errors
# Run with verbose: bash -x ct/myapp.sh
```

### Aplicativo inacessível após a criação

```bash
# 1. Verify container running
pct list
pct status CTID

# 2. Check if service running inside
pct exec CTID systemctl status myapp

# 3. Check firewall
# Proxmox host: iptables -L
# Container: iptables -L

# 4. Verify listening port
pct exec CTID netstat -tlnp | grep LISTEN
```

---

## Perguntas Frequentes

### P: Preciso ser um especialista em Bash?

**R**: Não! A base de código possui muitos exemplos que você pode copiar. A maioria das contribuições consiste na criação de scripts simples, seguindo os padrões estabelecidos.

### P: Posso adicionar um novo aplicativo que não seja de código aberto?

**R:** Não. O ProxmoxVE foca em aplicações de código aberto (GPL, MIT, Apache, etc.). Aplicações de código fechado não serão aceitas.

### P: Quanto tempo leva para meu PR ser revisado?

**R:** Os mantenedores são voluntários. As revisões geralmente ocorrem em 1 a 2 semanas. Alterações complexas podem levar mais tempo.

### P: Posso testar sem um sistema Proxmox?

**R:** Parcialmente. Você pode verificar a sintaxe e a conformidade com o ShellCheck localmente, mas testes reais em contêineres exigem o Proxmox. Considere usar:

- Proxmox em uma VM (VirtualBox/KVM)
- Instâncias de teste na Hetzner/DigitalOcean
- Solicitar aos mantenedores que testem para você

### P: Minha função de atualização é muito complexa - isso é um problema?

**R:** Sim! Funções de atualização podem ser complexas, se necessário. Certifique-se de:

- Fazer backup dos dados do usuário antes de atualizar
- Restaurar os dados do usuário após a atualização
- Testar minuciosamente antes de enviar
- Adicionar comentários claros explicando a lógica

### P: Posso adicionar novas dependências ao build.func?

**R**: Geralmente não. O build.func é o orquestrador e deve permanecer estável. Novas funções devem ser adicionadas em:

- `tools.func` - Instalação de ferramentas
- `core.func` - Funções utilitárias
- `install.func` - Configuração do contêiner

Em caso de dúvida, abra uma issue primeiro.

### P: E se o aplicativo tiver muitas opções de configuração?

**R:** Você tem opções:

**Opção 1:** Usar o modo Avançado (assistente de 19 etapas)

```bash
# Extend advanced_settings() if app needs special vars
```

**Opção 2:** Criar um menu de configuração personalizado

```bash
function custom_config() {
  OPTION=$(whiptail --inputbox "Enter database name:" 8 60)
  # ... use $OPTION in installation
}
```

**Opção 3:** Manter as configurações padrão + documentação

```bash
# In success message:
echo "Edit /opt/myapp/config.json to customize settings"
```

### P: Posso contribuir com suporte para Windows/macOS/ARM?

**R:**

- **Windows:** Não está planejado (o ProxmoxVE é focado em Linux/Proxmox)
- **macOS:** Pode contribuir com alternativas baseadas em Docker
- **ARM:** Sim! Muitos aplicativos funcionam em ARM. Adicionar aos scripts vm/pimox-\*.sh

---

## Obtendo Ajuda

### Recursos

- **Documentação**: Diretório `/docs` e wikis
- **Referência de Funções**: Arquivos wiki `/misc/*.md`
- **Exemplos**: Consulte aplicações similares em `/ct` e `/install`
- **Problemas no GitHub**: https://github.com/community-scripts/ProxmoxVE/issues
- **Discussões**: https://github.com/community-scripts/ProxmoxVE/discussions

### Fazer Perguntas

1. **Verifique problemas existentes** - Sua pergunta pode já ter sido respondida
2. **Pesquise na documentação** - Consulte `/docs` e `/misc/*.md`
3. **Pergunte nas Discussões** - Para perguntas gerais
4. **Abra um Problema** - Para bugs ou problemas específicos

### Relatar Bugs

Ao reportar bugs, inclua:

- Qual aplicativo
- O que aconteceu (mensagem de erro)
- O que você esperava
- Sua versão do Proxmox
- Sistema operacional e versão do container

Exemplo:

```
Title: pihole-install.sh fails on Alpine 3.20

Description:
Installation fails with error: "PHP-FPM not found"

Expected:
PiHole should install successfully

Environment:
- Proxmox VE 8.2
- Alpine 3.20
- Container CTID 110

Error Output:
[ERROR] in line 42: exit code 127: while executing command php-fpm --start
```

---

## Estatísticas de Contribuição

**ProxmoxVE em Números**:

- 🎯 Mais de 40 aplicativos suportados
- 👥 Mais de 100 colaboradores
- 📊 Mais de 10.000 estrelas no GitHub
- 🚀 Mais de 50 lançamentos
- 📈 Mais de 100.000 downloads por mês

**Sua contribuição faz a diferença!**

---

## Código de Conduta

Ao contribuir, você concorda em:

- ✅ Ser respeitoso e inclusivo
- ✅ Seguir as diretrizes de estilo
- ✅ Testar suas alterações minuciosamente
- ✅ Fornecer mensagens de commit claras
- ✅ Responder ao feedback das revisões

---

**Pronto para contribuir?** Comece com a seção [Início Rápido](#quick-start)!

**Dúvidas?** Abra uma issue ou inicie uma discussão no GitHub.

**Obrigado pela sua contribuição!** 🙏
