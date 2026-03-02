# Referência de Variáveis ​​de Ambiente do build.func

## Visão Geral

Este documento fornece uma referência completa de todas as variáveis ​​de ambiente usadas no `build.func`, organizadas por categoria e contexto de uso.

## Categorias de Variáveis

### Variáveis ​​Principais do Contêiner

| Variável  | Descrição                                     | Padrão    | Definida em | Usada em             |
| --------- | --------------------------------------------- | --------- | ----------- | -------------------- |
| `APP`     | Nome do aplicativo (ex.: "plex", "nextcloud") | -         | Ambiente    | Em todo o sistema    |
| `NSAPP`   | Nome do aplicativo no namespace               | `$APP`    | Ambiente    | Em todo o sistema    |
| `CTID`    | ID do contêiner                               | -         | Ambiente    | Criação do contêiner |
| `CT_TYPE` | Tipo de contêiner ("install" ou "update")     | "install" | Ambiente    | Ponto de entrada     |
| `CT_NAME` | Nome do contêiner                             | `$APP`    | Ambiente    | Criação do contêiner |

### Variáveis ​​do Sistema Operacional

| Variável       | Descrição                      | Padrão                 | Definido em     | Usado em           |
| -------------- | ------------------------------ | ---------------------- | --------------- | ------------------ |
| `var_os`       | Seleção do sistema operacional | "debian"               | base_settings() | Seleção do SO      |
| `var_version`  | Versão do SO                   | "12"                   | base_settings() | Seleção do modelo  |
| `var_template` | Nome do modelo                 | Gerado automaticamente | base_settings() | Download do modelo |

### Variáveis ​​de Configuração de Recursos

| Variável     | Descrição                      | Padrão      | Definido em     | Usado em             |
| ------------ | ------------------------------ | ----------- | --------------- | -------------------- |
| `var_cpu`    | Núcleos da CPU                 | "2"         | base_settings() | Criação do contêiner |
| `var_ram`    | RAM em MB                      | "2048"      | base_settings() | Criação do contêiner |
| `var_disk`   | Tamanho do disco em GB         | "8"         | base_settings() | Criação de contêiner |
| `DISK_SIZE`  | Tamanho do disco (alternativo) | `$var_disk` | Ambiente        | Criação de contêiner |
| `CORE_COUNT` | Núcleos da CPU (alternativo)   | `$var_cpu`  | Ambiente        | Criação de contêiner |
| `RAM_SIZE`   | Tamanho da RAM (alternativo)   | `$var_ram`  | Ambiente        | Criação de contêiner |

### Variáveis ​​de Configuração de Rede

| Variável      | Descrição                        | Padrão                 | Definido em        | Usado em             |
| ------------- | -------------------------------- | ---------------------- | ------------------ | -------------------- |
| `var_net`     | Interface de rede                | "vmbr0"                | base_settings()    | Configuração de rede |
| `var_bridge`  | Interface de ponte               | "vmbr0"                | base_settings()    | Configuração de rede |
| `var_gateway` | IP do gateway                    | "192.168.1.1"          | base_settings()    | Configuração de rede |
| `var_ip`      | Endereço IP do contêiner         | -                      | Entrada do usuário | Configuração de rede |
| `var_ipv6`    | Endereço IPv6                    | -                      | Entrada do usuário | Configuração de rede |
| `var_vlan`    | ID da VLAN                       | -                      | Entrada do usuário | Configuração de rede |
| `var_mtu`     | Tamanho da MTU                   | "1500"                 | base_settings()    | Configuração de rede |
| `var_mac`     | Endereço MAC                     | Gerado automaticamente | base_settings()    | Configuração de rede |
| `NET`         | Interface de rede (alternativa)  | `$var_net`             | Ambiente           | Configuração de rede |
| `BRG`         | Interface de ponte (alternativa) | `$var_bridge`          | Ambiente           | Configuração de rede |
| `GATE`        | IP do gateway (alternativo)      | `$var_gateway`         | Ambiente           | Configuração de rede |
| `IPV6_METHOD` | Método de configuração IPv6      | "nenhum"               | Ambiente           | Configuração de rede |
| `VLAN`        | ID da VLAN (alternativa)         | `$var_vlan`            | Ambiente           | Configuração de rede |
| `MTU`         | Tamanho da MTU (alternativa)     | `$var_mtu`             | Ambiente           | Configuração de rede |
| `MAC`         | Endereço MAC (alternativa)       | `$var_mac`             | Ambiente           | Configuração de rede |

