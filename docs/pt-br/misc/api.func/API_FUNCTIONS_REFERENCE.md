# Referência de Funções do api.func

## Visão Geral

Este documento fornece uma referência alfabética completa de todas as funções em `api.func`, incluindo parâmetros, dependências, exemplos de uso e tratamento de erros.

## Categorias de Funções

### Funções de Descrição de Erros

#### `get_error_description()`

**Finalidade**: Converter códigos de saída numéricos em explicações legíveis para humanos **Parâmetros**:

- `$1` - Código de saída a ser explicado **Retorno**: String com a explicação do erro em formato legível para humanos **Efeitos Colaterais**: Nenhum **Dependências**: Nenhuma **Variáveis ​​de Ambiente
  Utilizadas**: Nenhuma

**Códigos de Saída Suportados**:

- **Sistema Geral**: 0-9, 18, 22, 28, 35, 56, 60, 125-128, 129-143, 152, 255
- **Específico do LXC**: 100-101, 200-209
- **Docker**: 125

**Uso** Exemplo\*\*:

```bash
error_msg=$(get_error_description 127)
echo "Error 127: $error_msg"
# Output: Error 127: Command not found: Incorrect path or missing dependency.
```

**Exemplos de Códigos de Erro**:

```bash
get_error_description 0     # " " (space)
get_error_description 1     # "General error: An unspecified error occurred."
get_error_description 127   # "Command not found: Incorrect path or missing dependency."
get_error_description 200   # "LXC creation failed."
get_error_description 255   # "Unknown critical error, often due to missing permissions or broken scripts."
```

### Funções de Comunicação com a API

#### `post_to_api()`

**Finalidade**: Enviar dados de instalação do contêiner LXC para a API community-scripts.org **Parâmetros**: Nenhum (usa variáveis ​​de ambiente) **Retorno**: Nenhum **Efeitos Colaterais**:

- Envia uma requisição HTTP POST para a API
- Armazena a resposta na variável RESPONSE
- Requer o comando curl e conectividade de rede **Dependências**: Comando `curl` **Variáveis ​​de Ambiente Utilizadas**: `DIAGNOSTICS`, `RANDOM_UUID`, `CT_TYPE`, `DISK_SIZE`, `CORE_COUNT`, `RAM_SIZE`,
  `var_os`, `var_version`, `DISABLEIP6`, `NSAPP` `MÉTODO`

**Pré-requisitos**:

- O comando `curl` deve estar disponível
- `DIAGNOSTICS` deve estar definido como "yes"
- `RANDOM_UUID` deve estar definido e não vazio

**Endpoint da API**: `https://api.community-scripts.org/dev/upload`

**Estrutura do Payload JSON**:

```json
{
  "ct_type": 1,
  "type": "lxc",
  "disk_size": 8,
  "core_count": 2,
  "ram_size": 2048,
  "os_type": "debian",
  "os_version": "12",
  "disableip6": "true",
  "nsapp": "plex",
  "method": "install",
  "pve_version": "8.0",
  "status": "installing",
  "random_id": "uuid-string"
}
```

**Exemplo de Uso**:

```bash
export DIAGNOSTICS="yes"
export RANDOM_UUID="$(uuidgen)"
export CT_TYPE=1
export DISK_SIZE=8
export CORE_COUNT=2
export RAM_SIZE=2048
export var_os="debian"
export var_version="12"
export NSAPP="plex"
export METHOD="install"

post_to_api
```

#### `post_to_api_vm()`

**Finalidade**: Enviar dados de instalação da VM para a API community-scripts.org **Parâmetros**: Nenhum (usa variáveis ​​de ambiente) **Retorno**: Nenhum **Efeitos Colaterais**:

