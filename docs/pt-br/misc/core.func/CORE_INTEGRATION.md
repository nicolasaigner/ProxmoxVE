# Guia de Integração do core.func

## Visão Geral

Este documento descreve como o `core.func` se integra com outros componentes do projeto Proxmox Community Scripts, incluindo dependências, fluxo de dados e interface da API.

## Dependências

### Dependências Externas

#### Comandos Obrigatórios

- **`pveversion`**: Verificação da versão do Proxmox VE
- **`dpkg`**: Detecção da arquitetura
- **`ps`**: Detecção de processos e shells
- **`id`**: Verificação do ID do usuário
- **`curl`**: Download de arquivos de cabeçalho
- **`swapon`**: Verificação do status do swap
- **`dd`**: Criação do arquivo de swap
- **`mkswap`**: Formatação do arquivo de swap

#### Comandos Opcionais

- **`tput`**: Controle do terminal (instalado se ausente)
- **`apk`**: Gerenciador de pacotes Alpine
- **`apt-get`**: Gerenciador de pacotes Debian

### Dependências Internas

#### error_handler.func

- **Propósito**: Fornece explicações de códigos de erro para execução silenciosa
- **Uso**: Carregado automaticamente quando `silent()` encontra erros
- **Integração**: Chamada através da função `explain_exit_code()`
- **Fluxo de Dados**: Código de erro → explicação → exibição ao usuário

## Pontos de Integração

### Com build.func

#### Validação do Sistema

```bash
# build.func uses core.func for system checks
source core.func
pve_check
arch_check
shell_check
root_check
```

#### Interface do Usuário

```bash
# build.func uses core.func for UI elements
msg_info "Creating container..."
msg_ok "Container created successfully"
msg_error "Container creation failed"
```

#### Execução Silenciosa

```bash
# build.func uses core.func for command execution
silent pct create "$CTID" "$TEMPLATE" \
    --hostname "$HOSTNAME" \
    --memory "$MEMORY" \
    --cores "$CORES"
```

### Com tools.func

#### Funções Utilitárias

```bash
# tools.func uses core.func utilities
source core.func

# System checks
pve_check
root_check

# UI elements
msg_info "Running maintenance tasks..."
msg_ok "Maintenance completed"
```

#### Tratamento de Erros

```bash
# tools.func uses core.func for error handling
if silent systemctl restart service; then
    msg_ok "Service restarted"
else
    msg_error "Service restart failed"
fi
```

### Com api.func

#### Validação do Sistema

```bash
# api.func uses core.func for system checks
source core.func
pve_check
root_check
```

#### API Operações

```bash
# api.func uses core.func for API calls
msg_info "Connecting to Proxmox API..."
if silent curl -k -H "Authorization: PVEAPIToken=$API_TOKEN" \
    "$API_URL/api2/json/nodes/$NODE/lxc"; then
    msg_ok "API connection successful"
else
    msg_error "API connection failed"
fi
```

### Com error_handler.func

#### Explicações de erros

```bash
# error_handler.func provides explanations for core.func
explain_exit_code() {
    local code="$1"
    case "$code" in
        1) echo "General error" ;;
        2) echo "Misuse of shell builtins" ;;
        126) echo "Command invoked cannot execute" ;;
        127) echo "Command not found" ;;
        128) echo "Invalid argument to exit" ;;
        *) echo "Unknown error code" ;;
    esac
}
```

### Com install.func

#### Processo de instalação

```bash
# install.func uses core.func for installation
source core.func

# System checks
pve_check
root_check

# Installation steps
msg_info "Installing packages..."
silent apt-get update
silent apt-get install -y package

msg_ok "Installation completed"
```

### Com alpine-install.func

#### Operações específicas do Alpine

```bash
# alpine-install.func uses core.func for Alpine operations
source core.func

# Alpine detection
if is_alpine; then
    msg_info "Detected Alpine Linux"
    silent apk add --no-cache package
else
    msg_info "Detected Debian-based system"
    silent apt-get install -y package
fi
```

### Com alpine-tools.func

#### Utilitários do Alpine

```bash
# alpine-tools.func uses core.func for Alpine tools
source core.func

# Alpine-specific operations
if is_alpine; then
    msg_info "Running Alpine-specific operations..."
    # Alpine tools logic
    msg_ok "Alpine operations completed"
fi
```

### Com passthrough.func

#### Passagem de hardware

```bash
# passthrough.func uses core.func for hardware operations
source core.func

# System checks
pve_check
root_check

# Hardware operations
msg_info "Configuring GPU passthrough..."
if silent lspci | grep -i nvidia; then
    msg_ok "NVIDIA GPU detected"
else
    msg_warn "No NVIDIA GPU found"
fi
```

### Com vm-core.func

#### Operações da VM

```bash
# vm-core.func uses core.func for VM management
source core.func

# System checks
pve_check
root_check

# VM operations
msg_info "Creating virtual machine..."
silent qm create "$VMID" \
    --name "$VMNAME" \
    --memory "$MEMORY" \
    --cores "$CORES"

msg_ok "Virtual machine created"
```