### Variáveis ​​de configuração de armazenamento

| Variável                | Descrição                                  | Padrão                   | Definido em      | Usado em                     |
| ----------------------- | ------------------------------------------ | ------------------------ | ---------------- | ---------------------------- |
| `var_template_storage`  | Armazenamento para modelos                 | -                        | select_storage() | Armazenamento de modelos     |
| `var_container_storage` | Armazenamento para discos de contêineres   | -                        | select_storage() | Armazenamento de contêineres |
| `TEMPLATE_STORAGE`      | Armazenamento de modelos (alternativo)     | `$var_template_storage`  | Ambiente         | Armazenamento de modelos     |
| `CONTAINER_STORAGE`     | Armazenamento de contêineres (alternativo) | `$var_container_storage` | Ambiente         | Armazenamento de contêineres |

### Flags de Recursos

| Variável         | Descrição                                   | Padrão | Definido em                         | Usado em              |
| ---------------- | ------------------------------------------- | ------ | ----------------------------------- | --------------------- |
| `var_fuse`       | Habilitar suporte a FUSE                    | "não"  | Script CT / Configurações Avançadas | Recursos do contêiner |
| `var_tun`        | Habilitar suporte a TUN/TAP                 | "não"  | Script CT / Configurações Avançadas | Recursos do contêiner |
| `var_nesting`    | Habilitar suporte a aninhamento             | "1"    | Script CT / Configurações Avançadas | Recursos do contêiner |
| `var_keyctl`     | Habilitar suporte a keyctl                  | "0"    | Script CT / Configurações Avançadas | Recursos do contêiner |
| `var_mknod`      | Permitir criação de nós de dispositivo      | "0"    | Script CT / Configurações Avançadas | Recursos do contêiner |
| `var_mount_fs`   | Montagens de sistema de arquivos permitidas | ""     | Script CT / Configurações Avançadas | Recursos do contêiner |
| `var_protection` | Habilitar proteção do contêiner             | "não"  | Script CT / Configurações Avançadas | Criação de contêiner  |
| `var_timezone`   | Fuso horário do contêiner                   | ""     | Script CT / Configurações Avançadas | Criação de contêiner  |
| `var_verbose`    | Habilitar saída detalhada                   | "não"  | Ambiente / Configurações Avançadas  | Registro              |
| `var_ssh`        | Habilitar provisionamento de chave SSH      | "não"  | Script CT / Configurações Avançadas | Configuração SSH      |
| `ENABLE_FUSE`    | Flag FUSE (interna)                         | "não"  | Configurações Avançadas             | Criação de contêiner  |
| `ENABLE_TUN`     | Flag TUN/TAP (interna)                      | "não"  | Configurações Avançadas             | Criação de contêiner  |
| `ENABLE_NESTING` | Flag de aninhamento (interna)               | "1"    | Configurações Avançadas             | Criação de contêiner  |
| `ENABLE_KEYCTL`  | Flag Keyctl (interna)                       | "0"    | Configurações Avançadas             | Criação de contêiner  |
| `ENABLE_MKNOD`   | Flag Mknod (interna)                        | "0"    | Configurações Avançadas             | Criação de contêiner  |
| `PROTECT_CT`     | Flag de proteção (interna)                  | "não"  | Configurações Avançadas             | Criação de contêiner  |
| `CT_TIMEZONE`    | Configuração de fuso horário (interna)      | ""     | Configurações Avançadas             | Criação de contêiner  |
| `VERBOSE`        | Flag de modo detalhado                      | "não"  | Ambiente                            | Registro de logs      |
| `SSH`            | Flag de acesso SSH                          | "não"  | Configurações avançadas             | Configuração SSH      |

