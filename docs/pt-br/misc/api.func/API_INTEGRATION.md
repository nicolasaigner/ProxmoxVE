# Guia de Integração do api.func

## Visão Geral

Este documento descreve como o `api.func` se integra com outros componentes do projeto Proxmox Community Scripts, incluindo dependências, fluxo de dados e interface da API.

## Dependências

### Dependências Externas

#### Comandos Obrigatórios

- **`curl`**: Cliente HTTP para comunicação com a API
- **`uuidgen`**: Gera identificadores únicos (opcional, outros métodos podem ser usados)

#### Comandos Opcionais

- **Nenhum**: Sem outras dependências de comandos externos

### Dependências Internas

#### Variáveis ​​de Ambiente de Outros Scripts

- **build.func**: Fornece variáveis ​​para criação de contêineres
- **vm-core.func**: Fornece variáveis ​​para criação de máquinas virtuais
- **core.func**: Fornece variáveis ​​de informações do sistema
- **Scripts de Instalação**: Fornecem variáveis ​​específicas da aplicação

## Pontos de Integração

### Com build.func

#### Relatórios de Contêineres LXC

```bash
# build.func uses api.func for container reporting
source core.func
source api.func
source build.func

# Set up API reporting
export DIAGNOSTICS="yes"
export RANDOM_UUID="$(uuidgen)"

# Container creation with API reporting
create_container() {
    # Set container parameters
    export CT_TYPE=1
    export DISK_SIZE="$var_disk"
    export CORE_COUNT="$var_cpu"
    export RAM_SIZE="$var_ram"
    export var_os="$var_os"
    export var_version="$var_version"
    export NSAPP="$APP"
    export METHOD="install"

    # Report installation start
    post_to_api

    # Container creation using build.func
    # ... build.func container creation logic ...

    # Report completion
    if [[ $? -eq 0 ]]; then
        post_update_to_api "success" 0
    else
        post_update_to_api "failed" $?
    fi
}
```

#### Integração de Relatórios de Erros

```bash
# build.func uses api.func for error reporting
handle_container_error() {
    local exit_code=$1
    local error_msg=$(get_error_description $exit_code)

    echo "Container creation failed: $error_msg"
    post_update_to_api "failed" $exit_code
}
```

### Com vm-core.func

#### Relatório de Instalação da VM

```bash
# vm-core.func uses api.func for VM reporting
source core.func
source api.func
source vm-core.func

# Set up VM API reporting
mkdir -p /usr/local/community-scripts
echo "DIAGNOSTICS=yes" > /usr/local/community-scripts/diagnostics

export RANDOM_UUID="$(uuidgen)"

# VM creation with API reporting
create_vm() {
    # Set VM parameters
    export DISK_SIZE="${var_disk}G"
    export CORE_COUNT="$var_cpu"
    export RAM_SIZE="$var_ram"
    export var_os="$var_os"
    export var_version="$var_version"
    export NSAPP="$APP"
    export METHOD="install"

    # Report VM installation start
    post_to_api_vm

    # VM creation using vm-core.func
    # ... vm-core.func VM creation logic ...

    # Report completion
    post_update_to_api "success" 0
}
```

### Com core.func

#### Integração de Informações do Sistema

```bash
# core.func provides system information for api.func
source core.func
source api.func

# Get system information for API reporting
get_system_info_for_api() {
    # Get PVE version using core.func utilities
    local pve_version=$(pveversion | awk -F'[/ ]' '{print $2}')

    # Set API parameters
    export var_os="$var_os"
    export var_version="$var_version"

    # Use core.func error handling with api.func reporting
    if silent apt-get update; then
        post_update_to_api "success" 0
    else
        post_update_to_api "failed" $?
    fi
}
```

### Com error_handler.func

#### Integração da Descrição de Erros

