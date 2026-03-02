# Guia de Integração do error_handler.func

## Visão Geral

Este documento descreve como o `error_handler.func` se integra com outros componentes do projeto Proxmox Community Scripts, incluindo dependências, fluxo de dados e interface da API.

## Dependências

### Dependências Externas

#### Comandos Obrigatórios

- **Nenhum**: Implementação em Bash puro

#### Comandos Opcionais

- **Nenhum**: Sem dependências de comandos externos

### Dependências Internas

#### core.func

- **Finalidade**: Fornece variáveis ​​de cor para exibição de erros
- **Uso**: Usa as variáveis ​​de cor `RD`, `CL` e `YWB`
- **Integração**: Chamado automaticamente quando core.func é executado
- **Fluxo de Dados**: Variáveis ​​de cor → formatação da exibição de erros

## Pontos de Integração

### Com core.func

#### Integração de Execução Silenciosa

```bash
# core.func silent() function uses error_handler.func
silent() {
    local cmd="$*"
    local caller_line="${BASH_LINENO[0]:-unknown}"

    # Execute command
    "$@" >>"$SILENT_LOGFILE" 2>&1
    local rc=$?

    if [[ $rc -ne 0 ]]; then
        # Load error_handler.func if needed
        if ! declare -f explain_exit_code >/dev/null 2>&1; then
            source error_handler.func
        fi

        # Get error explanation
        local explanation
        explanation="$(explain_exit_code "$rc")"

        # Display error with explanation
        printf "\e[?25h"
        echo -e "\n${RD}[ERROR]${CL} in line ${RD}${caller_line}${CL}: exit code ${RD}${rc}${CL} (${explanation})"
        echo -e "${RD}Command:${CL} ${YWB}${cmd}${CL}\n"

        exit "$rc"
    fi
}
```

#### Uso de Variáveis ​​de Cor

```bash
# error_handler.func uses color variables from core.func
error_handler() {
    # ... error handling logic ...

    # Use color variables for error display
    echo -e "\n${RD}[ERROR]${CL} in line ${RD}${line_number}${CL}: exit code ${RD}${exit_code}${CL} (${explanation}): while executing command ${YWB}${command}${CL}\n"
}

on_interrupt() {
    echo -e "\n${RD}Interrupted by user (SIGINT)${CL}"
    exit 130
}

on_terminate() {
    echo -e "\n${RD}Terminated by signal (SIGTERM)${CL}"
    exit 143
}
```

### Com build.func

#### Erro na Criação do Contêiner Tratamento de erros

```bash
# build.func uses error_handler.func for container operations
source core.func
source error_handler.func

# Container creation with error handling
create_container() {
    # Set up error handling
    catch_errors

    # Container creation operations
    silent pct create "$CTID" "$TEMPLATE" \
        --hostname "$HOSTNAME" \
        --memory "$MEMORY" \
        --cores "$CORES"

    # If creation fails, error_handler provides explanation
}
```

#### Tratamento de erros no download do modelo

```bash
# build.func uses error_handler.func for template operations
download_template() {
    # Template download with error handling
    if ! silent curl -fsSL "$TEMPLATE_URL" -o "$TEMPLATE_FILE"; then
        # error_handler provides detailed explanation
        exit 222  # Template download failed
    fi
}
```

### Com tools.func

#### Tratamento de erros em operações de manutenção

```bash
# tools.func uses error_handler.func for maintenance operations
source core.func
source error_handler.func

# Maintenance operations with error handling
update_system() {
    catch_errors

    # System update operations
    silent apt-get update
    silent apt-get upgrade -y

    # Error handling provides explanations for failures
}

cleanup_logs() {
    catch_errors

    # Log cleanup operations
    silent find /var/log -name "*.log" -mtime +30 -delete

    # Error handling provides explanations for permission issues
}
```

### Com api.func

#### Tratamento de erros em operações de API

