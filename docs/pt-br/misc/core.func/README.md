# Documentação do core.func

## Visão geral

O arquivo `core.func` fornece funções utilitárias fundamentais e verificações do sistema que formam a base para todos os outros scripts do projeto Proxmox Community Scripts. Ele lida com operações básicas do sistema, elementos da interface do usuário, validação e infraestrutura principal.

## Finalidade e Casos de Uso

- **Validação do Sistema**: Verifica a compatibilidade com o Proxmox VE, a arquitetura e os requisitos do shell.
- **Interface do Usuário**: Fornece saída colorida, ícones, indicadores de carregamento e mensagens formatadas.
- **Utilitários Principais**: Funções básicas usadas em todos os scripts.
- **Tratamento de Erros**: Execução silenciosa com relatórios de erros detalhados.
- **Informações do Sistema**: Detecção do sistema operacional, gerenciamento do modo detalhado e gerenciamento de swap.

## Referência Rápida

### Grupos de Funções Principais

- **Verificações do Sistema**: `pve_check()`, `arch_check()`, `shell_check()`, `root_check()`
- **Interface do Usuário**: `msg_info()`, `msg_ok()`, `msg_error()`, `msg_warn()`, `spinner()`
- **Utilitários Principais**: `silent()`, `is_alpine()`, `is_verbose_mode()` `get_header()`
- **Gerenciamento do Sistema**: `check_or_create_swap()`, `ensure_tput()`

### Dependências

- **Externas**: `curl` para baixar cabeçalhos, `tput` para controle do terminal
- **Internas**: `error_handler.func` para explicações de erros

### Pontos de Integração

- Usado por: Todos os outros arquivos `.func` e scripts de instalação
- Usa: `error_handler.func` para explicações de erros
- Fornece: Utilitários principais para `build.func`, `tools.func`, `api.func`

## Arquivos de Documentação

### 📊 [CORE_FLOWCHART.md](./CORE_FLOWCHART.md)

Fluxos de execução visuais mostrando como as funções principais interagem e o processo de validação do sistema.

### 📚 [CORE_FUNCTIONS_REFERENCE.md](./CORE_FUNCTIONS_REFERENCE.md)

Referência alfabética completa de todas as funções com parâmetros, dependências e detalhes de uso.

### 💡 [CORE_USAGE_EXAMPLES.md](./CORE_USAGE_EXAMPLES.md)

Exemplos práticos mostrando como usar funções principais em scripts e padrões comuns.

### 🔗 [CORE_INTEGRATION.md](./CORE_INTEGRATION.md)

Como o core.func se integra com outros componentes e fornece serviços fundamentais.

## Principais Recursos

### Validação do Sistema

- **Verificação da Versão do Proxmox VE**: Compatível com PVE 8.0-8.9 e 9.0
- **Verificação da Arquitetura**: Garante a arquitetura AMD64 (exclui PiMox)
- **Verificação do Shell**: Valida o uso do shell Bash
- **Verificação de Root**: Garante privilégios de root
- **Verificação de SSH**: Alerta sobre o uso de SSH externo

### Interface do Usuário

- **Saída Colorida**: Códigos de cores ANSI para formatação da saída do terminal
- **Ícones**: Ícones simbólicos para diferentes tipos de mensagens
- **Spinners**: Indicadores de progresso animados
- **Mensagens Formatadas**: Formatação consistente de mensagens em todos os scripts

### Utilitários Principais

- **Execução Silenciosa**: Executa comandos com relatórios de erros detalhados
- **Detecção de SO**: Detecção de Alpine Linux
- **Modo Detalhado**: Gerencia configurações de saída detalhada
- **Gerenciamento de Cabeçalhos**: Baixa e exibe cabeçalhos de aplicativos
- **Gerenciamento de Swap**: Verificar e criar arquivos de swap

## Padrões de Uso Comuns

### Configuração Básica do Script

```bash
# Source core functions
source core.func

# Run system checks
pve_check
arch_check
shell_check
root_check
```

### Exibição de Mensagens

```bash
# Show progress
msg_info "Installing package..."

# Show success
msg_ok "Package installed successfully"

# Show error
msg_error "Installation failed"

# Show warning
msg_warn "This operation may take some time"
```

### Execução Silenciosa de Comandos

```bash
# Execute command silently with error handling
silent apt-get update
silent apt-get install -y package-name
```

## Variáveis ​​de Ambiente

### Variáveis ​​Principais

- `VERBOSE`: Ativar o modo de saída detalhado
- `SILENT_LOGFILE`: Caminho para o arquivo de log de execução silenciosa
- `APP`: Nome do aplicativo para exibição do cabeçalho
- `APP_TYPE`: Tipo de aplicativo (ct/vm) para caminhos de cabeçalho

### Variáveis ​​Internas

- `_CORE_FUNC_LOADED`: Impede o carregamento múltiplo
- `__FUNCTIONS_LOADED`: Impede o carregamento múltiplo de funções
- `RETRY_NUM`: Número de tentativas de repetição (padrão: 10)
- `RETRY_EVERY`: Segundos entre tentativas (padrão: 3)

## Tratamento de Erros

### Erros de Execução Silenciosa

- Os comandos executados via `silent()` capturam a saída para o arquivo de log
- Em caso de falha, exibe a explicação do código de erro
- Mostra as últimas 10 linhas da saída do log
- Fornece um comando para visualizar o log completo

### Falhas em Verificações do Sistema

- Cada função de verificação do sistema é encerrada com uma mensagem de erro apropriada
- Indicação clara do problema e como corrigi-lo
- Encerramento correto com um pequeno atraso para que o usuário leia a mensagem

## Boas Práticas

### Inicialização de Scripts

1. Carregue `core.func` primeiro
2. Execute as verificações do sistema antecipadamente
3. Configure o tratamento de erros
4. Use funções de mensagem apropriadas

### Uso de Mensagens

1. Use `msg_info()` para atualizações de progresso
2. Use `msg_ok()` para conclusões bem-sucedidas
3. Use `msg_error()` para falhas
4. Use `msg_warn()` para avisos

### Execução silenciosa

1. Use `silent()` para comandos que podem falhar
2. Verifique os códigos de retorno após a execução silenciosa
3. Forneça mensagens de erro significativas

## Solução de Problemas

### Problemas Comuns

1. **Versão do Proxmox**: Certifique-se de estar executando uma versão compatível do PVE
2. **Arquitetura**: O script funciona apenas em sistemas AMD64
3. **Shell**: Deve usar o shell Bash
4. **Permissões**: Deve ser executado como root
5. **Rede**: Avisos de SSH para conexões externas

### Modo de Depuração

Ative a saída detalhada para depuração:

```bash
export VERBOSE="yes"
source core.func
```

### Arquivos de Log

Verifique os logs de execução silenciosa:

```bash
cat /tmp/silent.$.log
```

## Documentação Relacionada

- [build.func](../build.func/) - Script principal de criação de contêineres
- [error_handler.func](../error_handler.func/) - Utilitários de tratamento de erros
- [tools.func](../tools.func/) - Funções utilitárias estendidas
- [api.func](../api.func/) - Interações com a API do Proxmox

---

_Esta documentação abrange o arquivo core.func, que fornece utilitários fundamentais para todos os scripts da comunidade Proxmox._