### Configuração do APT Cacher

| Variável            | Descrição                     | Padrão | Definido em                         | Usado em                 |
| ------------------- | ----------------------------- | ------ | ----------------------------------- | ------------------------ |
| `var_apt_cacher`    | Habilitar proxy do APT cacher | "não"  | Script CT / Configurações avançadas | Gerenciamento de pacotes |
| `var_apt_cacher_ip` | IP do servidor APT cacher     | ""     | Script CT / Configurações avançadas | Gerenciamento de pacotes |
| `APT_CACHER`        | Flag do APT cacher            | "não"  | Configurações avançadas             | Criação de contêineres   |
| `APT_CACHER_IP`     | IP do APT cacher (interno)    | ""     | Configurações avançadas             | Criação de contêineres   |

### Variáveis ​​de passagem de GPU

| Variável     | Descrição                                | Padrão | Definido em                                    | Usado em             |
| ------------ | ---------------------------------------- | ------ | ---------------------------------------------- | -------------------- |
| `var_gpu`    | Habilitar passagem de GPU                | "não"  | Script CT / Ambiente / Configurações Avançadas | Passagem de GPU      |
| `ENABLE_GPU` | Sinalizador de passagem de GPU (interno) | "não"  | Configurações Avançadas                        | Criação de contêiner |

**Observação**: A passagem de GPU é controlada por meio de `var_gpu`. Aplicativos que se beneficiam da aceleração por GPU (servidores de mídia, IA/ML, transcodificação) têm `var_gpu=yes` como padrão
em seus scripts CT.

**Aplicativos com GPU habilitada por padrão**:

- Mídia: jellyfin, plex, emby, channels, ersatztv, tunarr, immich
- Transcodificação: tdarr, unmanic, fileflows
- IA/ML: ollama, openwebui
- NVR: frigate

**Exemplos de uso**:

```bash
# Disable GPU for a specific installation
var_gpu=no bash -c "$(curl -fsSL https://...jellyfin.sh)"

# Enable GPU for apps without default GPU support
var_gpu=yes bash -c "$(curl -fsSL https://...debian.sh)"

# Set in default.vars for all apps
echo "var_gpu=yes" >> /usr/local/community-scripts/default.vars
```

### Variáveis ​​de API e Diagnóstico

| Variável      | Descrição                        | Padrão    | Definida em | Usada em            |
| ------------- | -------------------------------- | --------- | ----------- | ------------------- |
| `DIAGNOSTICS` | Habilitar modo de diagnóstico    | "false"   | Ambiente    | Diagnóstico         |
| `METHOD`      | Método de instalação             | "install" | Ambiente    | Fluxo de instalação |
| `RANDOM_UUID` | UUID aleatório para rastreamento | -         | Ambiente    | Registro            |
| `API_TOKEN`   | Token da API do Proxmox          | -         | Ambiente    | Chamadas de API     |
| `API_USER`    | Usuário da API do Proxmox        | -         | Ambiente    | Chamadas de API     |

### Variáveis ​​de Persistência de Configurações

| Variável            | Descrição                                | Padrão                                            | Definido em        | Usado em                      |
| ------------------- | ---------------------------------------- | ------------------------------------------------- | ------------------ | ----------------------------- |
| `SAVE_DEFAULTS`     | Salvar configurações como padrão         | "false"                                           | Entrada do usuário | Persistência de configurações |
| `SAVE_APP_DEFAULTS` | Salvar padrões específicos do aplicativo | "false"                                           | Entrada do usuário | Persistência de configurações |
| `DEFAULT_VARS_FILE` | Caminho para default.vars                | "/usr/local/community-scripts/default.vars"       | Ambiente           | Persistência de configurações |
| `APP_DEFAULTS_FILE` | Caminho para app.vars                    | "/usr/local/community-scripts/defaults/$APP.vars" | Ambiente           | Persistência de configurações |