## Dados Fluxo

### Dados de Entrada

#### Variáveis ​​de Ambiente

- **`APP`**: Nome do aplicativo para exibição no cabeçalho
- **`APP_TYPE`**: Tipo de aplicativo (ct/vm) para caminhos de cabeçalho
- **`VERBOSE`**: Configuração do modo detalhado
- **`var_os`**: Tipo de SO para detecção do Alpine
- **`PCT_OSTYPE`**: Variável alternativa para o tipo de SO
- **`var_verbose`**: Configuração alternativa para o modo detalhado
- **`var_full_verbose`**: Configuração do modo de depuração

#### Parâmetros de Comando

- **Argumentos de função**: Passados ​​para funções individuais
- **Argumentos de comando**: Passados ​​para a função `silent()`
- **Entrada do usuário**: Coletada por meio de comandos `read`

### Processando Dados

#### Informações do Sistema

- **Versão do Proxmox**: Analisada a partir da saída de `pveversion`
- **Arquitetura**: Obtida de `dpkg` --print-architecture`
- **Tipo de shell**: Detectado a partir das informações do processo
- **ID do usuário**: Obtido com `id -u`
- **Conexão SSH**: Detectada a partir do ambiente `SSH_CLIENT`

#### Estado da interface do usuário

- **Rastreamento de mensagens**: Matriz associativa `MSG_INFO_SHOWN`
- **Estado do indicador de carregamento**: Variáveis ​​`SPINNER_PID` e `SPINNER_MSG`
- **Estado do terminal**: Posição do cursor e modo de exibição

#### Informações de erro

- **Códigos de saída**: Capturados da execução do comando
- **Saída de log**: Redirecionada para arquivos de log temporários
- **Explicações de erro**: Obtidas de error_handler.func

### Dados de saída

#### Interface do usuário

- **Mensagens coloridas**: Códigos de cores ANSI para a saída do terminal
- **Ícones**: Representações simbólicas para diferentes tipos de mensagens
- **Indicadores de carregamento**: Animação de progresso Indicadores
- **Texto formatado**: Formatação consistente de mensagens

#### Estado do Sistema

- **Códigos de saída**: Retornados pelas funções
- **Arquivos de log**: Criados para execução silenciosa
- **Configuração**: Configurações do sistema modificadas
- **Estado do processo**: Processos de carregamento e limpeza

## Superfície da API

### Funções Públicas

#### Validação do Sistema

- **`pve_check()`**: Validação da versão do Proxmox VE
- **`arch_check()`**: Validação da arquitetura
- **`shell_check()`**: Validação do shell
- **`root_check()`**: Validação de privilégios
- **`ssh_check()`**: Aviso de conexão SSH

#### Interface do Usuário

- **`msg_info()`**: Mensagens informativas
- **`msg_ok()`**: Mensagens de sucesso
- **`msg_error()`**: Mensagens de erro
- **`msg_warn()`**: Mensagens de aviso
- **`msg_custom()`**: Mensagens personalizadas
- **`msg_debug()`**: Mensagens de depuração

#### Controle do Spinner

- **`spinner()`**: Iniciar animação do spinner
- **`stop_spinner()`**: Parar o spinner e limpar
- **`clear_line()`**: Limpar a linha atual do terminal

#### Execução silenciosa

- **`silent()`**: Executar comandos com tratamento de erros

#### Funções Utilitárias

- **`is_alpine()`**: Detecção do Alpine Linux
- **`is_verbose_mode()`**: Detecção do modo verboso
- **`fatal()`**: Tratamento de erros fatais
- **`ensure_tput()`**: Configuração do controle do terminal

#### Gerenciamento de Cabeçalhos

- **`get_header()`**: Baixar cabeçalhos do aplicativo
- **`header_info()`**: Exibir informações do cabeçalho

#### Gerenciamento do Sistema

- **`check_or_create_swap()`**: Gerenciamento do arquivo de swap

### Funções Internas

#### Inicialização

- **`load_functions()`**: Carregador de funções
- **`color()`**: Configuração de cores
- **`formatting()`**: Configuração de formatação
- **`icons()`**: Configuração de ícones
- **`default_vars()`**: Variáveis ​​padrão
- **`set_std_mode()`**: Modo padrão Configuração

#### Gerenciamento de Cores

- **`color_spinner()`**: Cores do seletor

### Variáveis ​​Globais

#### Variáveis ​​de Cor

- **`YW`**, **`YWB`**, **`BL`**, **`RD`**, **`BGN`**, **`GN`**, **`DGN`**, **`CL`**: Códigos de cores
- **`CS_YW`**, **`CS_YWB`**, **`CS_CL`**: Cores do seletor

#### Variáveis ​​de Formatação

- **`BFR`**, **`BOLD`**, **`HOLD`**, **`TAB`**, **`TAB3`**: Auxiliares de formatação

#### Variáveis ​​de Ícone

- **`CM`**, **`CROSS`**, **`INFO`**, **`OS`**, **`OSVERSION`**, etc.: Ícones de mensagem

#### Configuração Variáveis

- **`RETRY_NUM`**, **`RETRY_EVERY`**: Configurações de repetição
- **`STD`**: Configuração do modo padrão
- **`SILENT_LOGFILE`**: Caminho do arquivo de log

#### Variáveis ​​de Estado

- **`_CORE_FUNC_LOADED`**: Prevenção de carregamento
- **`__FUNCTIONS_LOADED`**: Prevenção de carregamento de função
- **`SPINNER_PID`**, **`SPINNER_MSG`**: Estado do indicador de carregamento
- **`MSG_INFO_SHOWN`**: Rastreamento de mensagens

## Padrões de Integração

### Padrão de Integração Padrão

```bash
#!/usr/bin/env bash
# Standard integration pattern

