# Referência Técnica: Arquitetura do Sistema de Configuração

> **Para Desenvolvedores e Usuários Avançados**

> _Analisando em detalhes como o sistema de configurações e valores padrão funciona_

---

## Sumário

1. [Arquitetura do Sistema](#system-architecture)
2. [Especificações de Formato de Arquivo](#file-format-specifications)
3. [Referência de Funções](#function-reference)
4. [Precedência de Variáveis](#variable-precedence)
5. [Diagramas de Fluxo de Dados](#data-flow-diagrams)
6. [Modelo de Segurança](#security-model)
7. [Detalhes de Implementação](#implementation-details)

---

## Arquitetura do Sistema

### Visão Geral dos Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                    Installation Script                      │
│  (pihole-install.sh, docker-install.sh, etc.)               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│                   build.func Library                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  variables()                                         │   │
│  │  - Initialize NSAPP, var_install, etc.               │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  install_script()                                    │   │
│  │  - Display mode menu                                 │   │
│  │  - Route to appropriate workflow                     │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  base_settings()                                     │   │
│  │  - Apply built-in defaults                           │   │
│  │  - Read environment variables (var_*)                │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  load_vars_file()                                    │   │
│  │  - Safe file parsing (NO source/eval)                │   │
│  │  - Whitelist validation                              │   │
│  │  - Value sanitization                                │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  default_var_settings()                              │   │
│  │  - Load user defaults                                │   │
│  │  - Display summary                                   │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  maybe_offer_save_app_defaults()                     │   │
│  │  - Offer to save current settings                    │   │
│  │  - Handle updates vs. new saves                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│           Configuration Files (on Disk)                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  /usr/local/community-scripts/default.vars           │   │
│  │  (User global defaults)                              │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  /usr/local/community-scripts/defaults/*.vars        │   │
│  │  (App-specific defaults)                             │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Especificações de Formato de Arquivo

### Valores Padrão do Usuário: `default.vars`

**Localização**: `/usr/local/community-scripts/default.vars`

**Tipo MIME**: `text/plain`

**Codificação**: UTF-8 (sem BOM)

**Especificação de Formato**:

```
# File Format: Simple key=value pairs
# Purpose: Store global user defaults
# Security: Sanitized values, whitelist validation

# Comments and blank lines are ignored
# Line format: var_name=value
# No spaces around the equals sign
# String values do not need quoting (but may be quoted)

[CONTENT]
var_cpu=4
var_ram=2048
var_disk=20
var_hostname=mydefault
var_brg=vmbr0
var_gateway=192.168.1.1
```

**Gramática Formal**:

```
FILE       := (BLANK_LINE | COMMENT_LINE | VAR_LINE)*
BLANK_LINE := \n
COMMENT_LINE := '#' [^\n]* \n
VAR_LINE   := VAR_NAME '=' VAR_VALUE \n
VAR_NAME   := 'var_' [a-z_]+
VAR_VALUE  := [^\n]*  # Any printable characters except newline
```

**Restrições**:

| Restrição                       | Valor                             |
| ------------------------------- | --------------------------------- |
| Tamanho máximo do arquivo       | 64 KB                             |
| Comprimento máximo da linha     | 1024 bytes                        |
| Número máximo de variáveis ​​   | 100                               |
| Nomes de variáveis ​​permitidos | `var_[a-z_]+`                     |
| Validação de valores            | Lista de permissões + Sanitização |

**Exemplo de Arquivo Válido**:

```bash
# Global User Defaults
# Created: 2024-11-28

# Resource defaults
var_cpu=4
var_ram=2048
var_disk=20

# Network defaults
var_brg=vmbr0
var_gateway=192.168.1.1
var_mtu=1500
var_vlan=100

# System defaults
var_timezone=Europe/Berlin
var_hostname=default-container

# Storage
var_container_storage=local
var_template_storage=local

# Security
var_ssh=yes
var_protection=0
var_unprivileged=1
```

### Configurações Padrão do Aplicativo: `<app>.vars`

**Localização**: `/usr/local/community-scripts/defaults/<nome_do_aplicativo>.vars`

**Formato**: Idêntico a `default.vars`

**Convenção de Nomenclatura**: `<nsapp>.vars`

- `nsapp` = nome do aplicativo em minúsculas, sem espaços
- Exemplos:

- `pihole` → `pihole.vars`

- `opnsense` → `opnsense.vars`

- `docker compose` → `dockercompose.vars`

**Exemplo de Configurações Padrão do Aplicativo**:

```bash
# App-specific defaults for PiHole (pihole)
# Generated on 2024-11-28T15:32:00Z
# These override user defaults when installing pihole

var_unprivileged=1
var_cpu=2
var_ram=1024
var_disk=10
var_brg=vmbr0
var_net=veth
var_gateway=192.168.1.1
var_hostname=pihole
var_timezone=Europe/Berlin
var_container_storage=local
var_template_storage=local
var_tags=dns,pihole
```

---

## Referência de Funções

### `load_vars_file()`

**Finalidade**: Carregar variáveis ​​de arquivos .vars com segurança, sem usar `source` ou `eval`

**Assinatura**:

```bash
load_vars_file(filepath)
```

**Parâmetros**:

| Parâmetro          | Tipo   | Obrigatório | Exemplo                                     |
| ------------------ | ------ | ----------- | ------------------------------------------- |
| caminho_do_arquivo | String | Sim         | `/usr/local/community-scripts/default.vars` |

**Retorno**:

- `0` em caso de sucesso
- `1` em caso de erro (arquivo ausente, erro de análise, etc.)

**Efeitos Colaterais no Ambiente**:

- Define todas as variáveis ​​`var_*` analisadas como variáveis ​​de ambiente
- NÃO remove variáveis ​​se o arquivo estiver ausente (seguro)
- NÃO afeta outras variáveis

**Padrão de Implementação**:

```bash
load_vars_file() {
  local file="$1"

  # File must exist
  [ -f "$file" ] || return 0

  # Parse line by line (not with source/eval)
  local line key val
  while IFS='=' read -r key val || [ -n "$key" ]; do
    # Skip comments and empty lines
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$key" ]] && continue

    # Validate key is in whitelist
    _is_whitelisted_key "$key" || continue

    # Sanitize and export value
    val="$(_sanitize_value "$val")"
    [ $? -eq 0 ] && export "$key=$val"
  done < "$file"

  return 0
}
```

**Exemplos de Uso**:

```bash
# Load user defaults
load_vars_file "/usr/local/community-scripts/default.vars"

# Load app-specific defaults
load_vars_file "$(get_app_defaults_path)"

# Check if successful
if load_vars_file "$vars_path"; then
  echo "Settings loaded successfully"
else
  echo "Failed to load settings"
fi

# Values are now available as variables
echo "Using $var_cpu cores"
echo "Allocating ${var_ram} MB RAM"
```

---

### `get_app_defaults_path()`

**Objetivo**: Obtém o caminho completo para o arquivo de configurações padrão específico do aplicativo

**Assinatura**:

```bash
get_app_defaults_path()
```

**Parâmetros**: Nenhum

**Retorno**:

- String: Caminho completo para as configurações padrão do aplicativo Arquivo

**Implementação**:

```bash
get_app_defaults_path() {
  local n="${NSAPP:-${APP,,}}"
  echo "/usr/local/community-scripts/defaults/${n}.vars"
}
```

**Exemplos de Uso**:

```bash
# Get app defaults path
app_defaults="$(get_app_defaults_path)"
echo "App defaults at: $app_defaults"

# Check if app defaults exist
if [ -f "$(get_app_defaults_path)" ]; then
  echo "App defaults available"
fi

# Load app defaults
load_vars_file "$(get_app_defaults_path)"
```

---

### `default_var_settings()`

**Finalidade**: Carregar e exibir as configurações globais padrão do usuário

**Assinatura**:

```bash
default_var_settings()
```

**Parâmetros**: Nenhum

**Retorno**:

- `0` em caso de sucesso
- `1` em caso de erro

**Fluxo de Trabalho**:

```
1. Find default.vars location
   (usually /usr/local/community-scripts/default.vars)

2. Create if missing

3. Load variables from file

4. Map var_verbose → VERBOSE variable

5. Call base_settings (apply to container config)

6. Call echo_default (display summary)
```

**Padrão de Implementação**:

```bash
default_var_settings() {
  local VAR_WHITELIST=(
    var_apt_cacher var_apt_cacher_ip var_brg var_cpu var_disk var_fuse var_gpu
    var_gateway var_hostname var_ipv6_method var_mac var_mtu
    var_net var_ns var_pw var_ram var_tags var_tun var_unprivileged
    var_verbose var_vlan var_ssh var_ssh_authorized_key
    var_container_storage var_template_storage
  )

  # Ensure file exists
  _ensure_default_vars

  # Find and load
  local dv="$(_find_default_vars)"
  load_vars_file "$dv"

  # Map verbose flag
  if [[ -n "${var_verbose:-}" ]]; then
    case "${var_verbose,,}" in
      1 | yes | true | on) VERBOSE="yes" ;;
      *) VERBOSE="${var_verbose}" ;;
    esac
  fi

  # Apply and display
  base_settings "$VERBOSE"
  echo_default
}
```

---

### `maybe_offer_save_app_defaults()`

**Finalidade**: Oferecer a opção de salvar as configurações atuais como específicas do aplicativo Configurações padrão

**Assinatura**:

```bash
maybe_offer_save_app_defaults()
```

**Parâmetros**: Nenhum

**Retornos**: Nenhum (apenas efeitos colaterais)

**Comportamento**:

1. Após a conclusão da instalação avançada
2. Oferece ao usuário: "Salvar como Configurações Padrão do Aplicativo para <APP>?"

3. Se sim:

- Salva em `/usr/local/community-scripts/defaults/<app>.vars`

- Inclui apenas variáveis ​​permitidas

- Salva os valores padrão anteriores (se existirem)

4. Se não:

- Nenhuma ação é tomada

**Fluxo**:

```bash
maybe_offer_save_app_defaults() {
  local app_vars_path="$(get_app_defaults_path)"

  # Build current settings from memory
  local new_tmp="$(_build_current_app_vars_tmp)"

  # Check if already exists
  if [ -f "$app_vars_path" ]; then
    # Show diff and ask: Update? Keep? View Diff?
    _show_app_defaults_diff_menu "$new_tmp" "$app_vars_path"
  else
    # New defaults - just save
    if whiptail --yesno "Save as App Defaults for $APP?" 10 60; then
      mv "$new_tmp" "$app_vars_path"
      chmod 644 "$app_vars_path"
    fi
  fi
}
```

---

### `_sanitize_value()`

**Objetivo**: Remove caracteres/padrões perigosos dos valores de configuração

**Assinatura**:

```bash
_sanitize_value(value)
```

**Parâmetros**:

| Parâmetro | Tipo   | Obrigatório |
| --------- | ------ | ----------- |
| valor     | String | Sim         |

**Retornos**:

- `0` (sucesso) + valor sanitizado na saída padrão
- `1` (falha) + nada se perigoso

**Padrões Perigosos**:

| Padrão   | Ameaça                    | Exemplo              |
| -------- | ------------------------- | -------------------- |
| `$(...)` | Substituição de comando   | `$(rm -rf /)`        |
| `` ` ``  | Substituição de comando   | `` `whoami` ``       |
| `;`      | Separador de comando      | `valor; rm -rf /`    |
| `&`      | Execução em segundo plano | `valor & malicioso`  |
| `<(`     | Substituição de processo  | `<(cat /etc/passwd)` |

**Implementação**:

```bash
_sanitize_value() {
  case "$1" in
  *'$('* | *'`'* | *';'* | *'&'* | *'<('*)
    echo ""
    return 1  # Reject dangerous value
    ;;
  esac
  echo "$1"
  return 0
}
```

**Exemplos de uso**:

```bash
# Safe value
_sanitize_value "192.168.1.1"  # Returns: 192.168.1.1 (status: 0)

# Dangerous value
_sanitize_value "$(whoami)"     # Returns: (empty) (status: 1)

# Usage in code
if val="$(_sanitize_value "$user_input")"; then
  export var_hostname="$val"
else
  msg_error "Invalid value: contains dangerous characters"
fi
```

---

### `_is_whitelisted_key()`

**Finalidade**: Verificar se o nome da variável está na lista de permissões

**Assinatura**:

```bash
_is_whitelisted_key(key)
```

**Parâmetros**:

| Parâmetro | Tipo   | Obrigatório | Exemplo   |
| --------- | ------ | ----------- | --------- |
| chave     | String | Sim         | `var_cpu` |

**Retornos**:

- `0` se a chave estiver na lista de permissões
- `1` se a chave NÃO estiver na lista de permissões

**Implementação**:

```bash
_is_whitelisted_key() {
  local k="$1"
  local w
  for w in "${VAR_WHITELIST[@]}"; do
    [ "$k" = "$w" ] && return 0
  done
  return 1
}
```

**Exemplos de Uso**:

```bash
# Check if variable can be saved
if _is_whitelisted_key "var_cpu"; then
  echo "var_cpu can be saved"
fi

# Reject unknown variables
if ! _is_whitelisted_key "var_custom"; then
  msg_error "var_custom is not supported"
fi
```

---

## Precedência de Variáveis

### Ordem de Carregamento

Quando um contêiner está sendo criado, as variáveis ​​são resolvidas nesta ordem:

```
Step 1: Read ENVIRONMENT VARIABLES
   ├─ Check if var_cpu is already set in shell environment
   ├─ Check if var_ram is already set
   └─ ...all var_* variables

Step 2: Load APP-SPECIFIC DEFAULTS
   ├─ Check if /usr/local/community-scripts/defaults/pihole.vars exists
   ├─ Load all var_* from that file
   └─ These override built-ins but NOT environment variables

Step 3: Load USER GLOBAL DEFAULTS
   ├─ Check if /usr/local/community-scripts/default.vars exists
   ├─ Load all var_* from that file
   └─ These override built-ins but NOT app-specific

Step 4: Use BUILT-IN DEFAULTS
   └─ Hardcoded in script (lowest priority)
```

### Exemplos de Precedência

**Exemplo 1: Variável de Ambiente Prevalece**

```bash
# Shell environment has highest priority
$ export var_cpu=16
$ bash pihole-install.sh

# Result: Container gets 16 cores
# (ignores app defaults, user defaults, built-ins)
```

**Exemplo 2: Valores Padrão do Aplicativo Substituindo os Valores Padrão do Usuário**

```bash
# User Defaults: var_cpu=4
# App Defaults: var_cpu=2
$ bash pihole-install.sh

# Result: Container gets 2 cores
# (app-specific setting takes precedence)
```

**Exemplo 3: Todos os Valores Padrão Ausentes (Integrados)** Usado)\*\*

```bash
# No environment variables set
# No app defaults file
# No user defaults file
$ bash pihole-install.sh

# Result: Uses built-in defaults
# (var_cpu might be 2 by default)
```

### Implementação em Código

```bash
# Typical pattern in build.func

base_settings() {
  # Priority 1: Environment variables (already set if export used)
  CT_TYPE=${var_unprivileged:-"1"}          # Use existing or default

  # Priority 2: Load app defaults (may override above)
  if [ -f "$(get_app_defaults_path)" ]; then
    load_vars_file "$(get_app_defaults_path)"
  fi

  # Priority 3: Load user defaults
  if [ -f "/usr/local/community-scripts/default.vars" ]; then
    load_vars_file "/usr/local/community-scripts/default.vars"
  fi

  # Priority 4: Apply built-in defaults (lowest)
  CORE_COUNT=${var_cpu:-"${APP_CPU_DEFAULT:-2}"}
  RAM_SIZE=${var_ram:-"${APP_RAM_DEFAULT:-1024}"}

  # Result: var_cpu has been set through precedence chain
}
```

---

## Diagramas de Fluxo de Dados

### Fluxo de Instalação: Configurações Avançadas

```
┌──────────────┐
│  Start Script│
└──────┬───────┘
       │
       v
┌──────────────────────────────┐
│ Display Installation Mode    │
│ Menu (5 options)             │
└──────┬───────────────────────┘
       │ User selects "Advanced Settings"
       v
┌──────────────────────────────────┐
│ Call: base_settings()            │
│ (Apply built-in defaults)        │
└──────┬───────────────────────────┘
       │
       v
┌──────────────────────────────────┐
│ Call: advanced_settings()        │
│ (Show 19-step wizard)            │
│ - Ask CPU, RAM, Disk, Network... │
└──────┬───────────────────────────┘
       │
       v
┌──────────────────────────────────┐
│ Show Summary                     │
│ Review all chosen values         │
└──────┬───────────────────────────┘
       │ User confirms
       v
┌──────────────────────────────────┐
│ Create Container                 │
│ Using current variable values    │
└──────┬───────────────────────────┘
       │
       v
┌──────────────────────────────────┐
│ Installation Complete            │
└──────┬───────────────────────────┘
       │
       v
┌──────────────────────────────────────┐
│ Offer: Save as App Defaults?         │
│ (Save current settings)              │
└──────┬───────────────────────────────┘
       │
       ├─ YES → Save to defaults/<app>.vars
       │
       └─ NO  → Exit
```

### Fluxo de Resolução de Variáveis

```
CONTAINER CREATION STARTED
         │
         v
   ┌─────────────────────┐
   │ Check ENVIRONMENT   │
   │ for var_cpu, var_..│
   └──────┬──────────────┘
          │ Found? Use them (Priority 1)
          │ Not found? Continue...
          v
   ┌──────────────────────────┐
   │ Load App Defaults        │
   │ /defaults/<app>.vars     │
   └──────┬───────────────────┘
          │ File exists? Parse & load (Priority 2)
          │ Not found? Continue...
          v
   ┌──────────────────────────┐
   │ Load User Defaults       │
   │ /default.vars            │
   └──────┬───────────────────┘
          │ File exists? Parse & load (Priority 3)
          │ Not found? Continue...
          v
   ┌──────────────────────────┐
   │ Use Built-in Defaults    │
   │ (Hardcoded values)       │
   └──────┬───────────────────┘
          │
          v
   ┌──────────────────────────┐
   │ All Variables Resolved   │
   │ Ready for container      │
   │ creation                 │
   └──────────────────────────┘
```

---

## Modelo de Segurança

### Modelo de Ameaças

| Ameaça                            | Mitigação                                              |
| --------------------------------- | ------------------------------------------------------ |
| **Execução Arbitrária de Código** | Sem `source` ou `eval`; somente análise manual         |
| **Injeção de Variáveis**          | Lista de permissões de nomes de variáveis ​​permitidos |
| **Substituição de Comandos**      | `_sanitize_value()` bloqueia `$()`, crases, etc.       |
| **Exploração de Caminho**         | Arquivos bloqueados em `/usr/local/community-scripts/` |
| **Elevação de Permissões**        | Arquivos criados com permissões restritas              |
| **Divulgação de Informações**     | Variáveis ​​sensíveis não registradas                  |

### Controles de Segurança

#### 1. Validação de Entrada

```bash
# Only specific variables allowed
if ! _is_whitelisted_key "$key"; then
  skip_this_variable
fi

# Values sanitized
if ! val="$(_sanitize_value "$value")"; then
  reject_entire_line
fi
```

#### 2. Análise Segura de Arquivos

```bash
# ❌ DANGEROUS (OLD)
source /path/to/config.conf
# Could execute: rm -rf / or any code

# ✅ SAFE (NEW)
load_vars_file "/path/to/config.conf"
# Only reads var_name=value pairs, no execution
```

#### 3. Lista de Permissões

```bash
# Only these variables can be configured
var_cpu, var_ram, var_disk, var_brg, ...
var_hostname, var_pw, var_ssh, ...

# NOT allowed:
var_malicious, var_hack, custom_var, ...
```

#### 4. Restrições de Valores

```bash
# No command injection patterns
if [[ "$value" =~ ($|`|;|&|<\() ]]; then
  reject_value
fi
```

---

## Detalhes da Implementação

### Módulo: `build.func`

**Ordem de Carregamento** (em scripts reais):

1. `#!/usr/bin/env bash` - Shebang
2. `source /dev/stdin <<<$(curl ... api.func)` - Funções da API
3. `source /dev/stdin <<<$(curl ... build.func)` - Funções de compilação
4. `variables()` - Inicializar variáveis
5. `check_root()` - Verificação de segurança
6. `install_script()` - Fluxo principal

**Seções principais**:

```bash
# Section 1: Initialization & Variables
- variables()
- NSAPP, var_install, INTEGER pattern, etc.

# Section 2: Storage Management
- storage_selector()
- ensure_storage_selection_for_vars_file()

# Section 3: Base Settings
- base_settings()          # Apply defaults to all var_*
- echo_default()           # Display current settings

# Section 4: Variable Loading
- load_vars_file()         # Safe parsing
- _is_whitelisted_key()    # Validation
- _sanitize_value()        # Threat mitigation

# Section 5: Defaults Management
- default_var_settings()   # Load user defaults
- get_app_defaults_path()  # Get app defaults path
- maybe_offer_save_app_defaults()  # Save option

# Section 6: Installation Flow
- install_script()         # Main entry point
- advanced_settings()      # 20-step wizard
```

### Padrões de Regex usados

| Padrão                 | Finalidade              | Exemplo de correspondência |
| ---------------------- | ----------------------- | -------------------------- | --- | ------- | --------------------- | ----------------------- |
| `^[0-9]+([.][0-9]+)?$` | Validação de inteiro    | `4`, `192.168`             |
| `^var_[a-z_]+$`        | Nome da variável        | `var_cpu`, `var_ssh`       |
| `*'$('*`               | Substituição de comando | `$(whoami)`                |     | `*\`\*` | Substituição de crase | `` `cat /etc/passwd` `` |

---

## Apêndice: Referência de Migração

### Padrão Antigo (Obsoleto)

```bash
# ❌ OLD: config-file.func
source config-file.conf          # Executes arbitrary code
if [ "$USE_DEFAULTS" = "yes" ]; then
  apply_settings_directly
fi
```

### Novo Padrão (Atual)

```bash
# ✅ NEW: load_vars_file()
if load_vars_file "$(get_app_defaults_path)"; then
  echo "Settings loaded securely"
fi
```

### Mapeamento de Funções

| Antigo           | Novo                              | Local      |
| ---------------- | --------------------------------- | ---------- |
| `read_config()`  | `load_vars_file()`                | build.func |
| `write_config()` | `_build_current_app_vars_tmp()`   | build.func |
| Nenhum           | `maybe_offer_save_app_defaults()` | build.func |
| Nenhum           | `get_app_defaults_path()`         | build.func |

---

**Fim da Referência Técnica**
