# Fluxos de Execução do build.func

## Visão Geral

Este documento detalha os fluxos de execução para diferentes modos e cenários de instalação no `build.func`, incluindo precedência de variáveis, árvores de decisão e padrões de fluxo de trabalho.

## Modos de Instalação

### 1. Fluxo de Instalação Padrão

**Objetivo**: Utiliza configurações padrão integradas com interação mínima do usuário
**Caso de Uso**: Criação rápida de contêineres com configurações padrão

```
Default Install Flow:
├── start()
│   ├── Detect execution context
│   ├── Capture hard environment variables
│   └── Set CT_TYPE="install"
├── install_script()
│   ├── Display installation mode menu
│   ├── User selects "Default Install"
│   └── Proceed with defaults
├── variables()
│   ├── base_settings()  # Set built-in defaults
│   ├── Load app.vars (if exists)
│   ├── Load default.vars (if exists)
│   └── Apply variable precedence
├── build_container()
│   ├── validate_settings()
│   ├── check_conflicts()
│   └── create_lxc_container()
└── default_var_settings()
    └── Offer to save as defaults
```

**Características Principais**:

- Mínimas solicitações ao usuário
- Utiliza configurações padrão integradas
- Execução rápida
- Adequado para implantações padrão

### 2. Fluxo de Instalação Avançado

**Objetivo**: Configuração totalmente interativa por meio de menus Whiptail
**Caso de Uso**: Configuração personalizada de contêineres com controle total

```
Advanced Install Flow:
├── start()
│   ├── Detect execution context
│   ├── Capture hard environment variables
│   └── Set CT_TYPE="install"
├── install_script()
│   ├── Display installation mode menu
│   ├── User selects "Advanced Install"
│   └── Proceed with advanced configuration
├── variables()
│   ├── base_settings()  # Set built-in defaults
│   ├── Load app.vars (if exists)
│   ├── Load default.vars (if exists)
│   └── Apply variable precedence
├── advanced_settings()
│   ├── OS Selection Menu
│   ├── Resource Configuration Menu
│   ├── Network Configuration Menu
│   ├── select_storage()
│   │   ├── resolve_storage_preselect()
│   │   └── choose_and_set_storage_for_file()
│   ├── GPU Configuration Menu
│   │   └── detect_gpu_devices()
│   └── Feature Flags Menu
├── build_container()
│   ├── validate_settings()
│   ├── check_conflicts()
│   └── create_lxc_container()
└── default_var_settings()
    └── Offer to save as defaults
```

**Características Principais**:

- Configuração totalmente interativa
- Menus Whiptail para todas as opções
- Controle total sobre as configurações
- Adequado para implantações personalizadas

### 3. Fluxo com Minhas Configurações Padrão

**Objetivo**: Carrega as configurações do arquivo global default.vars
**Caso de Uso**: Utiliza configurações globais salvas anteriormente Padrões

```
My Defaults Flow:
├── start()
│   ├── Detect execution context
│   ├── Capture hard environment variables
│   └── Set CT_TYPE="install"
├── install_script()
│   ├── Display installation mode menu
│   ├── User selects "My Defaults"
│   └── Proceed with loaded defaults
├── variables()
│   ├── base_settings()  # Set built-in defaults
│   ├── Load app.vars (if exists)
│   ├── Load default.vars  # Load global defaults
│   └── Apply variable precedence
├── build_container()
│   ├── validate_settings()
│   ├── check_conflicts()
│   └── create_lxc_container()
└── default_var_settings()
    └── Offer to save as defaults
```

**Características principais**:

- Usa o arquivo global default.vars
- Interação mínima do usuário
- Consistente com as configurações anteriores
- Adequado para implantações repetidas

### 4. Fluxo de Padrões do Aplicativo

**Objetivo**: Carrega as configurações do arquivo .vars específico do aplicativo
**Caso de uso**: Usar padrões específicos do aplicativo salvos anteriormente

```
App Defaults Flow:
├── start()
│   ├── Detect execution context
│   ├── Capture hard environment variables
│   └── Set CT_TYPE="install"
├── install_script()
│   ├── Display installation mode menu
│   ├── User selects "App Defaults"
│   └── Proceed with app-specific defaults
├── variables()
│   ├── base_settings()  # Set built-in defaults
│   ├── Load app.vars  # Load app-specific defaults
│   ├── Load default.vars (if exists)
│   └── Apply variable precedence
├── build_container()
│   ├── validate_settings()
│   ├── check_conflicts()
│   └── create_lxc_container()
└── default_var_settings()
    └── Offer to save as defaults
```

**Características principais**:

- Usa o arquivo .vars específico do aplicativo
- Interação mínima do usuário
- Configurações otimizadas para o aplicativo
- Adequado para implantações específicas do aplicativo

## Cadeia de Precedência de Variáveis

### Ordem de Precedência (Mais alta para mais baixa)

1. **Variáveis ​​de Ambiente Essenciais**: Definidas antes da execução do script
2. **Arquivo .vars específico do aplicativo**: `/usr/local/community-scripts/defaults/<app>.vars`
3. **Arquivo default.vars global**: `/usr/local/community-scripts/default.vars`
4. **Valores padrão integrados**: Definidos na função `base_settings()`

### Processo de Resolução de Variáveis

```
Variable Resolution:
├── Capture hard environment variables at start()
├── Load built-in defaults in base_settings()
├── Load global default.vars (if exists)
├── Load app-specific .vars (if exists)
└── Apply precedence chain
    ├── Hard env vars override all
    ├── App.vars override default.vars and built-ins
    ├── Default.vars override built-ins
    └── Built-ins are fallback defaults
```