```bash
# api.func uses error_handler.func for API operations
source core.func
source error_handler.func

# API operations with error handling
api_call() {
    catch_errors

    # API call with error handling
    if ! silent curl -k -H "Authorization: PVEAPIToken=$API_TOKEN" \
        "$API_URL/api2/json/nodes/$NODE/lxc"; then
        # error_handler provides explanation for API failures
        exit 1
    fi
}
```

### Com install.func

#### Tratamento de erros no processo de instalação

```bash
# install.func uses error_handler.func for installation operations
source core.func
source error_handler.func

# Installation with error handling
install_package() {
    local package="$1"

    catch_errors

    # Package installation
    silent apt-get install -y "$package"

    # Error handling provides explanations for installation failures
}
```

### Com alpine-install.func

#### Tratamento de erros na instalação do Alpine

```bash
# alpine-install.func uses error_handler.func for Alpine operations
source core.func
source error_handler.func

# Alpine installation with error handling
install_alpine_package() {
    local package="$1"

    catch_errors

    # Alpine package installation
    silent apk add --no-cache "$package"

    # Error handling provides explanations for Alpine-specific failures
}
```

### Com alpine-tools.func

#### Tratamento de erros nas ferramentas do Alpine

```bash
# alpine-tools.func uses error_handler.func for Alpine tools
source core.func
source error_handler.func

# Alpine tools with error handling
alpine_tool_operation() {
    catch_errors

    # Alpine-specific tool operations
    silent alpine_command

    # Error handling provides explanations for Alpine tool failures
}
```

### Com passthrough.func

#### Tratamento de erros de passagem de hardware

```bash
# passthrough.func uses error_handler.func for hardware operations
source core.func
source error_handler.func

# Hardware passthrough with error handling
configure_gpu_passthrough() {
    catch_errors

    # GPU passthrough operations
    silent lspci | grep -i nvidia

    # Error handling provides explanations for hardware failures
}
```

### Com vm-core.func

#### Tratamento de erros de operações de VM

```bash
# vm-core.func uses error_handler.func for VM operations
source core.func
source error_handler.func

# VM operations with error handling
create_vm() {
    catch_errors

    # VM creation operations
    silent qm create "$VMID" \
        --name "$VMNAME" \
        --memory "$MEMORY" \
        --cores "$CORES"

    # Error handling provides explanations for VM creation failures
}
```

## Fluxo de dados

### Dados de entrada

#### Variáveis ​​de ambiente

- **`DEBUG_LOGFILE`**: Caminho para o arquivo de log de depuração para registro de erros
- **`SILENT_LOGFILE`**: Caminho para o arquivo de log de execução silenciosa
- **`STRICT_UNSET`**: Habilita a verificação estrita de variáveis ​​não definidas (0/1)
- **`lockfile`**: Caminho do arquivo de bloqueio para limpeza (definido pelo script de chamada)

#### Parâmetros da função

- **Códigos de saída**: Passados ​​para `explain_exit_code()` e `error_handler()`
- **Informações do comando**: Passadas para `error_handler()` para contexto
- **Informações de sinal**: Passadas para os manipuladores de sinal

#### Informações do sistema

- **Códigos de saída**: Obtidos da variável `$?`
- **Informações de comando**: Obtidas da variável `BASH_COMMAND`
- **Números de linha**: Obtidos da variável `BASH_LINENO[0]`
- **Informações de processo**: Obtidas de chamadas de sistema

### Processamento de dados

#### Processamento de código de erro

- **Classificação de código**: Categoriza os códigos de saída por tipo
- **Busca de explicação**: Mapeia os códigos para mensagens legíveis por humanos
- **Coleta de contexto**: Coleta informações de comando e linha
- **Preparação de log**: Formata as informações de erro para registro

#### Processamento de sinal

- **Detecção de sinal**: Identifica os sinais recebidos
- **Seleção de manipulador**: Escolhe o manipulador de sinal apropriado
- **Operações de limpeza**: Executa a limpeza necessária
- **Configuração de código de saída**: Define os códigos de saída apropriados

#### Processamento de log

- **Depuração** **Registrando**: Grava informações de erro no log de depuração
- **Integração de log silencioso**: Exibe o conteúdo do log silencioso
- **Formatação de log**: Formata as entradas de log para facilitar a leitura
- **Análise de log**: Fornece recursos de análise de log

