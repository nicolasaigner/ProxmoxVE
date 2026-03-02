# Documentação do arquivo `error_handler.func`

## Visão geral

O arquivo `error_handler.func` fornece tratamento de erros e gerenciamento de sinais abrangentes para scripts da comunidade Proxmox. Ele oferece explicações detalhadas dos códigos de erro, recuperação de erros adequada e mecanismos de limpeza apropriados.

## Finalidade e Casos de Uso

- **Explicação de Códigos de Erro**: Fornece explicações legíveis para códigos de saída
- **Tratamento de Sinais**: Gerencia sinais SIGINT, SIGTERM e outros de forma adequada
- **Recuperação de Erros**: Implementa a limpeza e o relatório de erros adequados
- **Registro de Depuração**: Registra informações de erro para solução de problemas
- **Suporte à Execução Silenciosa**: Integra-se com a execução silenciosa do core.func

## Referência Rápida

### Grupos de Funções Principais

- **Explicação de Erros**: `explain_exit_code()` - Converte códigos de saída em mensagens legíveis
- **Tratamento de Erros**: `error_handler()` - Manipulador de erros principal com relatório detalhado
- **Manipuladores de Sinais**: `on_interrupt()`, `on_terminate()` - Tratamento de sinais adequado
- **Limpeza**: `on_exit()` - Limpeza ao término do script
- **Configuração de Captura de Erros**: `catch_errors()` - Inicializa o tratamento de erros armadilhas

### Dependências

- **Externas**: Nenhuma (implementação pura em Bash)
- **Internas**: Usa variáveis ​​de cor de core.func

### Pontos de Integração

- Usado por: Todos os scripts via execução silenciosa de core.func
- Usa: Variáveis ​​de cor de core.func
- Fornece: Explicações de erros para a função silenciosa core.func

## Arquivos de Documentação

### 📊 [ERROR_HANDLER_FLOWCHART.md](./ERROR_HANDLER_FLOWCHART.md)

Fluxos de execução visual mostrando os processos de tratamento de erros e o gerenciamento de sinais.

### 📚 [ERROR_HANDLER_FUNCTIONS_REFERENCE.md](./ERROR_HANDLER_FUNCTIONS_REFERENCE.md)

Referência alfabética completa de todas as funções com parâmetros, dependências e detalhes de uso.

### 💡 [ERROR_HANDLER_USAGE_EXAMPLES.md](./ERROR_HANDLER_USAGE_EXAMPLES.md)

Exemplos práticos mostrando como usar funções de tratamento de erros e padrões comuns.

### 🔗 [ERROR_HANDLER_INTEGRATION.md](./ERROR_HANDLER_INTEGRATION.md)

Como error_handler.func se integra com outros componentes e fornece serviços de tratamento de erros.

## Principais Recursos

### Categorias de Códigos de Erro

- **Erros Genéricos/Shell**: Códigos de saída 1, 2, 126, 127, 128, 130, 137, 139, 143
- **Erros do Gerenciador de Pacotes**: Erros do APT/DPKG (100, 101, 255)
- **Erros do Node.js**: Erros de tempo de execução do JavaScript (243-249, 254)
- **Erros do Python**: Erros de ambiente e dependências do Python (210-212)
- **Erros de Banco de Dados**: Erros do PostgreSQL, MySQL e MongoDB (231-254)
- **Erros Personalizados do Proxmox**: Erros específicos do contêiner e da VM (200-231)

### Tratamento de Sinais

- **SIGINT (Ctrl+C)**: Tratamento de interrupção controlada
- **SIGTERM**: Tratamento de encerramento controlado
- **SAÍDA**: Limpeza ao término do script
- **ERRO**: Captura de erros para falhas de comando

### Relatório de Erros

- **Mensagens Detalhadas**: Explicações de erros legíveis para humanos
- **Informações de Contexto**: Números de linha, comandos, registros de data e hora
- **Integração de Logs**: Integração silenciosa com arquivo de log
- **Registro de Depuração**: Suporte opcional para arquivo de log de depuração

## Padrões de Uso Comuns

### Configuração Básica de Tratamento de Erros

```bash
#!/usr/bin/env bash
# Basic error handling setup

source error_handler.func

# Initialize error handling
catch_errors

# Your script code here
# Errors will be automatically handled
```

### Explicação Manual de Erros

```bash
#!/usr/bin/env bash
source error_handler.func

# Get error explanation
explanation=$(explain_exit_code 127)
echo "Error 127: $explanation"
# Output: Error 127: Command not found
```

### Tratamento de Erros Personalizado

```bash
#!/usr/bin/env bash
source error_handler.func

# Custom error handling
if ! command -v required_tool >/dev/null 2>&1; then
    echo "Error: required_tool not found"
    exit 127
fi
```

