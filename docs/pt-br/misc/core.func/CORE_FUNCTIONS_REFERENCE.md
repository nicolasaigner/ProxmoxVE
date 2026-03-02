# Referência de Funções do core.func

## Visão Geral

Este documento fornece uma referência alfabética completa de todas as funções em `core.func`, incluindo parâmetros, dependências, exemplos de uso e tratamento de erros.

## Categorias de Funções

### Funções de Inicialização

#### `load_functions()`

**Propósito**: Carregador de funções principal que inicializa todos os utilitários principais
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Define `__FUNCTIONS_LOADED=1` para evitar recarregamento
- Chama todos os grupos de funções principais em sequência
- Inicializa cor, formatação, ícones, valores padrão e modo padrão
  **Dependências**: Nenhuma
  **Variáveis ​​de Ambiente Utilizadas**: `__FUNCTIONS_LOADED`

**Exemplo de Uso**:

```bash
# Automatically called when core.func is sourced
source core.func
# load_functions() is called automatically
```

### Funções de Cor e Formatação

#### `color()`

**Propósito**: Define códigos de cores ANSI para a saída estilizada do terminal
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**: Define variáveis ​​globais de cor
**Dependências**: Nenhuma
**Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Variáveis ​​de Definição**:

- `YW`: Amarelo
- `YWB`: Amarelo brilhante
- `BL`: Azul
- `RD`: Vermelho
- `BGN`: Verde brilhante
- `GN`: Verde
- `DGN`: Verde escuro
- `CL`: Limpar/Redefinir

**Exemplo de Uso**:

```bash
color
echo -e "${GN}Success message${CL}"
echo -e "${RD}Error message${CL}"
```

#### `color_spinner()`

**Propósito**: Define códigos de cores específicos para a saída do spinner
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**: Define variáveis ​​de cor específicas para o spinner
**Dependências**: Nenhuma
**Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Variáveis ​​de Definição**:

- `CS_YW`: Amarelo para o spinner
- `CS_YWB`: Amarelo brilhante para o spinner
- `CS_CL`: Limpar para o spinner spinner

#### `formatting()`

**Propósito**: Define funções auxiliares de formatação para a saída do terminal
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos colaterais**: Define variáveis ​​de formatação globais
**Dependências**: Nenhuma
**Variáveis ​​de ambiente utilizadas**: Nenhuma

**Variáveis ​​definidas**:

- `BFR`: Redefinir para trás e para frente
- `BOLD`: Texto em negrito
- `HOLD`: Caractere de espaço
- `TAB`: Dois espaços
- `TAB3`: Seis espaços

### Funções de ícones

#### `icons()`

**Propósito**: Define ícones simbólicos usados ​​em todo o feedback e prompts do usuário
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos colaterais**: Define variáveis ​​de ícone globais
**Dependências**: `formatting()` (para a variável TAB)
**Variáveis ​​de ambiente utilizadas**: `TAB` `CL`

**Configura variáveis**:

- `CM`: Marca de seleção
- `CROSS`: Marca de seleção cruzada
- `DNSOK`: DNS bem-sucedido
- `DNSFAIL`: Falha no DNS
- `INFO`: Ícone de informação
- `OS`: Ícone do sistema operacional
- `OSVERSION`: Ícone da versão do SO
- `CONTAINERTYPE`: Ícone do tipo de contêiner
- `DISKSIZE`: Ícone do tamanho do disco
- `CPUCORE`: Ícone do núcleo da CPU
- `RAMSIZE`: Ícone do tamanho da RAM
- `SEARCH`: Ícone de pesquisa
- `VERBOSE_CROPPED`: Ícone do modo detalhado
- `VERIFYPW`: Ícone de verificação de senha
- `CONTAINERID`: Ícone do ID do contêiner
- `HOSTNAME`: Ícone do nome do host
- `BRIDGE`: Ícone da ponte
- `NETWORK`: Ícone da rede
- `GATEWAY`: Ícone do gateway
- `DISABLEIPV6`: Ícone de desativação do IPv6
- `DEFAULT`: Configurações padrão ícone
- `MACADDRESS`: Ícone de endereço MAC
- `VLANTAG`: Ícone de tag VLAN
- `ROOTSSH`: Ícone de chave SSH
- `CREATING`: Ícone de criação
- `ADVANCED`: Ícone de configurações avançadas
- `FUSE`: Ícone de FUSE
- `HOURGLASS`: Ícone de ampulheta