```bash
# error_handler.func uses api.func for error descriptions
source core.func
source error_handler.func
source api.func

# Enhanced error handler with API reporting
enhanced_error_handler() {
    local exit_code=${1:-$?}
    local command=${2:-${BASH_COMMAND:-unknown}}

    # Get error description from api.func
    local error_msg=$(get_error_description $exit_code)

    # Display error information
    echo "Error $exit_code: $error_msg"
    echo "Command: $command"

    # Report error to API
    export DIAGNOSTICS="yes"
    export RANDOM_UUID="$(uuidgen)"
    post_update_to_api "failed" $exit_code

    # Use standard error handler
    error_handler $exit_code $command
}
```

### Com install.func

#### Relatório do Processo de Instalação

```bash
# install.func uses api.func for installation reporting
source core.func
source api.func
source install.func

# Installation with API reporting
install_package_with_reporting() {
    local package="$1"

    # Set up API reporting
    export DIAGNOSTICS="yes"
    export RANDOM_UUID="$(uuidgen)"
    export NSAPP="$package"
    export METHOD="install"

    # Report installation start
    post_to_api

    # Package installation using install.func
    if install_package "$package"; then
        echo "$package installed successfully"
        post_update_to_api "success" 0
        return 0
    else
        local exit_code=$?
        local error_msg=$(get_error_description $exit_code)
        echo "$package installation failed: $error_msg"
        post_update_to_api "failed" $exit_code
        return $exit_code
    fi
}
```

### Com alpine-install.func

#### Relatório de Instalação do Alpine

```bash
# alpine-install.func uses api.func for Alpine reporting
source core.func
source api.func
source alpine-install.func

# Alpine installation with API reporting
install_alpine_with_reporting() {
    local app="$1"

    # Set up API reporting
    export DIAGNOSTICS="yes"
    export RANDOM_UUID="$(uuidgen)"
    export NSAPP="$app"
    export METHOD="install"
    export var_os="alpine"

    # Report Alpine installation start
    post_to_api

    # Alpine installation using alpine-install.func
    if install_alpine_app "$app"; then
        echo "Alpine $app installed successfully"
        post_update_to_api "success" 0
        return 0
    else
        local exit_code=$?
        local error_msg=$(get_error_description $exit_code)
        echo "Alpine $app installation failed: $error_msg"
        post_update_to_api "failed" $exit_code
        return $exit_code
    fi
}
```

### Com alpine-tools.func

#### Relatório de Ferramentas do Alpine

```bash
# alpine-tools.func uses api.func for Alpine tools reporting
source core.func
source api.func
source alpine-tools.func

# Alpine tools with API reporting
run_alpine_tool_with_reporting() {
    local tool="$1"

    # Set up API reporting
    export DIAGNOSTICS="yes"
    export RANDOM_UUID="$(uuidgen)"
    export NSAPP="alpine-tools"
    export METHOD="tool"

    # Report tool execution start
    post_to_api

    # Run Alpine tool using alpine-tools.func
    if run_alpine_tool "$tool"; then
        echo "Alpine tool $tool executed successfully"
        post_update_to_api "success" 0
        return 0
    else
        local exit_code=$?
        local error_msg=$(get_error_description $exit_code)
        echo "Alpine tool $tool failed: $error_msg"
        post_update_to_api "failed" $exit_code
        return $exit_code
    fi
}
```

### Com passthrough.func

#### Passagem de Hardware Relatórios

```bash
# passthrough.func uses api.func for hardware reporting
source core.func
source api.func
source passthrough.func

# Hardware passthrough with API reporting
configure_passthrough_with_reporting() {
    local hardware_type="$1"

    # Set up API reporting
    export DIAGNOSTICS="yes"
    export RANDOM_UUID="$(uuidgen)"
    export NSAPP="passthrough"
    export METHOD="hardware"

    # Report passthrough configuration start
    post_to_api

    # Configure passthrough using passthrough.func
    if configure_passthrough "$hardware_type"; then
        echo "Hardware passthrough configured successfully"
        post_update_to_api "success" 0
        return 0
    else
        local exit_code=$?
        local error_msg=$(get_error_description $exit_code)
        echo "Hardware passthrough failed: $error_msg"
        post_update_to_api "failed" $exit_code
        return $exit_code
    fi
}
```