## Variáveis ​​de Ambiente

### Variáveis ​​de Depuração

- `DEBUG_LOGFILE`: Caminho para o arquivo de log de depuração para registro de erros
- `SILENT_LOGFILE`: Caminho para o arquivo de log de execução silenciosa
- `STRICT_UNSET`: Habilitar o modo estrito Verificação de variáveis ​​não definidas (0/1)

### Variáveis ​​Internas

- `lockfile`: Caminho do arquivo de bloqueio para limpeza (definido pelo script de chamada)
- `exit_code`: Código de saída atual
- `command`: Comando que falhou
- `line_number`: Número da linha onde ocorreu o erro

## Categorias de Erro

### Erros Genéricos/do Shell

- **1**: Erro geral / Operação não permitida
- **2**: Uso incorreto de funções internas do shell (erro de sintaxe)
- **126**: O comando invocado não pode ser executado (problema de permissão)
- **127**: Comando não encontrado
- **128**: Argumento inválido para sair
- **130**: Terminado por Ctrl+C (SIGINT)
- **137**: Finalizado (SIGKILL / Sem memória)
- **139**: Falha de segmentação (core dumped)
- **143**: Terminado (SIGTERM)

### Gerenciador de Pacotes Erros

- **100**: Erro do gerenciador de pacotes APT (pacotes corrompidos)
- **101**: Erro de configuração do APT (sources.list inválido)
- **255**: Erro interno fatal do DPKG

### Erros do Node.js

- **243**: Memória insuficiente no heap do JavaScript
- **245**: Opção de linha de comando inválida
- **246**: Erro interno de análise do JavaScript
- **247**: Erro interno fatal
- **248**: Falha no complemento C++ inválido / N-API
- **249**: Erro do inspetor
- **254**: Erro fatal desconhecido do npm/pnpm/yarn

### Erros do Python

- **210**: Ambiente virtualenv/uv ausente ou corrompido
- **211**: Falha na resolução de dependências
- **212**: Instalação abortada (permissões ou gerenciamento externo)

### Erros de Banco de Dados

- **PostgreSQL (231-234)**: Erros de conexão, autenticação, banco de dados e consulta
- **MySQL/MariaDB (241-244)**: Erros de conexão, autenticação, banco de dados e consulta
- **MongoDB (251-254)**: Erros de conexão, autenticação, banco de dados e consulta

### Erros Personalizados do Proxmox

- **200**: Falha ao criar o arquivo de bloqueio
- **203**: Variável CTID ausente
- **204**: Variável PCT_OSTYPE ausente
- **205**: CTID inválido (<100)
- **209**: Falha na criação do contêiner
- **210**: Cluster não Quórum
- **214**: Espaço de armazenamento insuficiente
- **215**: ID do contêiner não listado
- **216**: Entrada RootFS ausente na configuração
- **217**: O armazenamento não suporta o diretório raiz
- **220**: Não foi possível resolver o caminho do modelo
- **222**: Falha no download do modelo após 3 tentativas
- **223**: Modelo não disponível após o download
- **231**: Falha na atualização/retentativa da pilha LXC

## Boas Práticas

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

1. Use explain_exit_code() para Mensagens amigáveis ​​ao usuário
2. Registrar erros em arquivos de depuração quando necessário
3. Fornecer informações de contexto (números de linha, comandos)
4. Integrar com o registro de execução silenciosa

## Solução de Problemas

### Problemas Comuns

1. **Manipulador de Erros Ausente**: Certifique-se de que error_handler.func seja carregado
2. **Trap Não Definido**: Chame catch_errors() para inicializar os traps
3. **Variáveis ​​de Cor**: Certifique-se de que core.func seja carregado para cores
4. **Arquivos de Bloqueio**: Limpe os arquivos de bloqueio em on_exit()

### Modo de Depuração

Habilite o registro de depuração para obter informações detalhadas sobre erros:

```bash
export DEBUG_LOGFILE="/tmp/debug.log"
source error_handler.func
catch_errors
```

### Teste de Código de Erro

Teste as explicações dos erros:

```bash
source error_handler.func
for code in 1 2 126 127 128 130 137 139 143; do
    echo "Code $code: $(explain_exit_code $code)"
done
```

## Documentação Relacionada

- [core.func](../core.func/) - Utilitários principais e execução silenciosa
- [build.func](../build.func/) - Criação de contêineres com tratamento de erros
- [tools.func](../tools.func/) - Utilitários estendidos com tratamento de erros
- [api.func](../api.func/) - Operações de API com tratamento de erros

---

_Esta documentação abrange o arquivo error_handler.func, que fornece tratamento de erros abrangente para todos os scripts da comunidade Proxmox._
