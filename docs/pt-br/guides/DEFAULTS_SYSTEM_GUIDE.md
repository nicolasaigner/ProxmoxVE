# Sistema de Configuração e Configurações Padrão - Guia do Usuário

> **Guia completo para Configurações Padrão de Aplicativos e Configurações Padrão do Usuário**
>
> _Aprenda como configurar, salvar e reutilizar suas configurações de instalação_

---

## Sumário

1. [Início Rápido](#quick-start)
2. [Entendendo o Sistema de Configurações Padrão](#understanding-the-defaults-system)
3. [Modos de Instalação](#installation-modes)
4. [Como Salvar Configurações Padrão](#how-to-save-defaults)
5. [Como Usar Configurações Padrão Salvas](#how-to-use-saved-defaults)
6. [Gerenciando Suas Configurações Padrão](#managing-your-defaults)
7. [Configuração Avançada](#advanced-configuration)
8. [Solução de Problemas](#troubleshooting)

---

## Início Rápido

### Configuração em 30 segundos

```bash
# 1. Run any container installation script
bash pihole-install.sh

# 2. When prompted, select: "Advanced Settings"
#    (This allows you to customize everything)

# 3. Answer all configuration questions

# 4. At the end, when asked "Save as App Defaults?"
#    Select: YES

# 5. Done! Your settings are now saved
```

**Próxima vez**: Execute o mesmo script novamente, selecione **"Padrões do aplicativo"** e suas configurações serão aplicadas automaticamente!

---

## Entendendo o Sistema de Configurações Padrão

### O Sistema de Três Camadas

Suas configurações de instalação são gerenciadas em três camadas:

#### 🔷 **Camada 1: Configurações Padrão Integradas** (Fallback)

```
These are hardcoded in the scripts
Provide sensible defaults for each application
Example: PiHole uses 2 CPU cores by default
```

#### 🔶 **Camada 2: Configurações Padrão do Usuário** (Global)

```
Your personal global defaults
Applied to ALL container installations
Location: /usr/local/community-scripts/default.vars
Example: "I always want 4 CPU cores and 2GB RAM"
```

#### 🔴 **Camada 3: Configurações Padrão do Aplicativo** (Específicas)

```
Application-specific saved settings
Only applied when installing that specific app
Location: /usr/local/community-scripts/defaults/<appname>.vars
Example: "Whenever I install PiHole, use these exact settings"
```

### Sistema de Prioridade

Ao instalar um contêiner, as configurações são aplicadas nesta ordem:

```
┌─────────────────────────────────────┐
│ 1. Environment Variables (HIGHEST)  │  Set in shell: export var_cpu=8
│    (these override everything)      │
├─────────────────────────────────────┤
│ 2. App Defaults                     │  From: defaults/pihole.vars
│    (app-specific saved settings)    │
├─────────────────────────────────────┤
│ 3. User Defaults                    │  From: default.vars
│    (your global defaults)           │
├─────────────────────────────────────┤
│ 4. Built-in Defaults (LOWEST)       │  Hardcoded in script
│    (failsafe, always available)     │
└─────────────────────────────────────┘
```

**Em outras palavras**:

- Se você definir uma variável de ambiente → ela prevalece
- Caso contrário, se você tiver configurações padrão específicas do aplicativo → use-as
- Caso contrário, se você tiver configurações padrão do usuário → usar essas opções
- Caso contrário, use os valores padrão predefinidos

---

## Modos de Instalação

Ao executar qualquer script de instalação, você verá um menu:

### Opção 1️⃣: **Configurações Padrão**

```
Quick installation with standard settings
├─ Best for: First-time users, quick deployments
├─ What happens:
│  1. Script uses built-in defaults
│  2. Container created immediately
│  3. No questions asked
└─ Time: ~2 minutes
```

**Quando usar**: Você deseja uma instalação padrão e não precisa de personalização

---

### Opção 2️⃣: **Configurações Avançadas**

```
Full customization with 19 configuration steps
├─ Best for: Power users, custom requirements
├─ What happens:
│  1. Script asks for EVERY setting
│  2. You control: CPU, RAM, Disk, Network, SSH, etc.
│  3. Shows summary before creating
│  4. Offers to save as App Defaults
└─ Time: ~5-10 minutes
```

**Quando usar**: Você deseja controle total sobre a configuração

**Configurações Disponíveis**:

- Núcleos da CPU, quantidade de RAM, tamanho do disco
- Nome do contêiner, configurações de rede
- Acesso SSH, acesso à API, recursos
- Senha, chaves SSH, tags

---

### Opção 3️⃣: **Usuário** Configurações padrão\*\*

```
Use your saved global defaults
├─ Best for: Consistent deployments across many containers
├─ Requires: You've previously saved User Defaults
├─ What happens:
│  1. Loads settings from: /usr/local/community-scripts/default.vars
│  2. Shows you the loaded settings
│  3. Creates container immediately
└─ Time: ~2 minutes
```

**Quando usar**: Você tem configurações padrão preferidas que deseja usar para todos os aplicativos

---

### Opção 4️⃣: **Configurações padrão do aplicativo** (se disponível)

```
Use previously saved app-specific defaults
├─ Best for: Repeating the same configuration multiple times
├─ Requires: You've previously saved App Defaults for this app
├─ What happens:
│  1. Loads settings from: /usr/local/community-scripts/defaults/<app>.vars
│  2. Shows you the loaded settings
│  3. Creates container immediately
└─ Time: ~2 minutes
```

**Quando usar**: Você já instalou este aplicativo antes e deseja configurações idênticas

---

### Opção 5️⃣: **Menu de configurações**

```
Manage your saved configurations
├─ Functions:
│  • View current settings
│  • Edit storage selections
│  • Manage defaults location
│  • See what's currently configured
└─ Time: ~1 minute
```

**Quando usar**: Você deseja revisar ou modificar as configurações salvas

---

## Como salvar as configurações padrão

### Método 1: Salvar durante a instalação

Esta é a maneira mais fácil:

#### Passo a passo: Criar configurações padrão do aplicativo

```bash
# 1. Run the installation script
bash pihole-install.sh

# 2. Choose installation mode
#    ┌─────────────────────────┐
#    │ Select installation mode:│
#    │ 1) Default Settings     │
#    │ 2) Advanced Settings    │
#    │ 3) User Defaults        │
#    │ 4) App Defaults         │
#    │ 5) Settings Menu        │
#    └─────────────────────────┘
#
#    Enter: 2 (Advanced Settings)

# 3. Answer all configuration questions
#    • Container name? → my-pihole
#    • CPU cores? → 4
#    • RAM amount? → 2048
#    • Disk size? → 20
#    • SSH access? → yes
#    ... (more options)

# 4. Review summary (shown before creation)
#    ✓ Confirm to proceed

# 5. After creation completes, you'll see:
#    ┌──────────────────────────────────┐
#    │ Save as App Defaults for PiHole? │
#    │ (Yes/No)                         │
#    └──────────────────────────────────┘
#
#    Select: Yes

# 6. Done! Settings saved to:
#    /usr/local/community-scripts/defaults/pihole.vars
```

#### Passo a passo: Criar usuário Configurações padrão

```bash
# Same as App Defaults, but:
# When you select "Advanced Settings"
# FIRST app you run with this selection will offer
# to save as "User Defaults" additionally

# This saves to: /usr/local/community-scripts/default.vars
```

---

### Método 2: Criação manual de arquivos

Para usuários avançados que desejam criar configurações padrão sem executar a instalação:

```bash
# Create User Defaults manually
sudo tee /usr/local/community-scripts/default.vars > /dev/null << 'EOF'
# Global User Defaults
var_cpu=4
var_ram=2048
var_disk=20
var_unprivileged=1
var_brg=vmbr0
var_gateway=192.168.1.1
var_timezone=Europe/Berlin
var_ssh=yes
var_container_storage=local
var_template_storage=local
EOF

# Create App Defaults manually
sudo tee /usr/local/community-scripts/defaults/pihole.vars > /dev/null << 'EOF'
# App-specific defaults for PiHole
var_unprivileged=1
var_cpu=2
var_ram=1024
var_disk=10
var_brg=vmbr0
var_gateway=192.168.1.1
var_hostname=pihole
var_container_storage=local
var_template_storage=local
EOF
```

---

### Método 3: Usando variáveis ​​de ambiente

Defina as configurações padrão por meio de variáveis ​​de ambiente antes de executar:

```bash
# Set as environment variables
export var_cpu=4
export var_ram=2048
export var_disk=20
export var_hostname=my-container

# Run installation
bash pihole-install.sh

# These settings will be used
# (Can still be overridden by saved defaults)
```

---

## Como usar as configurações padrão salvas

### Usando as configurações padrão do usuário

```bash
# 1. Run any installation script
bash pihole-install.sh

# 2. When asked for mode, select:
#    Option: 3 (User Defaults)

# 3. Your settings from default.vars are applied
# 4. Container created with your saved settings
```

### Usando as configurações padrão do aplicativo

```bash
# 1. Run the app you configured before
bash pihole-install.sh

# 2. When asked for mode, select:
#    Option: 4 (App Defaults)

# 3. Your settings from defaults/pihole.vars are applied
# 4. Container created with exact same settings
```

### Substituindo as configurações padrão salvas

```bash
# Even if you have defaults saved,
# you can override them with environment variables

export var_cpu=8  # Override saved defaults
export var_hostname=custom-name

bash pihole-install.sh
# Installation will use these values instead of saved defaults
```

---

## Gerenciando suas configurações padrão

### Visualizar suas configurações

#### Visualizar usuário Configurações padrão

```bash
cat /usr/local/community-scripts/default.vars
```

#### Visualizar configurações padrão do aplicativo

```bash
cat /usr/local/community-scripts/defaults/pihole.vars
```

#### Listar todas as configurações padrão salvas do aplicativo

```bash
ls -la /usr/local/community-scripts/defaults/
```

### Editar suas configurações

#### Editar configurações padrão do usuário

```bash
sudo nano /usr/local/community-scripts/default.vars
```

#### Editar configurações padrão do aplicativo

```bash
sudo nano /usr/local/community-scripts/defaults/pihole.vars
```

### Atualizar configurações padrão existentes

```bash
# Run installation again with your app
bash pihole-install.sh

# Select: Advanced Settings
# Make desired changes
# At end, when asked to save:
#   "Defaults already exist, Update?"
#   Select: Yes

# Your saved defaults are updated
```

### Excluir configurações padrão

#### Excluir configurações padrão do usuário

```bash
sudo rm /usr/local/community-scripts/default.vars
```

#### Excluir configurações padrão do aplicativo

```bash
sudo rm /usr/local/community-scripts/defaults/pihole.vars
```

#### Excluir todas as configurações padrão do aplicativo Configurações padrão

```bash
sudo rm /usr/local/community-scripts/defaults/*
```

---

## Configuração avançada

### Variáveis ​​disponíveis

Todas as variáveis ​​configuráveis ​​começam com `var_`:

#### Alocação de recursos

```bash
var_cpu=4              # CPU cores
var_ram=2048           # RAM in MB
var_disk=20            # Disk in GB
var_unprivileged=1     # 0=privileged, 1=unprivileged
```

#### Rede

```bash
var_brg=vmbr0          # Bridge interface
var_net=dhcp           # dhcp, static IP/CIDR, or IP range (see below)
var_gateway=192.168.1.1  # Default gateway (required for static IP)
var_mtu=1500           # MTU size
var_vlan=100           # VLAN ID
```

#### Varredura de intervalo de IP

Você pode especificar um intervalo de IP em vez de um IP estático. O sistema fará ping em cada IP dentro do intervalo e atribuirá automaticamente o primeiro IP livre:

```bash
# Format: START_IP/CIDR-END_IP/CIDR
var_net=192.168.1.100/24-192.168.1.200/24
var_gateway=192.168.1.1
```

Isso é útil para implantações automatizadas onde você deseja IPs estáticos, mas não quer rastrear quais IPs já estão em uso.

#### Sistema

```bash
var_hostname=pihole    # Container name
var_timezone=Europe/Berlin  # Timezone
var_pw=SecurePass123   # Root password
var_tags=dns,pihole    # Tags for organization
var_verbose=yes        # Enable verbose output
```

#### Segurança e Acesso

```bash
var_ssh=yes            # Enable SSH
var_ssh_authorized_key="ssh-rsa AA..." # SSH public key
var_protection=1       # Enable protection flag
```

#### Recursos

```bash
var_fuse=1             # FUSE filesystem support
var_tun=1              # TUN device support
var_nesting=1          # Nesting (Docker in LXC)
var_keyctl=1           # Keyctl syscall
var_mknod=1            # Device node creation
```

#### Armazenamento

```bash
var_container_storage=local    # Where to store container
var_template_storage=local     # Where to store templates
```

### Arquivos de Configuração de Exemplo

#### Configurações Padrão do Servidor de Jogos

```bash
# High performance for gaming containers
var_cpu=8
var_ram=4096
var_disk=50
var_unprivileged=0
var_fuse=1
var_nesting=1
var_tags=gaming
```

#### Servidor de Desenvolvimento

```bash
# Development with Docker support
var_cpu=4
var_ram=2048
var_disk=30
var_unprivileged=1
var_nesting=1
var_ssh=yes
var_tags=development
```

#### IoT/Monitoramento

```bash
# Low-resource, always-on containers
var_cpu=2
var_ram=512
var_disk=10
var_unprivileged=1
var_nesting=0
var_fuse=0
var_tun=0
var_tags=iot,monitoring
```

---

## Solução de Problemas

### Mensagem "Configurações padrão do aplicativo não disponíveis"

**Problema**: Você deseja usar as Configurações Padrão do Aplicativo, mas a opção indica que elas não estão disponíveis.

**Solução**:

1. Você ainda não criou Configurações Padrão do Aplicativo para este app.
2. Execute o app com as "Configurações Avançadas".
3. Ao concluir, salve como Configurações Padrão do Aplicativo.
4. Na próxima vez, as Configurações Padrão do Aplicativo estarão disponíveis.

---

### "Configurações não estão sendo aplicadas"

**Problema**: Você salvou as configurações padrão, mas elas não estão sendo usadas.

**Lista de verificação**:

```bash
# 1. Verify files exist
ls -la /usr/local/community-scripts/default.vars
ls -la /usr/local/community-scripts/defaults/<app>.vars

# 2. Check file permissions (should be readable)
stat /usr/local/community-scripts/default.vars

# 3. Verify correct mode selected
#    (Make sure you selected "User Defaults" or "App Defaults")

# 4. Check for environment variable override
env | grep var_
#    If you have var_* set in environment,
#    those override your saved defaults
```

---

### "Não é possível gravar no local das configurações padrão"

**Problema**: Permissão negada ao salvar as configurações padrão.

**Solução**:

```bash
# Create the defaults directory if missing
sudo mkdir -p /usr/local/community-scripts/defaults

# Fix permissions
sudo chmod 755 /usr/local/community-scripts
sudo chmod 755 /usr/local/community-scripts/defaults

# Make sure you're running as root
sudo bash pihole-install.sh
```

---

### "O diretório de configurações padrão não existe"

**Problema**: O script não consegue encontrar onde salvar. Configurações padrão

**Solução**:

```bash
# Create the directory
sudo mkdir -p /usr/local/community-scripts/defaults

# Verify
ls -la /usr/local/community-scripts/
```

---

### Configurações parecem aleatórias ou incorretas

**Problema**: O contêiner recebe configurações diferentes das esperadas

**Possíveis causas e soluções**:

```bash
# 1. Check if environment variables are set
env | grep var_
# If you see var_* entries, those override your defaults
# Clear them: unset var_cpu var_ram (etc)

# 2. Verify correct defaults are in files
cat /usr/local/community-scripts/default.vars
cat /usr/local/community-scripts/defaults/pihole.vars

# 3. Check which mode you actually selected
# (Script output shows which defaults were applied)

# 4. Check Proxmox logs for errors
sudo journalctl -u pve-daemon -n 50
```

---

### "Variável não reconhecida"

**Problema**: Você definiu uma variável que não funciona

**Solução**: Apenas determinadas variáveis ​​são permitidas (lista de permissões de segurança):

```
Allowed variables (starting with var_):
✓ var_cpu, var_ram, var_disk, var_unprivileged
✓ var_brg, var_gateway, var_mtu, var_vlan, var_net
✓ var_hostname, var_pw, var_timezone
✓ var_ssh, var_ssh_authorized_key
✓ var_fuse, var_tun, var_nesting, var_keyctl
✓ var_container_storage, var_template_storage
✓ var_tags, var_verbose
✓ var_apt_cacher, var_apt_cacher_ip
✓ var_protection, var_mount_fs

✗ Other variables are NOT supported
```

---

## Boas práticas

### ✅ Recomendações

✓ Use **Configurações padrão do aplicativo** quando desejar configurações específicas do aplicativo ✓ Use **Configurações padrão do usuário** para suas preferências globais ✓ Edite os arquivos de
configurações padrão diretamente com o `nano` (seguro) ✓ Mantenha configurações padrão do aplicativo separadas para cada aplicativo ✓ Faça backup dos seus arquivos Configurações padrão regularmente ✓
Use variáveis ​​de ambiente para substituições temporárias

### ❌ Não faça

✗ Não use `source` em arquivos de configurações padrão (risco de segurança) ✗ Não coloque senhas confidenciais em configurações padrão (use chaves SSH) ✗ Não modifique as configurações padrão enquanto
a instalação estiver em andamento ✗ Não exclua o arquivo defaults.d enquanto os contêineres estiverem sendo criados ✗ Não use caracteres especiais sem escape

---

## Referência Rápida

### Localizações das Configurações Padrão

| Tipo | Local | Exemplo |

|------|----------|---------|

| Configurações Padrão do Usuário | `/usr/local/community-scripts/default.vars` | Configurações Globais | | Configurações Padrão do Aplicativo | `/usr/local/community-scripts/defaults/<app>.vars` |
Específico do Pi-hole | | Diretório de Backup | `/usr/local/community-scripts/defaults/` | Todas as configurações padrão do aplicativo |

### Formato do Arquivo

```bash
# Comments start with #
var_name=value

# No spaces around =
✓ var_cpu=4
✗ var_cpu = 4

# String values don't need quotes
✓ var_hostname=mycontainer
✓ var_hostname='mycontainer'

# Values with spaces need quotes
✓ var_tags="docker,production,testing"
✗ var_tags=docker,production,testing
```

### Referência de Comandos

```bash
# View defaults
cat /usr/local/community-scripts/default.vars

# Edit defaults
sudo nano /usr/local/community-scripts/default.vars

# List all app defaults
ls /usr/local/community-scripts/defaults/

# Backup your defaults
cp -r /usr/local/community-scripts/defaults/ ~/defaults-backup/

# Set temporary override
export var_cpu=8
bash pihole-install.sh

# Create custom defaults
sudo tee /usr/local/community-scripts/defaults/custom.vars << 'EOF'
var_cpu=4
var_ram=2048
EOF
```

---

## Obtendo Ajuda

### Precisa de Mais Informações?

- 📖 [Documentação Principal](../../docs/)
- 🐛 [Reportar Problemas](https://github.com/community-scripts/ProxmoxVE/issues)
- 💬 [Discussões](https://github.com/community-scripts/ProxmoxVE/discussions)

### Comandos Úteis

```bash
# Check what variables are available
grep "var_" /path/to/app-install.sh | head -20

# Verify defaults syntax
cat /usr/local/community-scripts/default.vars

# Monitor installation with defaults
bash pihole-install.sh 2>&1 | tee installation.log
```

---

## Informações do Documento

| Campo | Valor |

|-------|-------| | Versão | 1.0 | | Última atualização | 28 de novembro de 2025 | | Status | Atual | | Licença | MIT |

---

**Boa configuração! 🚀**
