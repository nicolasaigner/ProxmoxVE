# Referência de Funções do error_handler.func

## Visão Geral

Este documento fornece uma referência alfabética completa de todas as funções em `error_handler.func`, incluindo parâmetros, dependências, exemplos de uso e tratamento de erros.

## Categorias de Funções

### Funções de Explicação de Erros

#### `explain_exit_code()`

**Finalidade**: Converter códigos de saída numéricos em explicações legíveis para humanos **Parâmetros**:

- `$1` - Código de saída a ser explicado **Retorno**: String com a explicação do erro em formato legível para humanos **Efeitos Colaterais**: Nenhum **Dependências**: Nenhuma **Variáveis ​​de Ambiente
  Utilizadas**: Nenhuma

**Códigos de Saída Suportados**:

- **Genérico/Shell**: 1, 2, 126, 127, 128, 130, 137, 139, 143
- **Gerenciador de Pacotes**: 100, 101, 255
- **Node.js**: 243, 245, 246, 247, 248, 249, 254
- **Python**: 210, 211, 212
- **PostgreSQL**: 231, 232, 233, 234
- **MySQL/MariaDB**: 241, 242, 243, 244
- **MongoDB**: 251, 252, 253, 254
- **Proxmox Custom**: 200, 203, 204, 205, 209, 210, 214, 215, 216, 217, 220, 222, 223, 231

**Exemplo de Uso**:

```bash
explanation=$(explain_exit_code 127)
echo "Error 127: $explanation"
# Output: Error 127: Command not found
```

**Exemplos de Códigos de Erro**:

```bash
explain_exit_code 1    # "General error / Operation not permitted"
explain_exit_code 126  # "Command invoked cannot execute (permission problem?)"
explain_exit_code 127  # "Command not found"
explain_exit_code 130  # "Terminated by Ctrl+C (SIGINT)"
explain_exit_code 200  # "Custom: Failed to create lock file"
explain_exit_code 999  # "Unknown error"
```

### Tratamento de Erros Funções

#### `error_handler()`

**Propósito**: Principal manipulador de erros acionado por um trap ERR ou chamada manual **Parâmetros**:

- `$1` - Código de saída (opcional, padrão $?)
- `$2` - Comando que falhou (opcional, padrão BASH_COMMAND) **Retorno**: Nenhum (encerra com código de erro) **Efeitos Colaterais**:
- Exibe informações detalhadas do erro
- Registra o erro em um arquivo de depuração, se habilitado
- Exibe o conteúdo do log silencioso, se disponível
- Encerra com o código de erro original **Dependências**: `explain_exit_code()` **Variáveis ​​de Ambiente Utilizadas**: `DEBUG_LOGFILE`, `SILENT_LOGFILE`

**Exemplo de Uso**:

```bash
# Automatic error handling via ERR trap
set -e
trap 'error_handler' ERR

# Manual error handling
error_handler 127 "command_not_found"
```

**Informações de Erro Exibidas**:

- Mensagem de erro com código de cores
- Número da linha onde o erro ocorreu
- Código de saída Explicação
- Comando que falhou
- Conteúdo do log silencioso (últimas 20 linhas)
- Entrada do log de depuração (se habilitado)

### Funções de Tratamento de Sinais

#### `on_interrupt()`

**Propósito**: Tratar sinais SIGINT (Ctrl+C) de forma adequada **Parâmetros**: Nenhum **Retorno**: Nenhum (encerra com código 130) **Efeitos Colaterais**:

- Exibe mensagem de interrupção
- Encerra com código SIGINT (130) **Dependências**: Nenhuma **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Exemplo de Uso**:

```bash
# Set up interrupt handler
trap on_interrupt INT

# User presses Ctrl+C
# Handler displays: "Interrupted by user (SIGINT)"
# Script exits with code 130
```

#### `on_terminate()`

**Propósito**: Tratar sinais SIGTERM de forma adequada **Parâmetros**: Nenhum **Retorno**: Nenhum (encerra com código 143) **Efeitos Colaterais**:

- Exibe mensagem de término
- Encerra com código SIGTERM (143) **Dependências**: Nenhuma **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Exemplo de Uso**:

```bash
# Set up termination handler
trap on_terminate TERM

# System sends SIGTERM
# Handler displays: "Terminated by signal (SIGTERM)"
# Script exits with code 143
```

### Funções de Limpeza

#### `on_exit()`

**Propósito**: Lidar com a limpeza de saída do script **Parâmetros**: Nenhum **Retorno**: Nenhum (encerra com o código de saída original) **Efeitos Colaterais**:

- Remove o arquivo de bloqueio, se definido
- Encerra com o código de saída original **Dependências**: Nenhuma **Variáveis ​​de Ambiente Utilizadas**: `lockfile`

**Exemplo de Uso**:

```bash
# Set up exit handler
trap on_exit EXIT

# Set lock file
lockfile="/tmp/my_script.lock"

# Script exits normally or with error
# Handler removes lock file and exits
```

### Funções de Inicialização

#### `catch_errors()`

**Propósito**: Inicializar os mecanismos de tratamento de erros e o modo estrito **Parâmetros**: Nenhum **Retorno**: Nenhum **Efeitos Colaterais** **Efeitos**:

- Define o modo de tratamento de erros estrito
- Configura as armadilhas de erro
- Configura as armadilhas de sinal
- Configura a armadilha de saída **Dependências**: Nenhuma **Variáveis ​​de Ambiente Utilizadas**: `STRICT_UNSET`

**Configurações do Modo Estrito**:

- `-E`: Sair em caso de falha de comando
- `-e`: Sair em caso de qualquer erro
- `-o pipefail`: Sair em caso de falha de pipe
- `-u`: Sair em caso de variáveis ​​não definidas (se STRICT_UNSET=1)

**Configuração de Armadilhas**:

- `ERR`: Chama `error_handler` em caso de falha de comando
- `EXIT`: Chama `on_exit` ao sair do script
- `INT`: Chama `on_interrupt` em caso de SIGINT
- `TERM`: Chama `on_terminate` em caso de SIGTERM

**Exemplo de Uso**:

```bash
# Initialize error handling
catch_errors

# Script now has full error handling
# All errors will be caught and handled
```

## Hierarquia de Chamadas de Função

### Fluxo de Tratamento de Erros

```
Command Failure
├── ERR trap triggered
├── error_handler() called
│   ├── Get exit code
│   ├── Get command info
│   ├── Get line number
│   ├── explain_exit_code()
│   ├── Display error info
│   ├── Log to debug file
│   ├── Show silent log
│   └── Exit with error code
```

### Fluxo de Tratamento de Sinais

```
Signal Received
├── Signal trap triggered
├── Appropriate handler called
│   ├── on_interrupt() for SIGINT
│   ├── on_terminate() for SIGTERM
│   └── on_exit() for EXIT
└── Exit with signal code
```

### Fluxo de Inicialização

```
catch_errors()
├── Set strict mode
│   ├── -E (exit on failure)
│   ├── -e (exit on error)
│   ├── -o pipefail (pipe failure)
│   └── -u (unset variables, if enabled)
└── Set up traps
    ├── ERR → error_handler
    ├── EXIT → on_exit
    ├── INT → on_interrupt
    └── TERM → on_terminate
```

## Referência de Códigos de Erro

### Erros Genéricos/do Shell

| Código | Descrição |

|------|-------------|

| 1 | Erro geral / Operação não permitida | | 2 | Uso incorreto de funções internas do shell (ex.: erro de sintaxe) | | 126 | O comando invocado não pode ser executado (problema de permissão?) | | 127
| Comando não encontrado | | 128 | Argumento inválido para sair | | 130 | Terminado por Ctrl+C (SIGINT) | | 137 | Finalizado (SIGKILL / Sem memória?) | | 139 | Falha de segmentação (core dumped) | |
143 | Terminado (SIGTERM) |

### Erros do Gerenciador de Pacotes

| Código | Descrição |

|------|-------------| | 100 | APT: Erro no gerenciador de pacotes (pacotes quebrados / problemas de dependência) | | 101 | APT: Erro de configuração (sources.list inválido, configuração malformada) |
| 255 | DPKG: Erro interno fatal |

### Erros do Node.js

| Código | Descrição |

|------|-------------| | 243 | Node.js: Memória insuficiente (heap do JavaScript sem memória) | | 245 | Node.js: Opção de linha de comando inválida | | 246 | Node.js: Erro interno de análise do
JavaScript | | 247 | Node.js: Erro interno fatal | | 248 | Node.js: Addon C++ inválido / falha na N-API | | 249 | Node.js: Erro do inspetor | | 254 | npm/pnpm/yarn: Erro fatal desconhecido |

### Erros do Python

| Código | Descrição |

|------|-------------| | 210 | Python: Ambiente virtualenv / uv ausente ou corrompido | | 211 | Python: Falha na resolução de dependências | | 212 | Python: Instalação abortada (permissões ou
gerenciamento externo) |

### Erros do Banco de Dados

| Código | Descrição |

|------|-------------| | 231 | PostgreSQL: Falha na conexão (servidor não está em execução / socket incorreto) | | 232 | PostgreSQL: Falha na autenticação (usuário/senha incorretos) | | 233 |
PostgreSQL: Banco de dados não existe | | 234 | PostgreSQL: Erro fatal na consulta / sintaxe | | 241 | MySQL/MariaDB: Falha na conexão (servidor não está em execução / socket incorreto) | | 242 |
MySQL/MariaDB: Falha na autenticação (usuário/senha incorretos) | | 243 | MySQL/MariaDB: Banco de dados não existe | | 244 | MySQL/MariaDB: Erro fatal na consulta / sintaxe | | 251 | MongoDB: Falha na
conexão (servidor não está em execução) | | 252 | MongoDB: Falha na autenticação (usuário/senha incorretos) | | 253 | MongoDB: Banco de dados não encontrado | | 254 | MongoDB: Erro fatal na consulta |