### Dados de Saída

#### Informações de Erro

- **Mensagens de erro**: Explicações de erro legíveis para humanos
- **Informações de contexto**: Números de linha, comandos, carimbos de data/hora
- **Formatação de cores**: Códigos de cores ANSI para exibição no terminal
- **Conteúdo do log**: Trechos do log silencioso e informações de depuração

#### Estado do Sistema

- **Códigos de saída**: Retornados pelas funções
- **Arquivos de log**: Criados e atualizados para rastreamento de erros
- **Status de limpeza**: Remoção de arquivos de bloqueio e limpeza de processos
- **Tratamento de sinais**: Processamento de sinais adequado

## Interface da API

### Funções Públicas

#### Explicação de Erro

- **`explain_exit_code()`**: Converte códigos de saída em explicações
- **Parâmetros**: Código de saída para Explicação
- **Retorno**: String de explicação legível para humanos
- **Uso**: Chamada por `error_handler()` e outras funções

#### Tratamento de Erros

- **`error_handler()`**: Função principal de tratamento de erros
- **Parâmetros**: Código de saída (opcional), comando (opcional)
- **Retorno**: Nenhum (encerra com código de erro)
- **Uso**: Chamada por um interceptador de erro (ERR trap) ou manualmente

#### Tratamento de Sinais

- **`on_interrupt()`**: Trata sinais SIGINT
- **`on_terminate()`**: Trata sinais SIGTERM
- **`on_exit()`**: Lida com a limpeza de saída do script
- **Parâmetros**: Nenhum
- **Retorno**: Nenhum (encerra com código de sinal)
- **Uso**: Chamada por interceptadores de sinal

#### Inicialização

- **`catch_errors()`**: Inicializa o tratamento de erros
- **Parâmetros**: Nenhum
- **Retornos**: Nenhum
- **Uso**: Chamada para configurar as armadilhas de tratamento de erros

### Funções Internas

#### Nenhuma

- Todas as funções em error_handler.func são públicas
- Sem funções auxiliares internas
- Implementação direta de todas as funcionalidades

### Variáveis ​​Globais

#### Variáveis ​​de Configuração

- **`DEBUG_LOGFILE`**: Caminho do arquivo de log de depuração
- **`SILENT_LOGFILE`**: Caminho do arquivo de log silencioso
- **`STRICT_UNSET`**: Configuração do modo estrito
- **`lockfile`**: Caminho do arquivo de bloqueio

#### Variáveis ​​de Estado

- **`exit_code`**: Código de saída atual
- **`command`**: Comando que falhou
- **`line_number`**: Número da linha onde o erro ocorreu
- **`explicação`**: Texto explicativo do erro

## Padrões de Integração

### Padrão de Integração Padrão

```bash
#!/usr/bin/env bash
# Standard integration pattern

# 1. Source core.func first
source core.func

# 2. Source error_handler.func
source error_handler.func

# 3. Initialize error handling
catch_errors

# 4. Use silent execution
silent command

# 5. Errors are automatically handled
```

### Padrão de Integração Mínimo

```bash
#!/usr/bin/env bash
# Minimal integration pattern

source error_handler.func
catch_errors

# Basic error handling
command
```

### Padrão de Integração Avançado

```bash
#!/usr/bin/env bash
# Advanced integration pattern

source core.func
source error_handler.func

# Set up comprehensive error handling
export DEBUG_LOGFILE="/tmp/debug.log"
export SILENT_LOGFILE="/tmp/silent.log"
lockfile="/tmp/script.lock"
touch "$lockfile"

catch_errors
trap on_interrupt INT
trap on_terminate TERM
trap on_exit EXIT

# Advanced error handling
silent command
```

## Integração de Tratamento de Erros

### Tratamento Automático de Erros

- **ERR Trap**: Captura automaticamente falhas de comando
- **Explicação do Erro**: Fornece mensagens de erro legíveis
- **Informações de Contexto**: Mostra números de linha e comandos
- **Integração de Log**: Exibe conteúdo de log silencioso

