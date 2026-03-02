# Referência de Funções do build.func

## Visão Geral

Este documento fornece uma referência completa de todas as funções do pacote `build.func`, organizadas alfabeticamente com descrições detalhadas, parâmetros e informações de uso.

## Categorias de Funções

### Funções de Inicialização

#### `start()`

**Propósito**: Ponto de entrada principal quando build.func é carregado ou executado
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Detecta o contexto de execução (host Proxmox vs. contêiner)
- Captura variáveis ​​de ambiente fixas
- Define CT_TYPE com base no contexto
- Direciona para o fluxo de trabalho apropriado (install_script ou update_script)

**Dependências**: Nenhuma

**Variáveis ​​de Ambiente Utilizadas**: `CT_TYPE`, `APP`, `CTID`

#### `variables()`

**Propósito**: Carrega e resolve todas as variáveis ​​de configuração usando a cadeia de precedência
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Carrega o arquivo .vars específico do aplicativo
- Carrega o arquivo default.vars global
- Aplica a cadeia de precedência de variáveis
- Define Todas as variáveis ​​de configuração

**Dependências**: `base_settings()`

**Variáveis ​​de ambiente utilizadas**: Todas as variáveis ​​de configuração

#### `base_settings()`

**Finalidade**: Define valores padrão para todas as variáveis ​​de configuração
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos colaterais**: Define valores padrão para todas as variáveis
**Dependências**: Nenhuma
**Variáveis ​​de ambiente utilizadas**: Todas as variáveis ​​de configuração

### Funções da interface do usuário e do menu

#### `install_script()`

**Finalidade**: Coordenador principal do fluxo de trabalho de instalação
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos colaterais**:

- Exibe o menu de seleção do modo de instalação
- Coordena todo o processo de instalação
- Lida com a interação e validação do usuário

**Dependências**: `variables()`, `build_container()`, `default_var_settings()`
**Variáveis ​​de Ambiente Utilizadas**: `APP`, `CTID`, `var_hostname`

#### `advanced_settings()`

**Finalidade**: Fornecer opções de configuração avançadas através dos menus Whiptail
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Exibe os menus Whiptail para configuração
- Atualiza as variáveis ​​de configuração com base na entrada do usuário
- Valida as seleções do usuário

**Dependências**: `select_storage()`, `detect_gpu_devices()`

**Variáveis ​​de Ambiente Utilizadas**: Todas as variáveis ​​de configuração

#### `settings_menu()`

**Finalidade**: Exibir e gerenciar o menu de configuração
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**: Atualiza as variáveis ​​de configuração
**Dependências**: `advanced_settings()`
**Variáveis ​​de Ambiente Utilizadas**: Todas as variáveis ​​de configuração Variáveis

### Funções de Armazenamento

#### `select_storage()`

**Finalidade**: Gerencia a seleção de armazenamento para modelos e contêineres
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Resolve a pré-seleção de armazenamento
- Solicita ao usuário a seleção de armazenamento, se necessário
- Valida a disponibilidade de armazenamento
- Define as variáveis ​​`var_template_storage` e `var_container_storage`

**Dependências**: `resolve_storage_preselect()`, `choose_and_set_storage_for_file()`

**Variáveis ​​de Ambiente Utilizadas**: `var_template_storage`, `var_container_storage`, `TEMPLATE_STORAGE`, `CONTAINER_STORAGE`

#### `resolve_storage_preselect()`

**Finalidade**: Resolve o armazenamento pré-selecionado Opções
**Parâmetros**:

- `storage_type`: Tipo de armazenamento (template ou container)

**Retorno**: Nome do armazenamento, se válido; vazio, se inválido

**Efeitos colaterais**: Valida a disponibilidade do armazenamento

**Dependências**: Nenhuma

**Variáveis ​​de ambiente utilizadas**: `var_template_storage`, `var_container_storage`

#### `choose_and_set_storage_for_file()`

**Finalidade**: Seleção interativa de armazenamento via whiptail
**Parâmetros**:

- `storage_type`: Tipo de armazenamento (template ou container)
- `content_type`: Tipo de conteúdo (vztmpl ou rootdir)

**Retorno**: Nenhum

**Efeitos colaterais**:

- Exibe o menu do whiptail
- Atualiza as variáveis ​​de armazenamento
- Valida a seleção