## Lógica de Seleção de Armazenamento

### Fluxo de Resolução de Armazenamento

```
Storage Selection:
├── Check if storage is preselected
│   ├── var_template_storage set? → Validate and use
│   └── var_container_storage set? → Validate and use
├── Count available storage options
│   ├── Only 1 option → Auto-select
│   └── Multiple options → Prompt user
├── User selection via whiptail
│   ├── Template storage selection
│   └── Container storage selection
└── Validate selected storage
    ├── Check availability
    ├── Check content type support
    └── Proceed with selection
```

### Validação de Armazenamento

```
Storage Validation:
├── Check storage exists
├── Check storage is online
├── Check content type support
│   ├── Template storage: vztmpl support
│   └── Container storage: rootdir support
├── Check available space
└── Validate permissions
```

## Fluxo de Passagem Direta da GPU

### Detecção e Configuração da GPU

```
GPU Passthrough Flow:
├── detect_gpu_devices()
│   ├── Scan for Intel GPUs
│   │   ├── Check i915 driver
│   │   └── Detect devices
│   ├── Scan for AMD GPUs
│   │   ├── Check AMDGPU driver
│   │   └── Detect devices
│   └── Scan for NVIDIA GPUs
│       ├── Check NVIDIA driver
│       ├── Detect devices
│       └── Check CUDA support
├── Check GPU passthrough eligibility
│   ├── Is app in GPU_APPS list?
│   ├── Is container privileged?
│   └── Proceed if eligible
├── GPU selection logic
│   ├── Single GPU type → Auto-select
│   └── Multiple GPU types → Prompt user
├── configure_gpu_passthrough()
│   ├── Add GPU device entries
│   ├── Configure permissions
│   └── Update container config
└── fix_gpu_gids()
    ├── Update GPU group IDs
    └── Configure access permissions
```

### Verificação de Elegibilidade da GPU

```
GPU Eligibility:
├── Check app support
│   ├── Is APP in GPU_APPS list?
│   └── Proceed if supported
├── Check container privileges
│   ├── Is ENABLE_PRIVILEGED="true"?
│   └── Proceed if privileged
└── Check hardware availability
    ├── Are GPUs detected?
    └── Proceed if available
```

## Fluxo de Configuração de Rede

### Processo de Configuração de Rede

```
Network Configuration:
├── Basic network settings
│   ├── var_net (network interface)
│   ├── var_bridge (bridge interface)
│   └── var_gateway (gateway IP)
├── IP configuration
│   ├── var_ip (IPv4 address)
│   ├── var_ipv6 (IPv6 address)
│   └── IPV6_METHOD (IPv6 method)
├── Advanced network settings
│   ├── var_vlan (VLAN ID)
│   ├── var_mtu (MTU size)
│   └── var_mac (MAC address)
└── Network validation
    ├── Check IP format
    ├── Check gateway reachability
    └── Validate network configuration
```

## Fluxo de Criação de Contêiner

### Criação de Contêiner LXC Processo

```
Container Creation:
├── create_lxc_container()
│   ├── Create basic container
│   ├── Configure network
│   ├── Set up storage
│   ├── Configure features
│   ├── Set resource limits
│   ├── Configure startup
│   └── Start container
├── Post-creation configuration
│   ├── Wait for network
│   ├── Configure GPU (if enabled)
│   ├── Set up SSH keys
│   └── Run post-install scripts
└── Finalization
    ├── Display container info
    ├── Show access details
    └── Provide next steps
```

## Fluxos de Tratamento de Erros

### Fluxo de Validação de Erros

```
Validation Error Flow:
├── validate_settings()
│   ├── Check configuration validity
│   └── Return error if invalid
├── check_conflicts()
│   ├── Check for conflicts
│   └── Return error if conflicts found
├── Error handling
│   ├── Display error message
│   ├── cleanup_on_error()
│   └── Exit with error code
└── User notification
    ├── Show error details
    └── Suggest fixes
```

### Fluxo de Erros de Armazenamento

```
Storage Error Flow:
├── Storage selection fails
├── Retry storage selection
│   ├── Show available options
│   └── Allow user to retry
├── Storage validation fails
│   ├── Show validation errors
│   └── Allow user to fix
└── Fallback to default storage
    ├── Use fallback storage
    └── Continue with creation
```

### Fluxo de Erros de GPU

```
GPU Error Flow:
├── GPU detection fails
├── Fall back to no GPU
│   ├── Disable GPU passthrough
│   └── Continue without GPU
├── GPU configuration fails
│   ├── Show configuration errors
│   └── Allow user to retry
└── GPU permission errors
    ├── Fix GPU permissions
    └── Retry configuration
```

## Fluxos de Integração

### Com Scripts de Instalação

```
Install Script Integration:
├── build.func creates container
├── Container starts successfully
├── Install script execution
│   ├── Download and install app
│   ├── Configure app settings
│   └── Set up services
└── Post-installation configuration
    ├── Verify installation
    ├── Configure access
    └── Display completion info
```

### Com a API do Proxmox

```
Proxmox API Integration:
├── API authentication
├── Container creation via API
├── Configuration updates via API
├── Status monitoring via API
└── Error handling via API
```

## Considerações de Desempenho

### Otimização do Tempo de Execução

```
Performance Optimization:
├── Parallel operations where possible
├── Minimal user interaction in default mode
├── Efficient storage selection
├── Optimized GPU detection
└── Streamlined validation
```

### Uso de Recursos

```
Resource Usage:
├── Minimal memory footprint
├── Efficient disk usage
├── Optimized network usage
└── Minimal CPU overhead
```