### Com tools.func

#### Relatórios de Operações de Manutenção

```bash
# tools.func uses api.func for maintenance reporting
source core.func
source api.func
source tools.func

# Maintenance operations with API reporting
run_maintenance_with_reporting() {
    local operation="$1"

    # Set up API reporting
    export DIAGNOSTICS="yes"
    export RANDOM_UUID="$(uuidgen)"
    export NSAPP="maintenance"
    export METHOD="tool"

    # Report maintenance start
    post_to_api

    # Run maintenance using tools.func
    if run_maintenance_operation "$operation"; then
        echo "Maintenance operation $operation completed successfully"
        post_update_to_api "success" 0
        return 0
    else
        local exit_code=$?
        local error_msg=$(get_error_description $exit_code)
        echo "Maintenance operation $operation failed: $error_msg"
        post_update_to_api "failed" $exit_code
        return $exit_code
    fi
}
```

## Fluxo de Dados

### Dados de Entrada

#### Variáveis ​​de Ambiente de Outros Scripts

- **`CT_TYPE`**: Tipo de contêiner (1 para LXC, 2 para VM)
- **`DISK_SIZE`**: Tamanho do disco em GB
- **`CORE_COUNT`**: Número de núcleos da CPU
- **`RAM_SIZE`**: Tamanho da RAM em MB
- **`var_os`**: Tipo de sistema operacional
- **`var_version`**: Versão do SO
- **`DISABLEIP6`**: Configuração para desativar IPv6
- **`NSAPP`**: Nome do aplicativo de namespace
- **`METHOD`**: Método de instalação
- **`DIAGNOSTICS`**: Ativar/desativar relatórios de diagnóstico
- **`RANDOM_UUID`**: Identificador único para rastreamento

#### Parâmetros da Função

- **Códigos de saída**: Passados ​​para `get_error_description()` e `post_update_to_api()`
- **Informações de status**: Passadas para `post_update_to_api()`
- **Endpoints da API**: Codificados nas funções

#### Informações do Sistema

- **Versão do PVE**: Obtida pelo comando `pveversion`
- **Processamento do tamanho do disco**: Processado para a API da VM (remove o sufixo 'G')
- **Códigos de erro**: Obtidos dos códigos de saída dos comandos

### Processamento de Dados

#### Preparação da Requisição à API

- **Criação do payload JSON**: Formata os dados para consumo pela API
- **Validação de dados**: Garante que os campos obrigatórios estejam presentes
- **Tratamento de erros**: Lida com dados ausentes ou inválidos
- **Configuração do tipo de conteúdo**: Define os cabeçalhos HTTP apropriados

#### Processamento de Erros

- **Mapeamento de códigos de erro**: Mapeia Códigos numéricos para descrições
- **Formatação de mensagens de erro**: Formatar descrições de erros
- **Tratamento de erros desconhecidos**: Lidar com códigos de erro não reconhecidos
- **Mensagens de fallback**: Fornecer mensagens de erro padrão

#### Comunicação com a API

- **Preparação de requisições HTTP**: Preparar comandos curl
- **Tratamento de respostas**: Capturar códigos de resposta HTTP
- **Tratamento de erros**: Lidar com erros de rede e da API
- **Prevenção de duplicatas**: Impedir atualizações de status duplicadas

### Dados de saída

#### Comunicação com a API

- **Requisições HTTP**: Enviadas para a API community-scripts.org
- **Códigos de resposta**: Capturados das respostas da API
- **Informações de erro**: Reportadas à API
- **Atualizações de status**: Enviadas à API

#### Informações de erro

- **Descrições de erro**: Mensagens de erro legíveis para humanos
- **Códigos de erro**: Mapeados para descrições
- **Informações de contexto**: Contexto e detalhes do erro
- **Mensagens de fallback**: Mensagens de erro padrão

#### Estado do sistema