**Dependências**: Nenhuma

**Variáveis ​​de ambiente utilizadas**: `var_template_storage`, `var_container_storage`

### Funções de Criação de Contêineres

#### `build_container()`

**Propósito**: Validar configurações e preparar a criação do contêiner
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Valida toda a configuração
- Verifica conflitos
- Prepara a configuração do contêiner
- Chama `create_lxc_container()`

**Dependências**: `create_lxc_container()`

**Variáveis ​​de Ambiente Utilizadas**: Todas as variáveis ​​de configuração

#### `create_lxc_container()`

**Propósito**: Criar o contêiner LXC
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Cria um contêiner LXC com configuração básica
- Configura as definições de rede
- Configura o armazenamento e os pontos de montagem
- Configura recursos (FUSE, TUN, etc.)
- Define limites de recursos
- Configura opções de inicialização
- Inicia o contêiner

**Dependências**: `configure_gpu_passthrough()`, `fix_gpu_gids()`

**Variáveis ​​de Ambiente Utilizadas**: Todas as variáveis ​​de configuração

### Funções de GPU e Hardware

#### `detect_gpu_devices()`

**Objetivo**: Detectar o hardware de GPU disponível no sistema
**Parâmetros**: Nenhum
**Retornos**: Nenhum
**Efeitos Colaterais**:

- Busca por GPUs Intel, AMD e NVIDIA
- Atualiza var_gpu_type e var_gpu_devices
- Determina as capacidades da GPU

**Dependências**: Nenhuma

**Variáveis ​​de Ambiente Utilizadas**: `var_gpu_type`, `var_gpu_devices`, `GPU_APPS`

#### `configure_gpu_passthrough()`

**Objetivo**: Configurar o passthrough de GPU para o contêiner
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos colaterais**:

- Adiciona entradas de dispositivo GPU à configuração do contêiner
- Configura as permissões de dispositivo adequadas
- Configura o mapeamento de dispositivos
- Atualiza /etc/pve/lxc/<ctid>.conf

**Dependências**: `detect_gpu_devices()`

**Variáveis ​​de ambiente usadas**: `var_gpu`, `var_gpu_type`, `var_gpu_devices`, `CTID`

#### `fix_gpu_gids()`

**Objetivo**: Corrigir os IDs de grupo de GPU após a criação do contêiner
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos colaterais**:

- Atualiza a GPU IDs de grupo no contêiner
- Garante as permissões de acesso à GPU adequadas
- Configura os grupos de vídeo e renderização

**Dependências**: `configure_gpu_passthrough()`

**Variáveis ​​de ambiente utilizadas**: `CTID`, `var_gpu_type`

### Funções de configuração SSH

#### `configure_ssh_settings()`

**Finalidade**: Assistente interativo para configuração de chave e acesso SSH
**Parâmetros**:

- `step_info` (opcional): String indicadora de etapa (ex.: "Etapa 17/19") para cabeçalhos de diálogo consistentes

**Retorno**: Nenhum

**Efeitos colaterais**:

- Cria um arquivo temporário para as chaves SSH
- Descobre e apresenta as chaves SSH disponíveis do host
- Permite a entrada manual de chaves ou a varredura de pastas/globs
- Define a variável `SSH` como "sim" ou "não" com base na seleção do usuário
- Define `SSH_AUTHORIZED_KEY` se a chave for inserida manualmente Fornecido
- Preenche `SSH_KEYS_FILE` com as chaves selecionadas

**Dependências**: `ssh_discover_default_files()`, `ssh_build_choices_from_files()`

**Variáveis ​​de Ambiente Utilizadas**: `SSH`, `SSH_AUTHORIZED_KEY`, `SSH_KEYS_FILE`

**Opções de Origem da Chave SSH**:

1. `found` - Selecionar entre as chaves de host detectadas automaticamente
2. `manual` - Colar uma única chave pública
3. `folder` - Verificar pasta personalizada ou padrão glob
4. `none` - Nenhuma chave SSH

**Observação**: A caixa de diálogo "Habilitar acesso SSH root?" é sempre exibida, independentemente de as chaves SSH ou a senha estarem configuradas. Isso garante que os usuários sempre possam habilitar o acesso SSH, mesmo com login automático.

#### `ssh_discover_default_files()`

