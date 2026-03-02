# Fluxograma de Execução do core.func

## Fluxo de Execução Principal

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            core.func Loading                                   │
│  Entry point when core.func is sourced by other scripts                        │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Load Prevention Check                                   │
│  • Check if _CORE_FUNC_LOADED is set                                          │
│  • Return early if already loaded                                              │
│  • Set _CORE_FUNC_LOADED=1 to prevent reloading                               │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        LOAD_FUNCTIONS()                                        │
│  Main function loader - sets up all core utilities                             │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Core Function Loading Sequence                          │
│                                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐     │
│  │   color()       │  │ formatting()   │  │        icons()              │     │
│  │                 │  │                │  │                             │     │
│  │ • Set ANSI      │  │ • Set format   │  │ • Set symbolic icons        │     │
│  │   color codes   │  │   helpers      │  │ • Define message           │     │
│  │ • Define        │  │ • Tab, bold,   │  │   symbols                  │     │
│  │   colors        │  │   line reset  │  │ • Status indicators        │     │
│  └─────────────────┘  └─────────────────┘  └─────────────────────────────┘     │
│                                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐     │
│  │ default_vars()  │  │ set_std_mode()  │  │    Additional Functions   │     │
│  │                 │  │                 │  │                             │     │
│  │ • Set retry     │  │ • Set verbose   │  │ • Add more functions       │     │
│  │   variables     │  │   mode          │  │   as needed                │     │
│  │ • Initialize    │  │ • Configure     │  │                             │     │
│  │   counters      │  │   STD variable  │  │                             │     │
│  └─────────────────┘  └─────────────────┘  └─────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Fluxo de Funções de Verificação do Sistema

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        System Validation Flow                                  │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        PVE_CHECK()                                        │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Get PVE       │    │   Check PVE     │    │   Check PVE         │ │ │
│  │  │   Version       │    │   8.x Support   │    │   9.x Support       │ │ │
│  │  │                 │    │                 │    │                     │ │ │
│  │  │ • pveversion    │    │ • Allow 8.0-8.9│    │ • Allow ONLY 9.0    │ │ │
│  │  │ • Parse version │    │ • Reject others │    │ • Reject 9.1+       │ │ │
│  │  │ • Extract       │    │ • Exit if       │    │ • Exit if           │ │ │
│  │  │   major.minor  │    │   unsupported   │    │   unsupported        │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        ARCH_CHECK()                                       │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Check         │    │   AMD64 Check   │    │   PiMox Warning     │ │ │
│  │  │   Architecture  │    │                 │    │                     │ │ │
│  │  │                 │    │ • dpkg --print- │    │ • Show PiMox       │ │ │
│  │  │ • Get system    │    │   architecture  │    │   message           │ │ │
│  │  │   architecture  │    │ • Must be       │    │ • Point to ARM64   │ │ │
│  │  │ • Compare with  │    │   "amd64"       │    │   support          │ │ │
│  │  │   "amd64"       │    │ • Exit if not   │    │ • Exit script      │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        SHELL_CHECK()                                      │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Check         │    │   Bash Check    │    │   Error Handling    │ │ │
│  │  │   Shell Type    │    │                 │    │                     │ │ │
│  │  │                 │    │ • ps -p $ -o   │    │ • Clear screen      │ │ │
│  │  │ • Get current   │    │   comm=         │    │ • Show error        │ │ │
│  │  │   shell         │    │ • Must be       │    │ • Sleep and exit   │ │ │
│  │  │ • Compare with  │    │   "bash"        │    │                     │ │ │
│  │  │   "bash"        │    │ • Exit if not   │    │                     │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        ROOT_CHECK()                                       │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Check         │    │   Root Check    │    │   Sudo Check         │ │ │
│  │  │   User ID       │    │                 │    │                     │ │ │
│  │  │                 │    │ • id -u         │    │ • Check parent       │ │ │
│  │  │ • Get user ID   │    │ • Must be 0     │    │   process            │ │ │
│  │  │ • Check if      │    │ • Exit if not   │    │ • Detect sudo       │ │ │
│  │  │   root (0)      │    │   root          │    │   usage             │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Fluxo do Sistema de Mensagens

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Message System Flow                                     │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        MSG_INFO()                                         │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Message       │    │   Duplicate     │    │   Display Mode     │ │ │
│  │  │   Validation    │    │   Check         │    │   Selection         │ │ │
│  │  │                 │    │                 │    │                     │ │ │
│  │  │ • Check if      │    │ • Track shown   │    │ • Verbose mode:     │ │ │
│  │  │   message       │    │   messages      │    │   Show directly     │ │ │
│  │  │   exists        │    │ • Skip if       │    │ • Normal mode:      │ │ │
│  │  │ • Return if     │    │   already       │    │   Start spinner     │ │ │
│  │  │   empty         │    │   shown         │    │                     │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        SPINNER()                                          │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Spinner       │    │   Animation     │    │   Display            │ │ │
│  │  │   Initialization│    │   Loop          │    │   Control            │ │ │
│  │  │                 │    │                 │    │                     │ │ │
│  │  │ • Define        │    │ • Cycle through │    │ • Print spinner      │ │ │
│  │  │   characters    │    │   characters    │    │   character          │ │ │
│  │  │ • Set index     │    │ • Sleep 0.1s    │    │ • Print message      │ │ │
│  │  │ • Start loop    │    │ • Increment     │    │ • Clear line         │ │ │
│  │  │                 │    │   index         │    │                     │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        STOP_SPINNER()                                     │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Get Spinner   │    │   Kill Process  │    │   Cleanup           │ │ │
│  │  │   PID           │    │                 │    │                     │ │ │
│  │  │                 │    │ • Send TERM     │    │ • Remove PID file   │ │ │
│  │  │ • From          │    │ • Wait for      │    │ • Unset variables   │ │ │
│  │  │   SPINNER_PID   │    │   termination   │    │ • Reset terminal    │ │ │
│  │  │ • From PID      │    │ • Force kill    │    │   settings          │ │ │
│  │  │   file          │    │   if needed     │    │                     │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Fluxo de Execução Silenciosa

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        SILENT() Execution Flow                                │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        Command Execution                                   │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Setup         │    │   Execute       │    │   Capture Output    │ │ │
│  │  │   Environment   │    │   Command       │    │                     │ │ │
│  │  │                 │    │                 │    │ • Redirect stdout   │ │ │
│  │  │ • Disable       │    │ • Run command   │    │   to log file       │ │ │
│  │  │   error         │    │ • Capture       │    │ • Redirect stderr   │ │ │
│  │  │   handling      │    │   return code   │    │   to log file       │ │ │
│  │  │ • Remove        │    │ • Store exit    │    │ • Log all output    │ │ │
│  │  │   traps         │    │   code         │    │                     │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        Error Handling                                     │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Check Exit    │    │   Load Error    │    │   Display Error     │ │ │
│  │  │   Code          │    │   Handler       │    │   Information        │ │ │
│  │  │                 │    │                 │    │                     │ │ │
│  │  │ • If exit code  │    │ • Source        │    │ • Show error code   │ │ │
│  │  │   != 0          │    │   error_handler │    │ • Show explanation  │ │ │
│  │  │ • Proceed to    │    │   if needed     │    │ • Show command      │ │ │
│  │  │   error         │    │ • Get error     │    │ • Show log lines    │ │ │
│  │  │   handling      │    │   explanation   │    │ • Show full log     │ │ │
│  │  │                 │    │                 │    │   command           │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        Log Management                                      │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Log File      │    │   Log Display   │    │   Log Access        │ │ │
│  │  │   Management    │    │                 │    │                     │ │ │
│  │  │                 │    │ • Show last 10  │    │ • Provide command   │ │ │
│  │  │ • Create log    │    │   lines         │    │   to view full log  │ │ │
│  │  │   file path     │    │ • Count total   │    │ • Show line count   │ │ │
│  │  │ • Use process   │    │   lines         │    │ • Enable debugging  │ │ │
│  │  │   ID in name    │    │ • Format        │    │                     │ │ │
│  │  │                 │    │   output        │    │                     │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Fluxo de Gerenciamento de Cabeçalho

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Header Management Flow                                 │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        GET_HEADER()                                       │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Prepare       │    │   Check Local   │    │   Download Header   │ │ │
│  │  │   Parameters    │    │   File          │    │                     │ │ │
│  │  │                 │    │                 │    │ • Construct URL     │ │ │
│  │  │ • Get app name  │    │ • Check if      │    │ • Download file     │ │ │
│  │  │   from APP      │    │   file exists   │    │ • Save to local     │ │ │
│  │  │ • Get app type  │    │ • Check if      │    │   path              │ │ │
│  │  │   from APP_TYPE │    │   file has      │    │ • Return success    │ │ │
│  │  │ • Construct     │    │   content       │    │   status           │ │ │
│  │  │   paths         │    │ • Return if     │    │                     │ │ │
│  │  │                 │    │   available    │    │                     │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        HEADER_INFO()                                      │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Get Header    │    │   Clear Screen  │    │   Display Header    │ │ │
│  │  │   Content       │    │                 │    │                     │ │ │
│  │  │                 │    │ • Clear         │    │ • Show header       │ │ │
│  │  │ • Call          │    │   terminal      │    │   content if        │ │ │
│  │  │   get_header()  │    │ • Get terminal  │    │   available          │ │ │
│  │  │ • Handle        │    │   width         │    │ • Format output     │ │ │
│  │  │   errors        │    │ • Set default   │    │ • Center content    │ │ │
│  │  │ • Return        │    │   width if      │    │   if possible       │ │ │
│  │  │   content       │    │   needed        │    │                     │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Fluxo de Gerenciamento de Swap

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        CHECK_OR_CREATE_SWAP() Flow                            │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        Swap Detection                                     │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Check Active  │    │   Swap Found    │    │   No Swap Found     │ │ │
│  │  │   Swap          │    │                 │    │                     │ │ │
│  │  │                 │    │ • Show success  │    │ • Show error        │ │ │
│  │  │ • Use swapon    │    │   message        │    │   message           │ │ │
│  │  │   command       │    │ • Return 0      │    │ • Ask user for      │ │ │
│  │  │ • Check for     │    │                 │    │   creation          │ │ │
│  │  │   swap devices  │    │                 │    │ • Proceed to        │ │ │
│  │  │ • Return        │    │                 │    │   creation flow     │ │ │
│  │  │   status        │    │                 │    │                     │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        Swap Creation                                     │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   User Input    │    │   Size           │    │   File Creation     │ │ │
│  │  │   Collection    │    │   Validation     │    │                     │ │ │
│  │  │                 │    │                 │    │ • Create swap file   │ │ │
│  │  │ • Ask for       │    │ • Validate       │    │   with dd           │ │ │
│  │  │   confirmation  │    │   numeric input  │    │ • Set permissions    │ │ │
│  │  │ • Convert to    │    │ • Check range    │    │ • Format swap       │ │ │
│  │  │   lowercase     │    │ • Abort if       │    │ • Activate swap     │ │ │
│  │  │ • Check for     │    │   invalid        │    │ • Show success      │ │ │
│  │  │   y/yes         │    │                 │    │   message           │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Pontos de Integração

### Com Outros Scripts

- **build.func**: Fornece verificações do sistema e funções de interface do usuário
- **tools.func**: Usa utilitários do core para operações estendidas
- **api.func**: Usa verificações do sistema e tratamento de erros
- **error_handler.func**: Fornece explicações de erros para execução silenciosa Execução

### Dependências Externas

- **curl**: Para baixar arquivos de cabeçalho
- **tput**: Para controle do terminal (instalado se ausente)
- **swapon/mkswap**: Para gerenciamento de swap
- **pveversion**: Para verificação da versão do Proxmox

### Fluxo de Dados

- **Entrada**: Variáveis ​​de ambiente, parâmetros de comando
- **Processamento**: Validação do sistema, renderização da interface do usuário, execução de comandos
- **Saída**: Mensagens, arquivos de log, códigos de saída, alterações no estado do sistema
