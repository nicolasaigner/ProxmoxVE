# Documentação do install.func

## Visão geral

O arquivo `install.func` fornece orquestração do fluxo de trabalho de instalação de contêineres e operações fundamentais para aplicativos implantados em contêineres LXC. Ele lida com a configuração de rede, configuração do sistema operacional, verificação de conectividade e mecanismos de instalação.

## Finalidade e Casos de Uso

- **Configuração do Contêiner**: Inicializa um novo contêiner com a configuração adequada
- **Verificação de Rede**: Verifica a conectividade IPv4 e IPv6
- **Configuração do SO**: Atualiza o SO e aplica as configurações do sistema
- **Fluxo de Trabalho de Instalação**: Orquestra as etapas de instalação do aplicativo
- **Tratamento de Erros**: Captura abrangente de sinais e recuperação de erros

## Referência Rápida

### Grupos de Funções Principais

- **Inicialização**: `setting_up_container()` - Mensagem e ambiente de configuração
- **Rede**: `network_check()`, `verb_ip6()` - Verificação de conectividade
- **Configuração do SO**: `update_os()` - Atualizações do SO e gerenciamento de pacotes
- **Instalação**: `motd_ssh()`, `customize()` - Personalização do contêiner
- **Limpeza**: `cleanup_lxc()` - Limpeza final do contêiner

### Dependências

- **Externas**: `curl`, `apt-get` Utilitários `ping` e `dns`
- **Interno**: Utiliza funções de `core.func`, `error_handler.func` e `tools.func`

### Pontos de Integração

- Utilizado por: Todos os scripts install/\*.sh na inicialização
- Utiliza: Variáveis ​​de ambiente de build.func e core.func
- Fornece: Serviços de inicialização e gerenciamento de contêineres

## Arquivos de Documentação

### 📊 [INSTALL_FUNC_FLOWCHART.md](./INSTALL_FUNC_FLOWCHART.md)

Fluxos de execução visuais mostrando inicialização, verificações de rede e fluxos de trabalho de instalação.

### 📚 [INSTALL_FUNC_FUNCTIONS_REFERENCE.md](./INSTALL_FUNC_FUNCTIONS_REFERENCE.md)

Referência alfabética completa de todas as funções com parâmetros, dependências e detalhes de uso.

### 💡 [INSTALL_FUNC_USAGE_EXAMPLES.md](./INSTALL_FUNC_USAGE_EXAMPLES.md)

Exemplos práticos mostrando como usar funções de instalação e padrões comuns.

### 🔗 [INSTALL_FUNC_INTEGRATION.md](./INSTALL_FUNC_INTEGRATION.md)

Como install.func se integra com outros componentes e fornece serviços de instalação.

## Principais Recursos

### Inicialização do Contêiner

- **Configuração do Ambiente**: Preparar variáveis ​​e funções do contêiner
- **Sistema de Mensagens**: Exibir o progresso da instalação com saída colorida
- **Tratamento de Erros**: Configurar o tratamento de sinais para limpeza adequada

### Rede e Conectividade

- **Verificação de IPv4**: Enviar ping para hosts externos para verificar o acesso à internet
- **Suporte a IPv6**: Habilitação e verificação opcionais de IPv6
- **Verificação de DNS**: Verificar se a resolução de DNS está funcionando
- **Lógica de Repetição**: Repetições automáticas para falhas transitórias

### Configuração do SO

- **Atualizações de Pacotes**: Atualizar com segurança as listas de pacotes do SO
- **Otimização do Sistema**: Desativar serviços desnecessários (esperar online)
- **Fuso Horário**: Validar e definir o fuso horário do contêiner
- **Configuração de SSH**: Configurar o daemon e as chaves SSH

### Personalização do Contêiner

- **Mensagem do Dia**: Criar mensagem de login personalizada
- **Login Automático**: Login root opcional sem senha
- **Script de Atualização**: Registrar o aplicativo Função de atualização
- **Ganchos de personalização**: Configuração específica da aplicação

## Categorias de funções

### 🔹 Funções principais

- `setting_up_container()` - Exibe a mensagem de configuração e define o ambiente
- `network_check()` - Verifica a conectividade de rede
- `update_os()` - Atualiza os pacotes do sistema operacional com lógica de repetição
- `verb_ip6()` - Habilita o IPv6 (opcional)

### 🔹 Funções de configuração