- **POST_UPDATE_DONE**: Impede atualizações duplicadas
- **RESPONSE**: Armazena a resposta da API
- **JSON_PAYLOAD**: Armazena os dados formatados da API
- **API_URL**: Armazena o endpoint da API

## Interface da API

### Funções Públicas

#### Descrição de Erros

- **`get_error_description()`**: Converte códigos de saída em explicações
- **Parâmetros**: Código de saída a ser explicado
- **Retornos**: String de explicação legível
- **Uso**: Chamada por outras funções e scripts

#### Comunicação com a API

- **`post_to_api()`**: Envia dados de instalação do LXC
- **`post_to_api_vm()`**: Envia dados de instalação da VM
- **`post_update_to_api()`**: Envia atualizações de status
- **Parâmetros**: Status e código de saída (para atualizações)
- **Retornos**: Nenhum
- **Uso**: Chamado por scripts de instalação

### Funções Internas

#### Nenhuma

- Todas as funções em api.func são públicas
- Sem funções auxiliares internas
- Implementação direta de todas as funcionalidades

### Variáveis ​​Globais

#### Variáveis ​​de Configuração

- **`DIAGNOSTICS`**: Configuração de relatório de diagnóstico
- **`RANDOM_UUID`**: Identificador de rastreamento exclusivo
- **`POST_UPDATE_DONE`**: Prevenção de atualizações duplicadas

#### Variáveis ​​de Dados

- **`CT_TYPE`**: Tipo de contêiner
- **`DISK_SIZE`**: Tamanho do disco
- **`CORE_COUNT`**: Número de núcleos da CPU
- **`RAM_SIZE`**: Tamanho da RAM
- **`var_os`**: Sistema operacional
- **`var_version`**: Versão do SO
- **`DISABLEIP6`**: Configuração de IPv6
- **`NSAPP`**: Namespace do aplicativo
- **`METHOD`**: Método de instalação

#### Internas Variáveis

- **`API_URL`**: URL do endpoint da API
- **`JSON_PAYLOAD`**: Payload da requisição à API
- **`RESPONSE`**: Resposta da API
- **`DISK_SIZE_API`**: Tamanho do disco processado para a API da VM

## Padrões de Integração

### Padrão de Integração Padrão

```bash
#!/usr/bin/env bash
# Standard integration pattern

# 1. Source core.func first
source core.func

# 2. Source api.func
source api.func

# 3. Set up API reporting
export DIAGNOSTICS="yes"
export RANDOM_UUID="$(uuidgen)"

# 4. Set application parameters
export NSAPP="$APP"
export METHOD="install"

# 5. Report installation start
post_to_api

# 6. Perform installation
# ... installation logic ...

# 7. Report completion
post_update_to_api "success" 0
```

### Padrão de Integração Mínimo

```bash
#!/usr/bin/env bash
# Minimal integration pattern

source api.func

# Basic error reporting
export DIAGNOSTICS="yes"
export RANDOM_UUID="$(uuidgen)"

# Report failure
post_update_to_api "failed" 127
```

### Padrão de Integração Avançado

```bash
#!/usr/bin/env bash
# Advanced integration pattern

source core.func
source api.func
source error_handler.func

# Set up comprehensive API reporting
export DIAGNOSTICS="yes"
export RANDOM_UUID="$(uuidgen)"
export CT_TYPE=1
export DISK_SIZE=8
export CORE_COUNT=2
export RAM_SIZE=2048
export var_os="debian"
export var_version="12"
export METHOD="install"

# Enhanced error handling with API reporting
enhanced_error_handler() {
    local exit_code=${1:-$?}
    local command=${2:-${BASH_COMMAND:-unknown}}

    local error_msg=$(get_error_description $exit_code)
    echo "Error $exit_code: $error_msg"

    post_update_to_api "failed" $exit_code
    error_handler $exit_code $command
}

trap 'enhanced_error_handler' ERR

# Advanced operations with API reporting
post_to_api
# ... operations ...
post_update_to_api "success" 0
```

## Integração de Tratamento de Erros

### Relatório Automático de Erros