**Objetivo**: Descobre arquivos de chave pública SSH no sistema host
**Parâmetros**: Nenhum
**Retorno**: Array com os caminhos dos arquivos de chave descobertos
**Efeitos colaterais**: Analisa locais comuns de chaves SSH
**Dependências**: Nenhuma
**Variáveis ​​de ambiente utilizadas**: `var_ssh_import_glob`

#### `ssh_build_choices_from_files()`

**Objetivo**: Cria opções de checklist do Whiptail a partir de arquivos de chave SSH
**Parâmetros**:

- Array com os caminhos dos arquivos a serem processados
  **Retorno**: Nenhum

**Efeitos colaterais**:

- Define o array `CHOICES` para o checklist do Whiptail
- Define a variável `COUNT` com o número de chaves encontradas
- Cria um arquivo `MAPFILE` para o mapeamento da tag da chave para o conteúdo
  **Dependências**: Nenhuma
  **Variáveis ​​de ambiente utilizadas**: `CHOICES`, `COUNT`, `MAPFILE`

### Funções de Persistência de Configurações

#### `default_var_settings()`

**Propósito**: Oferece a opção de salvar as configurações atuais como padrão
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Solicita ao usuário que salve as configurações
- Salva no arquivo default.vars
- Salva no arquivo .vars específico do aplicativo

**Dependências**: `maybe_offer_save_app_defaults()`

**Variáveis ​​de Ambiente Utilizadas**: Todas as variáveis ​​de configuração

#### `maybe_offer_save_app_defaults()`

**Propósito**: Oferece a opção de salvar os valores padrão específicos do aplicativo
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos Colaterais**:

- Solicita ao usuário que salve as configurações específicas do aplicativo
- Salva no arquivo app.vars
- Atualiza a configuração específica do aplicativo

**Dependências**: Nenhuma

**Variáveis ​​de ambiente usadas**: `APP`, `SAVE_APP_DEFAULTS`

### Funções de utilitário

#### `validate_settings()`

**Finalidade**: Validar todas as configurações
**Parâmetros**: Nenhum
**Retorno**: 0 se válido, 1 se inválido
**Efeitos colaterais**:

- Verifica conflitos de configuração
- Valida limites de recursos
- Valida a configuração de rede
- Valida a configuração de armazenamento

**Dependências**: Nenhuma

**Variáveis ​​de ambiente utilizadas**: Todas as variáveis ​​de configuração

#### `check_conflicts()`

**Propósito**: Verifica conflitos de configuração
**Parâmetros**: Nenhum
**Retorno**: 0 se não houver conflitos, 1 se conflitos forem encontrados
**Efeitos colaterais**:

- Verifica configurações conflitantes
- Valida a alocação de recursos
- Verifica a configuração de rede

**Dependências**: Nenhuma

**Variáveis ​​de ambiente utilizadas**: Todas as variáveis ​​de configuração

#### `cleanup_on_error()`

**Propósito**: Limpa recursos em caso de erro
**Parâmetros**: Nenhum
**Retorno**: Nenhum
**Efeitos colaterais**:

- Remove contêineres parcialmente criados
- Limpa arquivos temporários
- Redefine a configuração

**Dependências**: Nenhuma
**Variáveis ​​de Ambiente Utilizadas**: `CTID`

## Fluxo de Chamada de Função

### Fluxo Principal de Instalação

```
start()
├── variables()
│   ├── base_settings()
│   ├── Load app.vars
│   └── Load default.vars
├── install_script()
│   ├── advanced_settings()
│   │   ├── select_storage()
│   │   │   ├── resolve_storage_preselect()
│   │   │   └── choose_and_set_storage_for_file()
│   │   └── detect_gpu_devices()
│   ├── build_container()
│   │   ├── validate_settings()
│   │   ├── check_conflicts()
│   │   └── create_lxc_container()
│   │       ├── configure_gpu_passthrough()
│   │       └── fix_gpu_gids()
│   └── default_var_settings()
│       └── maybe_offer_save_app_defaults()
```

### Fluxo de Tratamento de Erros

```
Error Detection
├── validate_settings()
│   └── check_conflicts()
├── Error Handling
│   └── cleanup_on_error()
└── Exit with error code
```

## Dependências de Função

### Dependências Principais