- Envia uma requisição HTTP POST para a API
- Armazena a resposta na variável RESPONSE
- Requer o comando `curl` e conectividade de rede **Dependências**: Comando `curl` Arquivo de diagnóstico **Variáveis ​​de ambiente utilizadas**: `DIAGNOSTICS`, `RANDOM_UUID`, `DISK_SIZE`,
  `CORE_COUNT`, `RAM_SIZE`, `var_os`, `var_version`, `NSAPP`, `METHOD`

**Pré-requisitos**:

- O arquivo `/usr/local/community-scripts/diagnostics` deve existir
- `DIAGNOSTICS` deve estar definido como "yes" no arquivo de diagnóstico
- O comando `curl` deve estar disponível
- `RANDOM_UUID` deve estar definido e não vazio

**Endpoint da API**: `https://api.community-scripts.org/dev/upload`

**Estrutura do payload JSON**:

```json
{
  "ct_type": 2,
  "type": "vm",
  "disk_size": 8,
  "core_count": 2,
  "ram_size": 2048,
  "os_type": "debian",
  "os_version": "12",
  "disableip6": "",
  "nsapp": "plex",
  "method": "install",
  "pve_version": "8.0",
  "status": "installing",
  "random_id": "uuid-string"
}
```

**Exemplo de uso**:

```bash
# Create diagnostics file
echo "DIAGNOSTICS=yes" > /usr/local/community-scripts/diagnostics

export RANDOM_UUID="$(uuidgen)"
export DISK_SIZE="8G"
export CORE_COUNT=2
export RAM_SIZE=2048
export var_os="debian"
export var_version="12"
export NSAPP="plex"
export METHOD="install"

post_to_api_vm
```

#### `post_update_to_api()`

**Finalidade**: Enviar o status de conclusão da instalação para a API do community-scripts.org **Parâmetros**:

- `$1` - Status ("sucesso" ou "falha", padrão: "falha")
- `$2` - Código de saída (padrão: 1) **Retorno**: Nenhum **Efeitos colaterais**:
- Envia uma solicitação HTTP POST para a API
- Define POST_UPDATE_DONE=true para evitar duplicatas
- Armazena a resposta na variável RESPONSE **Dependências**: Comando `curl`, `get_error_description()` **Variáveis ​​de ambiente utilizadas**: `DIAGNOSTICS`, `RANDOM_UUID`

**Pré-requisitos**:

- O comando `curl` deve estar disponível
- `DIAGNOSTICS` deve estar definido como "yes"
- `RANDOM_UUID` deve estar definido e não pode estar vazio
- POST_UPDATE_DONE deve ser falso (evita duplicatas)

**Endpoint da API**: `https://api.community-scripts.org/dev/upload/updatestatus`

**Estrutura do Payload JSON**:

```json
{
  "status": "success",
  "error": "Error description from get_error_description()",
  "random_id": "uuid-string"
}
```

**Exemplo de Uso**:

```bash
export DIAGNOSTICS="yes"
export RANDOM_UUID="$(uuidgen)"

# Report successful installation
post_update_to_api "success" 0

# Report failed installation
post_update_to_api "failed" 127
```

## Hierarquia de Chamadas de Função

### Fluxo de Comunicação da API

```
post_to_api()
├── Check curl availability
├── Check DIAGNOSTICS setting
├── Check RANDOM_UUID
├── Get PVE version
├── Create JSON payload
└── Send HTTP POST request

post_to_api_vm()
├── Check diagnostics file
├── Check curl availability
├── Check DIAGNOSTICS setting
├── Check RANDOM_UUID
├── Process disk size
├── Get PVE version
├── Create JSON payload
└── Send HTTP POST request

post_update_to_api()
├── Check POST_UPDATE_DONE flag
├── Check curl availability
├── Check DIAGNOSTICS setting
├── Check RANDOM_UUID
├── Determine status and exit code
├── Get error description
├── Create JSON payload
├── Send HTTP POST request
└── Set POST_UPDATE_DONE=true
```

### Fluxo de Descrição de Erros

```
get_error_description()
├── Match exit code
├── Return appropriate description
└── Handle unknown codes
```

## Referência de Códigos de Erro