### Erros personalizados do Proxmox

| Código | Descrição |

|------|-------------| | 200 | Personalizado: Falha ao criar o arquivo de bloqueio | | 203 | Personalizado: Variável CTID ausente | | 204 | Personalizado: Variável PCT_OSTYPE ausente | | 205 |
Personalizado: CTID inválido (<100) | | 209 | Personalizado: Falha na criação do contêiner | | 210 | Personalizado: Cluster sem quórum | | 214 | Personalizado: Espaço de armazenamento insuficiente | |
215 | Personalizado: ID do contêiner não listado | | 216 | Personalizado: Entrada RootFS ausente na configuração | | 217 | Personalizado: O armazenamento não suporta diretório raiz | | 220 |
Personalizado: Não foi possível resolver o caminho do modelo | | 222 | Personalizado: Falha no download do modelo após 3 tentativas | | 223 | Personalizado: Modelo não disponível após o download | |
231 | Personalizado: Falha na atualização/retentativa da pilha LXC |

## Dependências de Variáveis ​​de Ambiente

### Variáveis ​​Obrigatórias

- **`lockfile`**: Caminho do arquivo de bloqueio para limpeza (definido pelo script de chamada)

### Variáveis ​​Opcionais

- **`DEBUG_LOGFILE`**: Caminho para o arquivo de log de depuração para registro de erros
- **`SILENT_LOGFILE`**: Caminho para o arquivo de log de execução silenciosa
- **`STRICT_UNSET`**: Habilita a verificação estrita de variáveis ​​não definidas (0/1)

### Variáveis ​​Internas

- **`exit_code`**: Código de saída atual
- **`command`**: Comando com falha
- **`line_number`**: Número da linha onde o erro ocorreu
- **`explanation`**: Texto explicativo do erro

## Padrões de Tratamento de Erros

### Tratamento Automático de Erros

```bash
#!/usr/bin/env bash
source error_handler.func

# Initialize error handling
catch_errors

# All commands are now monitored
# Errors will be automatically caught and handled
```

### Tratamento Manual de Erros

```bash
#!/usr/bin/env bash
source error_handler.func

# Manual error handling
if ! command -v required_tool >/dev/null 2>&1; then
    error_handler 127 "required_tool not found"
fi
```

### Códigos de Erro Personalizados

```bash
#!/usr/bin/env bash
source error_handler.func

# Use custom error codes
if [[ ! -f /required/file ]]; then
    echo "Error: Required file missing"
    exit 200  # Custom error code
fi
```

### Tratamento de Sinais

```bash
#!/usr/bin/env bash
source error_handler.func

# Set up signal handling
trap on_interrupt INT
trap on_terminate TERM
trap on_exit EXIT

# Script handles signals gracefully
```

## Exemplos de Integração

### Com core.func

```bash
#!/usr/bin/env bash
source core.func
source error_handler.func

# Silent execution uses error_handler for explanations
silent apt-get install -y package
# If command fails, error_handler provides explanation
```

### Com build.func

```bash
#!/usr/bin/env bash
source core.func
source error_handler.func
source build.func

# Container creation with error handling
# Errors are caught and explained
```

### Com tools.func

```bash
#!/usr/bin/env bash
source core.func
source error_handler.func
source tools.func

# Tool operations with error handling
# All errors are properly handled and explained
```

## Melhores Práticas

### Configuração do Tratamento de Erros

1. Carregue error_handler.func no início do script
2. Chame catch_errors() para inicializar os traps
3. Use códigos de saída apropriados para diferentes tipos de erro
4. Forneça mensagens de erro significativas

### Tratamento de Sinais

1. Sempre configure os traps de sinal
2. Forneça uma limpeza adequada em caso de interrupção
3. Use códigos de saída apropriados para sinais
4. Limpe arquivos e processos temporários

### Relatório de Erros

1. Use 1. Utilize a função `explain_exit_code()` para mensagens amigáveis ​​ao usuário.
2. Registre erros em arquivos de depuração quando necessário.
3. Forneça informações de contexto (números de linha, comandos).
4. Integre com o registro de execução silenciosa.

### Códigos de Erro Personalizados

1. Utilize os códigos de erro personalizados do Proxmox (200-231) para erros de contêiner/VM.
2. Utilize códigos de erro padrão para operações comuns.
3. Documente os códigos de erro personalizados em comentários de script.
4. Forneça mensagens de erro claras para os códigos personalizados.