- `start()` → `install_script()` → `build_container()` → `create_lxc_container()`
- `variables()` → `base_settings()`
- `advanced_settings()` → `select_storage()` → `detect_gpu_devices()`

### Dependências de Armazenamento

- `select_storage()` → `resolve_storage_preselect()`
- `select_storage()` → `choose_and_set_storage_for_file()`

### Dependências da GPU

- `configure_gpu_passthrough()` → `detect_gpu_devices()`

- `fix_gpu_gids()` → `configure_gpu_passthrough()`

### Dependências de Configurações

- `default_var_settings()` → `maybe_offer_save_app_defaults()`

## Exemplos de Uso da Função

### Criação Básica de Contêineres

```bash
# Set required variables
export APP="plex"
export CTID="100"
export var_hostname="plex-server"

# Call main functions
start()  # Entry point
# → variables()  # Load configuration
# → install_script()  # Main workflow
# → build_container()  # Create container
# → create_lxc_container()  # Actual creation
```

### Configuração Avançada

```bash
# Set advanced variables
export var_os="debian"
export var_version="12"
export var_cpu="4"
export var_ram="4096"
export var_disk="20"

# Call advanced functions
advanced_settings()  # Interactive configuration
# → select_storage()  # Storage selection
# → detect_gpu_devices()  # GPU detection
```

### Passagem de GPU

```bash
# Enable GPU passthrough
export GPU_APPS="plex"
export var_gpu="nvidia"

# Call GPU functions
detect_gpu_devices()  # Detect hardware
configure_gpu_passthrough()  # Configure passthrough
fix_gpu_gids()  # Fix permissions
```

### Persistência de Configurações

```bash
# Save settings as defaults
export SAVE_DEFAULTS="true"
export SAVE_APP_DEFAULTS="true"

# Call persistence functions
default_var_settings()  # Save global defaults
maybe_offer_save_app_defaults()  # Save app defaults
```

### Gerenciamento de Recursos e IDs de Contêineres

#### `validate_container_id()`

**Finalidade**: Valida se um ID de contêiner está disponível para uso.

**Parâmetros**: `ctid` (Inteiro)
**Retorna**: `0` se disponível, `1` se já estiver em uso ou for inválido.

**Descrição**: Verifica se existem arquivos de configuração em `/etc/pve/lxc/` ou `/etc/pve/qemu-server/` e verifica os volumes lógicos LVM.

#### `get_valid_container_id()`

**Finalidade**: Retorna o próximo ID de contêiner disponível e não utilizado.

**Parâmetros**: `suggested_id` (Opcional)
**Retorna**: Uma string de ID de contêiner válida.

**Descrição**: Se o ID sugerido já estiver em uso, o valor é incrementado até encontrar um disponível.

#### `maxkeys_check()`

**Finalidade**: Garante que os parâmetros do kernel do host suportem um grande número de chaves (necessário para alguns aplicativos).

**Parâmetros**: Nenhum
**Descrição**: Verifica e, opcionalmente, atualiza `kernel.keys.maxkeys` e `kernel.keys.maxbytes`.

#### `get_current_ip()`

**Finalidade**: Recupera o endereço IP atual do contêiner.

**Parâmetros**: `ctid` (Inteiro)
**Retorna**: String do endereço IP.

#### `update_motd_ip()`

**Finalidade**: Atualiza o arquivo de Mensagem do Dia (MOTD) com o IP do contêiner.

**Parâmetros**: Nenhum

## Tratamento de Erros da Função

### Funções de Validação

- `validate_settings()`: Retorna 0 para válido, 1 para inválido
- `check_conflicts()`: Retorna 0 para nenhum conflito, 1 para conflitos

### Recuperação de Erros

- `cleanup_on_error()`: Limpa os erros encontrados
- Os códigos de erro são propagados pela pilha de chamadas
- Erros críticos causam o encerramento do script

### Tipos de Erro

1. **Erros de Configuração**: Configurações inválidas ou conflitos
2. **Erros de Recursos**: Recursos insuficientes ou conflitos
3. **Erros de Rede**: Configuração de rede inválida
4. **Erros de Armazenamento**: Armazenamento indisponível ou inválido
5. **Erros de GPU**: Falhas na configuração da GPU
6. **Erros de Criação de Contêiner**: Falhas na criação do LXC