### Tratamento Manual de Erros

- **Códigos de Erro Personalizados**: Usa códigos de erro personalizados do Proxmox
- **Recuperação de Erros**: Implementa lógica de repetição com tratamento de erros
- **Tratamento Condicional**: Tratamento diferente para diferentes tipos de erro
- **Análise de Erros**: Analisa padrões e tendências de erros

### Sinal Integração de Manipulação

- **Interrupção Suave**: Lida com Ctrl+C de forma suave
- **Encerramento Limpo**: Lida com sinais SIGTERM
- **Limpeza de Saída**: Limpa recursos ao sair do script
- **Gerenciamento de Arquivos de Bloqueio**: Remove arquivos de bloqueio ao sair

## Considerações de Desempenho

### Sobrecarga de Tratamento de Erros

- **Impacto Mínimo**: O tratamento de erros adiciona sobrecarga mínima
- **Configuração de Trap**: A configuração de trap é feita uma vez durante a inicialização
- **Processamento de Erros**: O processamento de erros é feito apenas em caso de falhas
- **Gravação de Log**: A gravação de log é feita apenas quando habilitada

### Uso de Memória

- **Pegada Mínima**: O manipulador de erros usa memória mínima
- **Reutilização de Variáveis**: Variáveis ​​globais reutilizadas entre funções
- **Sem Vazamentos de Memória**: A limpeza adequada evita vazamentos de memória
- **Processamento Eficiente**: Processamento eficiente de códigos de erro

### Velocidade de Execução

- **Detecção Rápida de Erros**: Detecção e tratamento rápidos de erros
- **Explicação Eficiente**: Busca rápida da explicação do código de erro
- **Atraso Mínimo**: Atraso mínimo no tratamento de erros
- **Saída Rápida**: Saída rápida em caso de erro

## Considerações de Segurança

### Divulgação de Informações de Erro

- **Divulgação Controlada**: Somente as informações de erro necessárias são exibidas
- **Segurança de Logs**: Os arquivos de log possuem as permissões apropriadas
- **Dados Sensíveis**: Dados sensíveis não são registrados
- **Sanitização de Erros**: As mensagens de erro são higienizadas

### Segurança no Tratamento de Sinais

- **Validação de Sinais**: Somente os sinais esperados são tratados
- **Segurança de Limpeza**: Limpeza segura de arquivos temporários
- **Segurança de Arquivos de Bloqueio**: Gerenciamento seguro de arquivos de bloqueio
- **Segurança de Processos**: Encerramento seguro de processos

### Segurança de Arquivos de Log

- **Permissões de Arquivos**: Os arquivos de log possuem as permissões apropriadas
- **Rotação de Logs**: Os arquivos de log são rotacionados para evitar o preenchimento do disco
- **Limpeza de Logs**: Arquivos de log antigos são limpos
- **Acesso a Logs**: Acesso a logs é controlado

## Considerações para Integração Futura

### Extensibilidade

- **Novos Códigos de Erro**: Fácil adição de novas explicações para códigos de erro
- **Manipuladores Personalizados**: Fácil adição de manipuladores de erro personalizados
- **Extensões de Sinal**: Fácil adição de novos manipuladores de sinal
- **Formatos de Log**: Fácil adição de novos formatos de log

### Compatibilidade

- **Versão do Bash**: Compatível com diferentes versões do Bash
- **Compatibilidade com o Sistema**: Compatível com diferentes sistemas
- **Compatibilidade com Scripts**: Compatível com diferentes tipos de scripts
- **Compatibilidade com Códigos de Erro**: Compatível com diferentes códigos de erro

### Desempenho

- **Otimização**: O tratamento de erros pode ser otimizado para melhor desempenho
- **Cache**: As explicações de erros podem ser armazenadas em cache para consultas mais rápidas
- **Processamento Paralelo**: O tratamento de erros pode ser paralelizado
- **Gerenciamento de Recursos**: Melhor gerenciamento de recursos para o tratamento de erros