### Funções de Variáveis ​​Padrão

#### `default_vars()`

**Finalidade**: Define as variáveis ​​padrão de repetição e espera para ações do sistema
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**: Define as variáveis ​​de configuração de repetição
**Dependências**: Nenhuma
**Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Variáveis ​​Definidas**:

- `RETRY_NUM`: Número de tentativas de repetição (padrão: 10)
- `RETRY_EVERY`: Segundos entre tentativas (padrão: 3)
- `i`: Contador de tentativas Inicializado com RETRY_NUM

#### `set_std_mode()`

**Propósito**: Define o modo detalhado padrão para execução de scripts
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**: Define a variável STD com base na configuração VERBOSE
**Dependências**: Nenhuma
**Variáveis ​​de Ambiente Utilizadas**: `VERBOSE`

**Variáveis ​​Definidas**:

- `STD`: "silent" se VERBOSE != "yes", string vazia se VERBOSE = "yes"

### Funções de Execução Silenciosa

#### `silent()`

**Propósito**: Executa comandos silenciosamente com relatório de erros detalhado
**Parâmetros**: `$*` - Comando e argumentos a serem executados
**Retorno**: Nenhum (encerra em caso de erro)
**Efeitos Colaterais**:

- Executa o comando com a saída redirecionada para o arquivo de log
- Em caso de erro, exibe informações detalhadas sobre o erro
- Encerra com o código de saída do comando
  **Dependências**: `error_handler.func` (para explicações de erros)
  **Variáveis ​​de Ambiente Utilizadas**: `SILENT_LOGFILE`

**Exemplo de Uso**:

```bash
silent apt-get update
silent apt-get install -y package-name
```

**Tratamento de Erros**:

- Captura a saída do comando em `/tmp/silent.$$.log`
- Exibe a explicação do código de erro
- Exibe as últimas 10 linhas do log
- Fornece um comando para visualizar o log completo

### Funções de Verificação do Sistema

#### `shell_check()`

**Propósito**: Verificar se o script está sendo executado no shell Bash
**Parâmetros**: Nenhum
**Retorno**: Nenhum (encerra se não for Bash)
**Efeitos Colaterais**:

- Verifica o processo do shell atual
- Encerra com uma mensagem de erro se não for Bash
  **Dependências**: Nenhuma
  **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Exemplo de Uso**:

```bash
shell_check
# Script continues if Bash, exits if not
```

#### `root_check()`

**Propósito**: Garantir que o script esteja sendo executado como usuário root
**Parâmetros**: Nenhum
**Retorno**: Nenhum (encerra se não for root)
**Efeitos Colaterais**:

- Verifica o ID do usuário e o processo pai
- Encerra com uma mensagem de erro se não for root
  **Dependências**: Nenhuma
  **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Uso Exemplo**:

```bash
root_check
# Script continues if root, exits if not
```

#### `pve_check()`

**Objetivo**: Verificar a compatibilidade da versão do Proxmox VE
**Parâmetros**: Nenhum
**Retorno**: Nenhum (encerra se a versão não for suportada)
**Efeitos colaterais**:

- Verifica a versão do PVE usando o comando `pveversion`
- Encerra com uma mensagem de erro se a versão não for suportada
  **Dependências**: Comando `pveversion`
  **Variáveis ​​de ambiente usadas**: Nenhuma

**Versões suportadas**:

- Proxmox VE 8.0 - 8.9
- Proxmox VE 9.0 (somente)

**Exemplo de uso**:

```bash
pve_check
# Script continues if supported version, exits if not
```

#### `arch_check()`

**Objetivo**: Verificar se a arquitetura do sistema é AMD64
**Parâmetros**: Nenhum
**Retorno**: Nenhum (encerra se não for AMD64) AMD64)
**Efeitos Colaterais**:

- Verifica a arquitetura do sistema
- Encerra com um aviso do PiMox se não for AMD64
  **Dependências**: Comando `dpkg`
  **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Exemplo de Uso**:

```bash
arch_check
# Script continues if AMD64, exits if not
```

#### `ssh_check()`

**Objetivo**: Detectar e alertar sobre o uso de SSH externo
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Verifica a variável de ambiente SSH_CLIENT
- Alerta se a conexão for feita a partir de um IP externo
- Permite conexões locais (127.0.0.1 ou IP do host)
  **Dependências**: Nenhuma
  **Variáveis ​​de Ambiente Utilizadas**: `SSH_CLIENT`

**Exemplo de Uso**:

```bash
ssh_check
# Shows warning if external SSH, continues anyway
```

### Funções de Gerenciamento de Cabeçalho

#### `get_header()`

**Finalidade**: Baixa e armazena em cache os arquivos de cabeçalho do aplicativo
**Parâmetros**: Nenhum (usa as variáveis ​​APP e APP_TYPE)
**Retorna**: Conteúdo do cabeçalho em caso de sucesso, vazio em caso de falha
**Efeitos colaterais**:

- Baixa o cabeçalho de uma URL remota
- Armazena o cabeçalho em cache localmente
- Cria a estrutura de diretórios, se necessário
  **Dependências**: Comando `curl`
  **Variáveis ​​de ambiente usadas**: `APP`, `APP_TYPE`

**Exemplo de uso**:

```bash
export APP="plex"
export APP_TYPE="ct"
header_content=$(get_header)
```

#### `header_info()`

**Finalidade**: Exibe as informações do cabeçalho do aplicativo
**Parâmetros**: Nenhum (usa a variável APP)
**Retorna**: Nenhum
**Efeitos colaterais**:

- Limpa a tela
- Exibe o conteúdo do cabeçalho
- Obtém a largura do terminal para formatação
  **Dependências**: `get_header()`, `tput` comando
  **Variáveis ​​de Ambiente Utilizadas**: `APP`

**Exemplo de Uso**:

```bash
export APP="plex"
header_info
# Displays Plex header information
```

### Funções Utilitárias

#### `ensure_tput()`

**Propósito**: Garante que o comando tput esteja disponível para controle do terminal
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Instala o pacote ncurses se o comando tput estiver ausente
- Funciona em sistemas baseados em Alpine e Debian
  **Dependências**: Gerenciadores de pacotes `apk` ou `apt-get`
  **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Exemplo de Uso**:

```bash
ensure_tput
# Installs ncurses if needed, continues if already available
```

#### `is_alpine()`

**Propósito**: Detecta se o sistema está sendo executado no Alpine Linux
**Parâmetros**: Nenhum
**Retorno**: 0 se Alpine, 1 se não Alpine
**Efeitos Colaterais**:

- Instala o pacote ncurses se o comando tput estiver ausente **Efeitos**: Nenhum
  **Dependências**: Nenhuma
  **Variáveis ​​de Ambiente Utilizadas**: `var_os`, `PCT_OSTYPE`

**Exemplo de Uso**:

```bash
if is_alpine; then
    echo "Running on Alpine Linux"
else
    echo "Not running on Alpine Linux"
fi
```

#### `is_verbose_mode()`

**Propósito**: Verifica se o modo verboso está ativado
**Parâmetros**: Nenhum
**Retorna**: 0 se o modo verboso estiver ativado, 1 se não estiver
**Efeitos Colaterais**: Nenhum
**Dependências**: Nenhuma
**Variáveis ​​de Ambiente Utilizadas**: `VERBOSE`, `var_verbose`

**Exemplo de Uso**:

```bash
if is_verbose_mode; then
    echo "Verbose mode enabled"
else
    echo "Verbose mode disabled"
fi
```

#### `fatal()`

**Propósito**: Exibe um erro fatal e encerra o script
**Parâmetros**: `$1` - Mensagem de erro
**Retorna**: Nenhum (encerra o script)
**Efeitos Colaterais** **Efeitos**:

- Exibe mensagem de erro
- Envia sinal INT para o processo atual
  **Dependências**: `msg_error()`
  **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Exemplo de Uso**:

```bash
fatal "Critical error occurred"
# Script terminates after displaying error
```

### Funções do Spinner

#### `spinner()`

