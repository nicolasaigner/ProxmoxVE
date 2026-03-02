# Fluxograma de Execução de error_handler.func

## Fluxo Principal de Tratamento de Erros

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Error Handler Initialization                             │
│  Entry point when error_handler.func is sourced by other scripts                │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        CATCH_ERRORS()                                           │
│  Initialize error handling traps and strict mode                                │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Trap Setup Sequence                                      │
│                                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐      │
│  │   Set Strict    │  │   Set Error     │  │     Set Signal              │      │
│  │   Mode          │  │   Trap          │  │     Traps                   │      │
│  │                 │  │                 │  │                             │      │
│  │ • -Ee           │  │ • ERR trap      │  │ • EXIT trap                 │      │
│  │ • -o pipefail   │  │ • error_handler │  │ • INT trap                  │      │
│  │ • -u (if        │  │   function      │  │ • TERM trap                 │      │
│  │   STRICT_UNSET) │  │                 │  │                             │      │
│  └─────────────────┘  └─────────────────┘  └─────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Fluxo do Tratador de Erros

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        ERROR_HANDLER() Flow                                   │
│  Main error handler triggered by ERR trap or manual call                      │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Error Detection                                        │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    Error Information Collection                            │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Get Exit      │    │   Get Command    │    │   Get Line          │ │ │
│  │  │   Code          │    │   Information    │    │   Number            │ │ │
│  │  │                 │    │                 │    │                     │ │ │
│  │  │ • From $? or    │    │ • From          │    │ • From              │ │ │
│  │  │   parameter     │    │   BASH_COMMAND  │    │   BASH_LINENO[0]    │ │ │
│  │  │ • Store in      │    │ • Clean $STD    │    │ • Default to        │ │ │
│  │  │   exit_code     │    │   references     │    │   "unknown"         │ │ │
│  │  │                 │    │ • Store in      │    │ • Store in          │ │ │
│  │  │                 │    │   command       │    │   line_number       │ │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Success Check                                          │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    Exit Code Validation                                    │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Check Exit    │    │   Success       │    │   Error              │ │
│  │  │   Code          │    │   Path          │    │   Path               │ │
│  │  │                 │    │                 │    │                     │ │
│  │  │ • If exit_code  │    │ • Return 0      │    │ • Continue to       │ │
│  │  │   == 0          │    │ • No error      │    │   error handling    │ │
│  │  │ • Success       │    │   processing    │    │ • Process error     │ │
│  │  │ • No error      │    │                 │    │   information        │ │
│  │  │   handling      │    │                 │    │                     │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Error Processing                                       │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    Error Explanation                                      │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Get Error     │    │   Display Error  │    │   Log Error         │ │ │
│  │  │   Explanation   │    │   Information    │    │   Information        │ │ │
│  │  │                 │    │                 │    │                     │ │
│  │  │ • Call          │    │ • Show error    │    │ • Write to debug    │ │
│  │  │   explain_exit_ │    │   message        │    │   log if enabled    │ │
│  │  │   code()        │    │ • Show line     │    │ • Include           │ │
│  │  │ • Get human-    │    │   number         │    │   timestamp         │ │
│  │  │   readable      │    │ • Show command  │    │ • Include exit      │ │
│  │  │   message       │    │ • Show exit     │    │   code              │ │
│  │  │                 │    │   code          │    │ • Include command    │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Silent Log Integration                                 │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    Silent Log Display                                      │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Check Silent  │    │   Display Log   │    │   Exit with         │ │
│  │  │   Log File      │    │   Content       │    │   Error Code        │ │
│  │  │                 │    │                 │    │                     │ │
│  │  │ • Check if      │    │ • Show last 20  │    │ • Exit with         │ │
│  │  │   SILENT_       │    │   lines         │    │   original exit     │ │
│  │  │   LOGFILE set   │    │ • Show file     │    │   code              │ │
│  │  │ • Check if      │    │   path          │    │ • Terminate script  │ │
│  │  │   file exists   │    │ • Format        │    │   execution         │ │
│  │  │ • Check if      │    │   output        │    │                     │ │
│  │  │   file has      │    │                 │    │                     │ │
│  │  │   content       │    │                 │    │                     │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Fluxo de Tratamento de Sinais

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Signal Handler Flow                                    │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        Signal Detection                                   │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   SIGINT        │    │   SIGTERM       │    │     EXIT            │ │ │
│  │  │   (Ctrl+C)      │    │   (Termination) │    │     (Script End)    │ │ │
│  │  │                 │    │                 │    │                     │ │
│  │  │ • User          │    │ • System        │    │ • Normal script     │ │
│  │  │   interruption  │    │   termination   │    │   completion        │ │
│  │  │ • Graceful      │    │ • Graceful      │    │ • Error exit        │ │
│  │  │   handling      │    │   handling      │    │ • Signal exit       │ │
│  │  │ • Exit code     │    │ • Exit code     │    │ • Cleanup           │ │
│  │  │   130           │    │   143           │    │   operations        │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        ON_INTERRUPT() Flow                                   │
│  Handles SIGINT (Ctrl+C) signals                                              │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Interrupt Processing                                  │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    User Interruption Handling                              │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Display       │    │   Cleanup       │    │   Exit with         │ │ │
│  │  │   Message       │    │   Operations    │    │   Code 130          │ │ │
│  │  │                 │    │                 │    │                     │ │
│  │  │ • Show          │    │ • Stop          │    │ • Exit with         │ │
│  │  │   interruption  │    │   processes     │    │   SIGINT code       │ │
│  │  │   message       │    │ • Clean up      │    │ • Terminate script  │ │
│  │  │ • Use red       │    │   temporary     │    │   execution         │ │
│  │  │   color         │    │   files         │    │                     │ │
│  │  │ • Clear         │    │ • Remove lock   │    │                     │ │
│  │  │   terminal      │    │   files         │    │                     │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Fluxo do Tratador de Saída

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        ON_EXIT() Flow                                        │
│  Handles script exit cleanup                                                  │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Exit Cleanup                                          │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    Cleanup Operations                                      │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Lock File     │    │   Temporary     │    │   Exit with         │ │ │
│  │  │   Cleanup       │    │   File          │    │   Original Code     │ │ │
│  │  │                 │    │   Cleanup      │    │                     │ │
│  │  │ • Check if      │    │ • Remove        │    │ • Exit with         │ │
│  │  │   lockfile      │    │   temporary     │    │   original exit     │ │
│  │  │   variable set  │    │   files         │    │   code              │ │
│  │  │ • Check if      │    │ • Clean up      │    │ • Preserve exit     │ │
│  │  │   lockfile      │    │   process       │    │   status            │ │
│  │  │   exists        │    │   state         │    │ • Terminate         │ │
│  │  │ • Remove        │    │                 │    │   execution         │ │
│  │  │   lockfile      │    │                 │    │                     │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Fluxo de Explicação do Código de Erro

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        EXPLAIN_EXIT_CODE() Flow                              │
│  Converts numeric exit codes to human-readable explanations                   │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Error Code Classification                              │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    Error Code Categories                                  │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Generic/      │    │   Package       │    │   Node.js           │ │ │
│  │  │   Shell         │    │   Manager       │    │   Errors            │ │ │
│  │  │   Errors        │    │   Errors        │    │                     │ │
│  │  │                 │    │                 │    │ • 243: Out of      │ │
│  │  │ • 1: General    │    │ • 100: APT      │    │   memory            │ │
│  │  │   error         │    │   package       │    │ • 245: Invalid      │ │
│  │  │ • 2: Shell      │    │   error         │    │   option            │ │
│  │  │   builtin       │    │ • 101: APT      │    │ • 246: Parse        │ │
│  │  │   misuse        │    │   config error  │    │   error             │ │
│  │  │ • 126: Cannot   │    │ • 255: DPKG     │    │ • 247: Fatal        │ │
│  │  │   execute       │    │   fatal error   │    │   error             │ │
│  │  │ • 127: Command  │    │                 │    │ • 248: Addon        │ │
│  │  │   not found     │    │                 │    │   failure           │ │
│  │  │ • 128: Invalid  │    │                 │    │ • 249: Inspector    │ │
│  │  │   exit          │    │                 │    │   error             │ │
│  │  │ • 130: SIGINT   │    │                 │    │ • 254: Unknown      │ │
│  │  │ • 137: SIGKILL  │    │                 │    │   fatal error       │ │
│  │  │ • 139: Segfault │    │                 │    │                     │ │
│  │  │ • 143: SIGTERM  │    │                 │    │                     │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Python        │    │   Database       │    │   Proxmox           │ │ │
│  │  │   Errors         │    │   Errors         │    │   Custom            │ │ │
│  │  │                 │    │                 │    │   Errors            │ │
│  │  │ • 210: Virtual  │    │ • PostgreSQL:   │    │ • 200: Lock file    │ │
│  │  │   env missing    │    │   231-234        │    │   failed            │ │
│  │  │ • 211: Dep       │    │ • MySQL: 241-   │    │ • 203: Missing     │ │
│  │  │   resolution     │    │   244            │    │   CTID              │ │
│  │  │ • 212: Install   │    │ • MongoDB: 251- │    │ • 204: Missing     │ │
│  │  │   aborted        │    │   254            │    │   PCT_OSTYPE        │ │
│  │  │                 │    │                 │    │ • 205: Invalid      │ │
│  │  │                 │    │                 │    │   CTID              │ │
│  │  │                 │    │                 │    │ • 209: Container    │ │
│  │  │                 │    │                 │    │   creation failed   │ │
│  │  │                 │    │                 │    │ • 210: Cluster      │ │
│  │  │                 │    │                 │    │   not quorate       │ │
│  │  │                 │    │                 │    │ • 214: No storage  │ │
│  │  │                 │    │                 │    │   space             │ │
│  │  │                 │    │                 │    │ • 215: CTID not    │ │
│  │  │                 │    │                 │    │   listed            │ │
│  │  │                 │    │                 │    │ • 216: RootFS      │ │
│  │  │                 │    │                 │    │   missing           │ │
│  │  │                 │    │                 │    │ • 217: Storage      │ │
│  │  │                 │    │                 │    │   not supported     │ │
│  │  │                 │    │                 │    │ • 220: Template     │ │
│  │  │                 │    │                 │    │   path error        │ │
│  │  │                 │    │                 │    │ • 222: Template     │ │
│  │  │                 │    │                 │    │   download failed   │ │
│  │  │                 │    │                 │    │ • 223: Template     │ │
│  │  │                 │    │                 │    │   not available     │ │
│  │  │                 │    │                 │    │ • 231: LXC stack    │ │
│  │  │                 │    │                 │    │   upgrade failed    │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Default Case                                           │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    Unknown Error Handling                                  │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Check for     │    │   Return        │    │   Log Unknown        │ │ │
│  │  │   Unknown       │    │   Generic       │    │   Error              │ │ │
│  │  │   Code          │    │   Message       │    │                     │ │
│  │  │                 │    │                 │    │ • Log to debug      │ │
│  │  │ • If no match   │    │ • "Unknown      │    │   file if enabled   │ │
│  │  │   found         │    │   error"        │    │ • Include error      │ │
│  │  │ • Use default   │    │ • Return to     │    │   code               │ │
│  │  │   case          │    │   caller        │    │ • Include           │ │
│  │  │                 │    │                 │    │   timestamp         │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Fluxo de Registro de Depuração

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Debug Log Integration                                  │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    Debug Log Writing                                      │ │
│  │                                                                           │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │ │
│  │  │   Check Debug   │    │   Write Error    │    │   Format Log        │ │ │
│  │  │   Log File       │    │   Information    │    │   Entry             │ │ │
│  │  │                 │    │                 │    │                     │ │
│  │  │ • Check if       │    │ • Timestamp     │    │ • Error separator   │ │
│  │  │   DEBUG_LOGFILE  │    │ • Exit code     │    │ • Structured        │ │
│  │  │   set            │    │ • Explanation   │    │   format             │ │
│  │  │ • Check if       │    │ • Line number   │    │ • Easy to parse     │ │
│  │  │   file exists    │    │ • Command       │    │ • Easy to read      │ │
│  │  │ • Check if       │    │ • Append to     │    │                     │ │
│  │  │   file writable  │    │   file           │    │                     │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Pontos de Integração

### Com core.func

- **Execução Silenciosa**: Fornece explicações de erro para a função silent()
- **Variáveis ​​de Cor**: Usa variáveis ​​de cor para exibir erros
- **Integração de Log**: Integra-se com SILENT_LOGFILE

### Com Outros Scripts

- **Erro** **Armadilhas**: Configura uma armadilha de erro (ERR) para tratamento automático de erros
- **Armadilhas de Sinal**: Lida com os sinais SIGINT, SIGTERM e EXIT
- **Limpeza**: Fornece limpeza ao término do script

### Dependências Externas

- **Nenhuma**: Implementação em Bash puro
- **Suporte a Cores**: Requer variáveis ​​de cor de core.func
- **Arquivos de Log**: Usa operações de arquivo padrão