### Erros Gerais do Sistema

| Código | Descrição |

|------|-------------|

| 0 | (espaço) | | 1 | Erro geral: Ocorreu um erro não especificado. | | 2 | Uso incorreto do shell ou argumentos de comando inválidos. | | 3 | Função não executada ou condição de shell inválida. | |
4 | Erro ao abrir um arquivo ou caminho inválido. | | 5 | Erro de E/S: Ocorreu uma falha de entrada/saída. | | 6 | Dispositivo ou endereço inexistente. | | 7 | Memória insuficiente ou esgotamento de
recursos. | | 8 | Arquivo não executável ou formato de arquivo inválido. | | 9 | Falha na execução do processo filho. | | 18 | Falha na conexão com um servidor remoto. | | 22 | Argumento inválido ou
conexão de rede com falha. | | 28 | Sem espaço disponível no dispositivo. | | 35 | Tempo limite excedido ao estabelecer uma conexão. | | 56 | Conexão TLS com falha. | | 60 | Erro no certificado SSL. |

### Erros de Execução de Comandos

| Código | Descrição |

|------|-------------| | 125 | Erro do Docker: O contêiner não pôde ser iniciado. | | 126 | Comando não executável: Permissões incorretas ou dependências ausentes. | | 127 | Comando não encontrado:
Caminho incorreto ou dependência ausente. | | 128 | Sinal de saída inválido, por exemplo, comando Git incorreto. |

### Erros de Sinal

| Código | Descrição |

|------|-------------| | 129 | Sinal 1 (SIGHUP): Processo encerrado devido a desconexão. | | 130 | Sinal 2 (SIGINT): Encerramento manual via Ctrl+C. | | 132 | Sinal 4 (SIGILL): Instrução de máquina
ilegal. | | 133 | Sinal 5 (SIGTRAP): Erro de depuração ou sinal de ponto de interrupção inválido. | | 134 | Sinal 6 (SIGABRT): O programa se encerrou. | | 135 | Sinal 7 (SIGBUS): Erro de memória,
endereço de memória inválido. | | 137 | Sinal 9 (SIGKILL): Processo encerrado à força (OOM-killer ou 'kill -9'). | | 139 | Sinal 11 (SIGSEGV): Falha de segmentação, possivelmente devido a acesso
inválido a ponteiro. | | 141 | Sinal 13 (SIGPIPE): Pipe fechado inesperadamente. | | 143 | Sinal 15 (SIGTERM): Processo encerrado normalmente. | | 152 | Sinal 24 (SIGXCPU): Limite de tempo da CPU
excedido. |

### Erros Específicos do LXC

| Código | Descrição |

------|-------------| | 100 | Erro de instalação do LXC: Erro inesperado em create_lxc.sh. | | 101 | Erro de instalação do LXC: Nenhuma conexão de rede detectada. | | 200 | Falha na criação do LXC. |
| 201 | Erro do LXC: Classe de armazenamento inválida. | | 202 | O usuário cancelou o menu em create_lxc.sh. | | 203 | CTID não definido em create_lxc.sh. | | 204 | PCT_OSTYPE não definido em
create_lxc.sh. | | 205 | O CTID não pode ser menor que 100 em create_lxc.sh. | | 206 | CTID já em uso em create_lxc.sh. | | 207 | Modelo não encontrado em create_lxc.sh. | | 208 | Erro ao baixar o
modelo em create_lxc.sh. | | 209 | A criação do contêiner falhou, mas o modelo está intacto em create_lxc.sh. |

### Outros erros

| Código | Descrição |

|------|-------------| | 255 | Erro crítico desconhecido, geralmente devido à falta de permissões ou scripts corrompidos. | | \* | Código de erro desconhecido (exit_code). |

## Dependências de Variáveis ​​de Ambiente

### Variáveis ​​Obrigatórias

- **`DIAGNOSTICS`**: Habilitar/desabilitar o relatório de diagnóstico ("sim"/"não")
- **`RANDOM_UUID`**: Identificador único para rastreamento