**Propósito**: Exibe um spinner animado para indicar o progresso
**Parâmetros**: Nenhum (usa a variável SPINNER_MSG)
**Retorno**: Nenhum (executa indefinidamente)
**Efeitos Colaterais**:

- Exibe caracteres giratórios no spinner
- Usa sequências de controle do terminal
  **Dependências**: `color_spinner()`
  **Variáveis ​​de Ambiente Utilizadas**: `SPINNER_MSG`

**Exemplo de Uso**:

```bash
SPINNER_MSG="Processing..."
spinner &
SPINNER_PID=$!
# Spinner runs in background
```

#### `clear_line()`

**Propósito**: Limpa a linha atual do terminal
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos colaterais**: Limpa a linha atual usando o controle do terminal
**Dependências**: Comando `tput`
**Variáveis ​​de ambiente usadas**: Nenhuma

#### `stop_spinner()`

**Propósito**: Interrompe a execução do spinner e realiza a limpeza
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos colaterais**:

- Encerra o processo do spinner
- Remove o arquivo PID
- Redefine as configurações do terminal
- Remove as variáveis ​​do spinner
  **Dependências**: Nenhuma
  **Variáveis ​​de ambiente usadas**: `SPINNER_PID`, `SPINNER_MSG`

**Exemplo de uso**:

```bash
stop_spinner
# Stops spinner and cleans up
```

### Funções de mensagem

#### `msg_info()`

**Finalidade**: Exibir mensagem informativa com indicador de carregamento
**Parâmetros**: `$1` - Texto da mensagem
**Retorno**: Nenhum
**Efeitos colaterais**:

- Inicia o indicador de carregamento se o modo detalhado não estiver ativado
- Registra as mensagens exibidas para evitar duplicatas
- Exibe a mensagem com um ícone de ampulheta no modo detalhado
  **Dependências**: `spinner()`, `is_verbose_mode()`, `is_alpine()`
  **Variáveis ​​de ambiente utilizadas**: `MSG_INFO_SHOWN`

**Exemplo de uso**:

```bash
msg_info "Installing package..."
# Shows spinner with message
```

#### `msg_ok()`

**Finalidade**: Exibir mensagem de sucesso
**Parâmetros**: `$1` - Texto da mensagem de sucesso
**Retorno**: Nenhum
**Efeitos colaterais**:

- Interrompe o indicador de carregamento
- Exibe uma marca de seleção verde com a mensagem
- Remove a mensagem da lista de mensagens exibidas Rastreamento
  **Dependências**: `stop_spinner()`
  **Variáveis ​​de Ambiente Utilizadas**: `MSG_INFO_SHOWN`

**Exemplo de Uso**:

```bash
msg_ok "Package installed successfully"
# Shows green checkmark with message
```

#### `msg_error()`

**Propósito**: Exibir mensagem de erro
**Parâmetros**: `$1` - Texto da mensagem de erro
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Interrompe o indicador de carregamento
- Exibe um X vermelho com a mensagem
  **Dependências**: `stop_spinner()`
  **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Exemplo de Uso**:

```bash
msg_error "Installation failed"
# Shows red cross with message
```

#### `msg_warn()`

**Propósito**: Exibir mensagem de aviso
**Parâmetros**: `$1` - Texto da mensagem de aviso
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Interrompe o indicador de carregamento
- Exibe um ícone amarelo de informação com a mensagem
  **Dependências**: `stop_spinner()`
  **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Exemplo de Uso**:

```bash
msg_warn "This operation may take some time"
# Shows yellow info icon with message
```

#### `msg_custom()`

**Finalidade**: Exibe uma mensagem personalizada com o símbolo e a cor especificados
**Parâmetros**:

- `$1` - Símbolo personalizado (padrão: "[*]")
- `$2` - Código de cor (padrão: "\e[36m")
- `$3` - Texto da mensagem
  **Retorno**: Nenhum
  **Efeitos Colaterais**:
- Interrompe o indicador de carregamento
- Exibe uma mensagem formatada personalizada
  **Dependências**: `stop_spinner()`
  **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Exemplo de Uso**:

```bash
msg_custom "⚡" "\e[33m" "Custom warning message"
# Shows custom symbol and color with message
```

#### `msg_debug()`