- `motd_ssh()` - Configura a mensagem do dia (MOTD) e a configuração SSH
- `customize()` - Aplica personalizações ao contêiner
- `cleanup_lxc()` - Limpeza final antes da conclusão

### 🔹 Funções de utilitário

- `create_update_script()` - Registra a função de atualização da aplicação
- `set_timezone()` - Configura o fuso horário do contêiner
- `disable_wait_online()` - Desabilita o systemd-networkd-wait-online

## Execução Fluxo

```
Container Started
    ↓
source $FUNCTIONS_FILE_PATH
    ↓
setting_up_container()           ← Display "Setting up container..."
    ↓
network_check()                  ← Verify internet connectivity
    ↓
update_os()                      ← Update package lists
    ↓
[Application-Specific Installation]
    ↓
motd_ssh()                       ← Configure SSH/MOTD
customize()                      ← Apply customizations
    ↓
cleanup_lxc()                    ← Final cleanup
    ↓
Installation Complete
```

## Padrões de Uso Comuns

### Configuração Básica do Contêiner

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
setting_up_container
network_check
update_os

# ... application installation ...

motd_ssh
customize
cleanup_lxc
```

### Com IPv6 Opcional

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
setting_up_container
verb_ip6  # Enable IPv6
network_check
update_os

# ... installation ...

motd_ssh
customize
cleanup_lxc
```

### Com Script de Atualização Personalizado

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
setting_up_container
network_check
update_os

# ... installation ...

# Register update function
function update_script() {
  # Update logic here
}
export -f update_script

motd_ssh
customize
cleanup_lxc
```

## Melhores Práticas

### ✅ FAÇA

- Chame `setting_up_container()` no início
- Verifique a saída de `network_check()` antes da instalação principal
- Use a variável `$STD` para operações silenciosas
- Chame `cleanup_lxc()` no final
- Teste a conectividade de rede antes de operações críticas

### ❌ NÃO FAÇA

- Ignore a verificação de rede
- Presuma que a internet está disponível
- Codifique os caminhos do contêiner
- Use `echo` em vez das funções `msg_*`
- Esqueça de chamar a limpeza no final

## Ambiente Variáveis

### Variáveis ​​Disponíveis

- `$FUNCTIONS_FILE_PATH` - Caminho para as funções principais (definido por build.func)
- `$CTID` - Número de identificação do contêiner
- `$NSAPP` - Nome normalizado do aplicativo (em minúsculas)
- `$APP` - Nome de exibição do aplicativo
- `$STD` - Supressão de saída (`silencioso` ou vazio)
- `$VERBOSE` - Modo de saída detalhada (`sim` ou `não`)

### Configurando Variáveis ​​do Contêiner

```bash
CONTAINER_TIMEZONE="UTC"
CONTAINER_HOSTNAME="myapp-container"
CONTAINER_FQDN="myapp.example.com"
```

## Solução de Problemas

### "Falha na verificação de rede"

```bash
# Container may not have internet access
# Check:
ping 8.8.8.8           # External connectivity
nslookup example.com   # DNS resolution
ip route show          # Routing table
```

### "Falha na atualização do pacote"

```bash
# APT may be locked by another process
ps aux | grep apt      # Check for running apt
# Or wait for existing apt to finish
sleep 30
update_os
```

### "Não foi possível executar as funções"

```bash
# $FUNCTIONS_FILE_PATH may not be set
# This variable is set by build.func before running install script
# If missing, the install script was not called properly
```

## Documentação Relacionada

- **[tools.func/](../tools.func/)** - Instalação de pacotes e ferramentas
- **[core.func/](../core.func/)** - Funções utilitárias e mensagens
- **[error_handler.func/](../error_handler.func/)** - Tratamento de erros
- **[alpine-install.func/](../alpine-install.func/)** - Configuração específica do Alpine
- **[UPDATED_APP-install.md](../../UPDATED_APP-install.md)** - Guia de scripts de aplicativos

## Atualizações recentes

### Versão 2.0 (Dez 2025)

- ✅ Verificações de conectividade de rede aprimoradas
- ✅ Tratamento de erros de atualização do SO aprimorado
- ✅ Adicionado suporte a IPv6 com verb_ip6()
- ✅ Validação de fuso horário aprimorada
- ✅ Limpeza simplificada Procedimentos

---

**Última atualização**: dezembro de 2025
**Responsáveis**: Equipe community-scripts
**Licença**: MIT