- **Descrições de Erros**: Fornece mensagens de erro legíveis para humanos
- **Integração com a API**: Reporta erros à API community-scripts.org
- **Rastreamento de Erros**: Rastreia padrões de erro para melhoria do projeto
- **Dados de Diagnóstico**: Contribui para análises de uso anônimas

### Relatório Manual de Erros

- **Personalizado** **Códigos de Erro**: Use códigos de erro apropriados para diferentes cenários
- **Contexto do Erro**: Forneça informações de contexto para os erros
- **Atualizações de Status**: Relate casos de sucesso e falha
- **Análise de Erros**: Analise padrões e tendências de erros

### Erros de Comunicação da API

- **Falhas de Rede**: Lide com falhas de comunicação da API de forma adequada
- **Pré-requisitos Ausentes**: Verifique os pré-requisitos antes das chamadas da API
- **Prevenção de Duplicatas**: Evite atualizações de status duplicadas
- **Recuperação de Erros**: Lide com erros da API sem bloquear a instalação

## Considerações de Desempenho

### Sobrecarga de Comunicação da API

- **Impacto Mínimo**: As chamadas da API adicionam sobrecarga mínima
- **Assíncrono**: As chamadas da API não bloqueiam o processo de instalação
- **Tratamento de Erros**: Falhas da API não afetam a instalação
- **Opcional**: O relatório da API é opcional e pode ser desativado

### Uso de Memória

- **Pegada Mínima**: As funções da API usam memória mínima
- **Reutilização de Variáveis**: Variáveis ​​globais reutilizadas entre funções
- **Sem Memória** **Vazamentos**: A limpeza adequada previne vazamentos de memória
- **Processamento Eficiente**: Criação eficiente de payloads JSON

### Velocidade de Execução

- **Chamadas de API Rápidas**: Comunicação rápida com a API
- **Processamento Eficiente de Erros**: Processamento rápido de códigos de erro
- **Atraso Mínimo**: Atraso mínimo nas operações da API
- **Não Bloqueante**: As chamadas de API não bloqueiam a instalação

## Considerações de Segurança

### Privacidade de Dados

- **Relatórios Anônimos**: Somente dados anônimos são enviados
- **Sem Dados Sensíveis**: Nenhuma informação sensível é transmitida
- **Controle do Usuário**: Os usuários podem desativar os relatórios de diagnóstico
- **Minimização de Dados**: Somente os dados necessários são enviados

### Segurança da API

- **HTTPS**: A comunicação com a API utiliza protocolos seguros
- **Validação de Dados**: Os dados da API são validados antes do envio
- **Tratamento de Erros**: Os erros da API são tratados com segurança
- **Sem Credenciais**: Nenhuma credencial de autenticação é enviada

### Segurança de Rede

- **Comunicação Segura**: Utiliza protocolos HTTP seguros
- **Tratamento de Erros**: Erros de rede são tratados de forma adequada
- **Sem Vazamento de Dados**: Nenhum dado sensível é vazado
- **Endpoints Seguros**: Utiliza endpoints de API confiáveis

## Considerações para Integração Futura

### Extensibilidade

- **Novos Endpoints de API**: Fácil adição de novos endpoints de API
- **Dados Adicionais**: Fácil adição de novos campos de dados
- **Códigos de Erro**: Fácil adição de novas descrições de códigos de erro
- **Versões da API**: Fácil suporte a novas versões da API

### Compatibilidade

- **Versionamento da API**: Compatível com diferentes versões da API
- **Formato de Dados**: Compatível com diferentes formatos de dados
- **Códigos de Erro**: Compatível com diferentes sistemas de códigos de erro
- **Protocolos de Rede**: Compatível com diferentes protocolos de rede

### Desempenho

- **Otimização**: A comunicação da API pode ser otimizada
- **Cache**: As respostas da API podem ser armazenadas em cache
- **Operações em Lote**: Múltiplas operações podem ser executadas simultaneamente Processamento em lote
- **Processamento assíncrono**: As chamadas de API podem ser feitas de forma assíncrona.