**Finalidade**: Exibe uma mensagem de depuração se o modo de depuração estiver ativado
**Parâmetros**: `$*` - Texto da mensagem de depuração
**Retorno**: Nenhum
**Efeitos colaterais**:

- Exibe apenas se `var_full_verbose` estiver definido
- Mostra o carimbo de data/hora e o prefixo de depuração
  **Dependências**: Nenhuma
  **Variáveis ​​de ambiente usadas**: `var_full_verbose`, `var_verbose`

**Exemplo de uso**:

```bash
export var_full_verbose=1
msg_debug "Debug information here"
# Shows debug message with timestamp
```

### Funções de gerenciamento do sistema

#### `check_or_create_swap()`

**Finalidade**: Verifica se há uma partição de swap ativa e, opcionalmente, cria um arquivo de swap
**Parâmetros**: Nenhum
**Retorno**: 0 se a partição de swap existir ou tiver sido criada, 1 se for ignorada
**Efeitos colaterais**:

- Verifica se há uma partição de swap ativa
- Solicita ao usuário que crie uma partição de swap se não houver nenhuma Encontrado
- Cria um arquivo de swap se o usuário confirmar
  **Dependências**: comandos `swapon`, `dd`, `mkswap`
  **Variáveis ​​de Ambiente Utilizadas**: Nenhuma

**Exemplo de Uso**:

```bash
if check_or_create_swap; then
    echo "Swap is available"
else
    echo "No swap available"
fi
```

## Hierarquia de Chamadas de Função

### Fluxo de Inicialização

```
load_functions()
├── color()
├── formatting()
├── icons()
├── default_vars()
└── set_std_mode()
```

### Fluxo do Sistema de Mensagens

```
msg_info()
├── is_verbose_mode()
├── is_alpine()
├── spinner()
└── color_spinner()

msg_ok()
├── stop_spinner()
└── clear_line()

msg_error()
└── stop_spinner()

msg_warn()
└── stop_spinner()
```

### Fluxo de Verificação do Sistema

```
pve_check()
├── pveversion command
└── version parsing

arch_check()
├── dpkg command
└── architecture check

shell_check()
├── ps command
└── shell detection

root_check()
├── id command
└── parent process check
```

### Fluxo de Execução Silenciosa

```
silent()
├── Command execution
├── Output redirection
├── Error handling
├── error_handler.func loading
└── Log management
```

## Padrões de Tratamento de Erros

### Erros de Verificação do Sistema

- Todas as funções de verificação do sistema são encerradas com mensagens de erro apropriadas
- Indicação clara do problema e como corrigi-lo
- Encerramento correto com um pequeno atraso para que o usuário leia a mensagem

### Execução Silenciosa Erros

- Os comandos executados via `silent()` capturam a saída para o arquivo de log
- Em caso de falha, exibe a explicação do código de erro
- Mostra as últimas 10 linhas da saída do log
- Fornece um comando para visualizar o log completo

### Erros do Spinner

- As funções do Spinner gerenciam a limpeza do processo ao sair
- Os manipuladores de traps garantem que os spinners sejam interrompidos
- As configurações do terminal são restauradas em caso de erro

## Dependências de Variáveis ​​de Ambiente

### Variáveis ​​Obrigatórias

- `APP`: Nome do aplicativo para exibição do cabeçalho
- `APP_TYPE`: Tipo de aplicativo (ct/vm) para caminhos de cabeçalho
- `VERBOSE`: Configuração do modo detalhado

### Variáveis ​​Opcionais

- `var_os`: Tipo de SO para detecção do Alpine
- `PCT_OSTYPE`: Variável alternativa para o tipo de SO
- `var_verbose`: Configuração alternativa para o modo detalhado
- `var_full_verbose`: Configuração do modo de depuração

### Variáveis ​​Internas

- `_CORE_FUNC_LOADED`: Impede o carregamento múltiplo
- `__FUNCTIONS_LOADED`: Impede o carregamento múltiplo de funções
- `SILENT_LOGFILE`: Caminho do arquivo de log de execução silenciosa
- `SPINNER_PID`: ID do processo do Spinner
- `SPINNER_MSG`: Texto da mensagem do Spinner
- `MSG_INFO_SHOWN`: Rastreia as mensagens de informação exibidas