### Variáveis ​​Opcionais

- **`CT_TYPE`**: Tipo de contêiner (1 para LXC, 2 para VM)
- **`DISK_SIZE`**: Tamanho do disco em GB (ou GB com sufixo 'G' para VM)
- **`CORE_COUNT`**: Número de núcleos da CPU
- **`RAM_SIZE`**: Tamanho da RAM em MB
- **`var_os`**: Tipo de sistema operacional
- **`var_version`**: Versão do SO
- **`DISABLEIP6`**: Configuração para desabilitar IPv6
- **`NSAPP`**: Nome do aplicativo de namespace
- **`METHOD`**: Método de instalação

### Variáveis ​​Internas

- **`POST_UPDATE_DONE`**: Impede atualizações de status duplicadas
- **`API_URL`**: Endpoint da API de scripts da comunidade
- **`JSON_PAYLOAD`**: Payload da requisição à API
- **`RESPONSE`**: Resposta da API
- **`DISK_SIZE_API`**: Tamanho do disco processado para a API de VM

## Padrões de Tratamento de Erros

### Erros de Comunicação da API

- Todas as funções da API lidam com falhas do curl de forma adequada
- Erros de rede não bloqueiam o processo de instalação
- Pré-requisitos ausentes causam retorno antecipado
- Atualizações duplicadas são impedidas

### Descrição de Erros

- Códigos de erro desconhecidos retornam uma mensagem genérica
- Todos os códigos de erro são tratados com instruções case
- A mensagem de fallback inclui o código de erro real

### Validação de Pré-requisitos

- Verificar a disponibilidade do curl antes das chamadas à API
- Validar a configuração DIAGNOSTICS
- Garantir que RANDOM_UUID esteja definido
- Verificar atualizações duplicadas

## Exemplos de Integração

### Com build.func

```bash
#!/usr/bin/env bash
source core.func
source api.func
source build.func

# Set up API reporting
export DIAGNOSTICS="yes"
export RANDOM_UUID="$(uuidgen)"

# Report installation start
post_to_api

# Container creation...
# ... build.func code ...

# Report completion
if [[ $? -eq 0 ]]; then
    post_update_to_api "success" 0
else
    post_update_to_api "failed" $?
fi
```

### Com vm-core.func

```bash
#!/usr/bin/env bash
source core.func
source api.func
source vm-core.func

# Set up API reporting
export DIAGNOSTICS="yes"
export RANDOM_UUID="$(uuidgen)"

# Report VM installation start
post_to_api_vm

# VM creation...
# ... vm-core.func code ...

# Report completion
post_update_to_api "success" 0
```

### Com error_handler.func

```bash
#!/usr/bin/env bash
source core.func
source error_handler.func
source api.func

# Use error descriptions
error_code=127
error_msg=$(get_error_description $error_code)
echo "Error $error_code: $error_msg"

# Report error to API
post_update_to_api "failed" $error_code
```

## Boas Práticas

### Uso da API

1. Sempre verifique os pré-requisitos antes de chamar a API
2. Use identificadores únicos para rastreamento
3. Lide com falhas da API de forma adequada
4. Não bloqueie a instalação em caso de falhas da API

### Relatório de Erros

1. Use códigos de erro apropriados
2. Forneça descrições de erro significativas
3. Relate casos de sucesso e falha
4. Evite atualizações de status duplicadas

### Relatório de Diagnóstico

1. Respeite as configurações de privacidade do usuário
2. Envie dados somente quando o diagnóstico estiver ativado
3. Use identificadores de rastreamento anônimos
4. Inclua informações relevantes do sistema

### Tratamento de Erros

1. Lide com códigos de erro desconhecidos de forma adequada
2. Forneça mensagens de erro alternativas
3. Inclua o código de erro em erros desconhecidos mensagens de erro
4. Use um formato de mensagem de erro consistente