# 1. Source core.func first
source core.func

# 2. Run system checks
pve_check
arch_check
shell_check
root_check

# 3. Set up error handling
trap 'stop_spinner' EXIT INT TERM

# 4. Use UI functions
msg_info "Starting operation..."

# 5. Use silent execution
silent command

# 6. Show completion
msg_ok "Operation completed"
```

### Padrão de Integração Mínima

```bash
#!/usr/bin/env bash
# Minimal integration pattern

source core.func
pve_check
root_check

msg_info "Running operation..."
silent command
msg_ok "Operation completed"
```

### Padrão de Integração Avançada

```bash
#!/usr/bin/env bash
# Advanced integration pattern

source core.func

# System validation
pve_check
arch_check
shell_check
root_check
ssh_check

# Error handling
trap 'stop_spinner' EXIT INT TERM

# Verbose mode handling
if is_verbose_mode; then
    msg_info "Verbose mode enabled"
fi

# OS-specific operations
if is_alpine; then
    msg_info "Alpine Linux detected"
    # Alpine-specific logic
else
    msg_info "Debian-based system detected"
    # Debian-specific logic
fi

# Operation execution
msg_info "Starting operation..."
if silent command; then
    msg_ok "Operation succeeded"
else
    msg_error "Operation failed"
    exit 1
fi
```

## Integração de Tratamento de Erros

### Silenciosa Fluxo de Erro de Execução

```
silent() command
├── Execute command
├── Capture output to log
├── Check exit code
├── If error:
│   ├── Load error_handler.func
│   ├── Get error explanation
│   ├── Display error details
│   ├── Show log excerpt
│   └── Exit with error code
└── If success: Continue
```

### Fluxo de Erro de Verificação do Sistema

```
System Check Function
├── Check system state
├── If valid: Return 0
└── If invalid:
    ├── Display error message
    ├── Show fix instructions
    ├── Sleep for user to read
    └── Exit with error code
```

## Considerações de Desempenho

### Otimização de Carregamento

- **Carregamento Único**: `_CORE_FUNC_LOADED` impede o carregamento múltiplo
- **Carregamento de Funções**: `__FUNCTIONS_LOADED` impede o carregamento múltiplo de funções
- **Carregamento Preguiçoso**: Funções carregadas somente quando necessário

### Uso de Memória

- **Pegada Mínima**: Funções principais usam memória mínima
- **Reutilização de Variáveis**: Variáveis ​​globais reutilizadas entre funções
- **Limpeza**: Processos do Spinner são limpos ao final

### Velocidade de Execução

- **Verificações Rápidas**: Verificações do sistema são otimizadas para velocidade
- **Spinners Eficientes**: A animação do Spinner usa CPU mínima
- **Mensagens Rápidas**: Funções de mensagem otimizadas para desempenho

## Segurança Considerações

### Elevação de Privilégios

- **Verificação de Root**: Garante que o script seja executado com privilégios suficientes
- **Verificação de Shell**: Valida o ambiente de shell
- **Validação de Processo**: Verifica o uso de sudo no processo pai

### Validação de Entrada

- **Verificação de Parâmetros**: Funções validam os parâmetros de entrada
- **Tratamento de Erros**: O tratamento adequado de erros evita falhas
- **Execução Segura**: Execução silenciosa com tratamento adequado de erros

### Proteção do Sistema

- **Validação de Versão**: Garante a compatibilidade com a versão do Proxmox
- **Verificação de Arquitetura**: Impede a execução em sistemas não suportados
- **Aviso de SSH**: Alerta sobre o uso de SSH externo

## Considerações para Integração Futura

### Extensibilidade

- **Grupos de Funções**: Fácil adição de novos grupos de funções
- **Tipos de Mensagens**: Fácil adição de novos tipos de mensagens
- **Verificações do Sistema**: Fácil adição de novas verificações do sistema

### Compatibilidade

- **Versão **Suporte\*\*: Fácil adição de novas versões do Proxmox
- **Suporte a SO**: Fácil adição de novos sistemas operacionais
- **Suporte a arquitetura**: Fácil adição de novas arquiteturas

### Desempenho

- **Otimização**: As funções podem ser otimizadas para melhor desempenho
- **Cache**: Os resultados podem ser armazenados em cache para operações repetidas
- **Paralelização**: As operações podem ser paralelizadas quando apropriado