## Cadeia de Precedência de Variáveis

As variáveis ​​são resolvidas na seguinte ordem (da maior para a menor prioridade):

1. **Variáveis ​​de Ambiente Obrigatórias**: Definidas antes da execução do script
2. **Arquivo .vars específico do aplicativo**: `/usr/local/community-scripts/defaults/<app>.vars`
3. **Arquivo default.vars global**: `/usr/local/community-scripts/default.vars`
4. **Valores padrão internos**: Definidos na função `base_settings()`

## Variáveis ​​Críticas para Uso Não Interativo

Para execução silenciosa/não interativa, estas variáveis ​​devem ser definidas:

```bash
# Core container settings
export APP="plex"
export CTID="100"
export var_hostname="plex-server"

# OS selection
export var_os="debian"
export var_version="12"

# Resource allocation
export var_cpu="4"
export var_ram="4096"
export var_disk="20"

# Network configuration
export var_net="vmbr0"
export var_gateway="192.168.1.1"
export var_ip="192.168.1.100"

# Storage selection
export var_template_storage="local"
export var_container_storage="local"

# Feature flags
export ENABLE_FUSE="true"
export ENABLE_TUN="true"
export SSH="true"
```

## Padrões de Uso de Variáveis ​​de Ambiente

### 1. Criação de Contêiner

```bash
# Basic container creation
export APP="nextcloud"
export CTID="101"
export var_hostname="nextcloud-server"
export var_os="debian"
export var_version="12"
export var_cpu="2"
export var_ram="2048"
export var_disk="10"
export var_net="vmbr0"
export var_gateway="192.168.1.1"
export var_ip="192.168.1.101"
export var_template_storage="local"
export var_container_storage="local"
```

### 2. GPU Passagem direta

```bash
# Enable GPU passthrough
export GPU_APPS="plex,jellyfin,emby"
export var_gpu="intel"
export ENABLE_PRIVILEGED="true"
```

### 3. Configuração Avançada de Rede

```bash
# VLAN and IPv6 configuration
export var_vlan="100"
export var_ipv6="2001:db8::100"
export IPV6_METHOD="static"
export var_mtu="9000"
```

### 4. Configuração de Armazenamento

```bash
# Custom storage locations
export var_template_storage="nfs-storage"
export var_container_storage="ssd-storage"
```

## Validação de Variáveis

O script valida as variáveis ​​em vários pontos:

1. **Validação do ID do contêiner**: Deve ser único e estar dentro de um intervalo válido
2. **Validação do endereço IP**: Deve estar em um formato IPv4/IPv6 válido
3. **Validação do armazenamento**: Deve existir e suportar os tipos de conteúdo necessários
4. **Validação de recursos**: Deve estar dentro de limites razoáveis
5. **Validação da rede**: Deve ser uma configuração de rede válida

## Combinações Comuns de Variáveis

### Contêiner de Desenvolvimento

```bash
export APP="dev-container"
export CTID="200"
export var_hostname="dev-server"
export var_os="ubuntu"
export var_version="22.04"
export var_cpu="4"
export var_ram="4096"
export var_disk="20"
export ENABLE_NESTING="true"
export ENABLE_PRIVILEGED="true"
```

### Servidor de Mídia com GPU

```bash
export APP="plex"
export CTID="300"
export var_hostname="plex-server"
export var_os="debian"
export var_version="12"
export var_cpu="6"
export var_ram="8192"
export var_disk="50"
export GPU_APPS="plex"
export var_gpu="nvidia"
export ENABLE_PRIVILEGED="true"
```

### Leve Serviço

```bash
export APP="nginx"
export CTID="400"
export var_hostname="nginx-proxy"
export var_os="alpine"
export var_version="3.18"
export var_cpu="1"
export var_ram="512"
export var_disk="2"
export ENABLE_UNPRIVILEGED="true"
```
