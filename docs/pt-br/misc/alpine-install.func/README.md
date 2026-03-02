# Documentação do alpine-install.func

## Visão geral

O arquivo `alpine-install.func` fornece funções de instalação e configuração específicas do Alpine Linux para contêineres LXC. Ele complementa o `install.func` padrão com operações específicas do
Alpine, utilizando o gerenciador de pacotes apk em vez do apt.

## Finalidade e Casos de Uso

- **Configuração de Contêineres Alpine**: Inicializa contêineres Alpine Linux com a configuração adequada
- **Gerenciamento de IPv6**: Habilita ou desabilita IPv6 no Alpine com configuração persistente
- **Verificação de Rede**: Verifica a conectividade em ambientes Alpine
- **Configuração de SSH**: Configura o daemon SSH no Alpine
- **Configuração de Login Automático**: Configura o login de root sem senha para contêineres Alpine
- **Gerenciamento de Pacotes**: Operações seguras com APKs e tratamento de erros

## Referência Rápida

### Grupos de Funções Principais

- **Inicialização**: `setting_up_container()` - Mensagem de configuração do Alpine
- **Rede**: `verb_ip6()`, `network_check()` - IPv6 e conectividade
- **Configuração do SO**: `update_os()` - Atualizações de pacotes do Alpine
- **SSH/MOTD**: `motd_ssh()` - Configuração de SSH e mensagem de login
- **Personalização do Contêiner**: `customize()`, `cleanup_lxc()` - Finalização Configuração

### Dependências

- **Externas**: `apk`, `curl`, `wget`, `ping`
- **Internas**: Usa funções de `core.func`, `error_handler.func`

### Pontos de Integração

- Usado por: Scripts de instalação baseados em Alpine (alpine.sh, alpine-ntfy.sh, etc.)
- Usa: Variáveis ​​de ambiente de build.func
- Fornece: Serviços de instalação e gerenciamento específicos do Alpine

## Arquivos de Documentação

### 📊 [ALPINE_INSTALL_FUNC_FLOWCHART.md](./ALPINE_INSTALL_FUNC_FLOWCHART.md)

Fluxos de execução visual mostrando os fluxos de trabalho de inicialização e configuração de contêineres Alpine.

### 📚 [ALPINE_INSTALL_FUNC_FUNCTIONS_REFERENCE.md](./ALPINE_INSTALL_FUNC_FUNCTIONS_REFERENCE.md)

Referência alfabética completa de todas as funções com parâmetros e detalhes de uso.

### 💡 [ALPINE_INSTALL_FUNC_USAGE_EXAMPLES.md](./ALPINE_INSTALL_FUNC_USAGE_EXAMPLES.md)

Exemplos práticos mostrando como usar as funções de instalação do Alpine.

### 🔗 [ALPINE_INSTALL_FUNC_INTEGRATION.md](./ALPINE_INSTALL_FUNC_INTEGRATION.md)

Como o alpine-install.func se integra aos fluxos de trabalho de instalação padrão.

## Principais Recursos

### Funções Específicas do Alpine

- **Gerenciador de Pacotes apk**: Operações com pacotes Alpine (em vez de apt-get)
- **Suporte a OpenRC**: O Alpine usa o init OpenRC em vez do systemd
- **Configuração Leve**: Dependências mínimas apropriadas para o Alpine
- **Configuração IPv6**: Configurações IPv6 persistentes via `/etc/network/interfaces`

### Rede e Conectividade

- **Alternar IPv6**: Habilitar/desabilitar com configuração persistente
- **Verificação de Conectividade**: Verificar o acesso à internet no Alpine
- **Verificação de DNS**: Resolver nomes de domínio corretamente
- **Lógica de Repetição**: Recuperação automática de falhas transitórias

### SSH e Login Automático

- **Daemon SSH**: Configurar e iniciar o sshd no Alpine
- **Chaves de Root**: Configurar o acesso SSH de root
- **Login Automático**: Login automático opcional sem senha
- **MOTD**: Mensagem de login personalizada no Alpine

## Categorias de Funções

### 🔹 Funções principais

- `setting_up_container()` - Mensagem de configuração do contêiner Alpine
- `update_os()` - Atualizar pacotes Alpine via APK
- `verb_ip6()` - Habilitar/desabilitar IPv6 permanentemente
- `network_check()` - Verificar conectividade de rede

### 🔹 Funções de SSH e configuração

- `motd_ssh()` - Configurar o daemon SSH no Alpine
- `customize()` - Aplicar personalizações específicas do Alpine
- `cleanup_lxc()` - Limpeza final

### 🔹 Gerenciamento de serviços (OpenRC)

- `rc-update` - Habilitar/desabilitar serviços para o Alpine
- `rc-service` - Iniciar/parar serviços no Alpine
- Arquivos de configuração de serviços em `/etc/init.d/`

## Diferenças em relação à instalação do Debian

| Recurso | Debian (install.func) | Alpine (alpine-install.func) |

|---------|:---:|:---:|

| Gerenciador de Pacotes | apt-get | apk | | Sistema de Inicialização | systemd | OpenRC | | Serviço SSH | systemctl | rc-service | | Arquivos de Configuração | /etc/systemd/ | /etc/init.d/ | |
Configuração de Rede | /etc/network/ ou Netplan | /etc/network/interfaces | | Configuração de IPv6 | arquivos netplan | /etc/network/interfaces | | Login Automático | sobrescrita do getty |
`/etc/inittab` ou configuração do shell | | Tamanho | ~200MB | ~100MB |

Fluxo de Execução para Alpine

```
Alpine Container Started
    ↓
source $FUNCTIONS_FILE_PATH
    ↓
setting_up_container()           ← Alpine setup message
    ↓
update_os()                      ← apk update
    ↓
verb_ip6()                       ← IPv6 configuration (optional)
    ↓
network_check()                  ← Verify connectivity
    ↓
[Application-Specific Installation]
    ↓
motd_ssh()                       ← Configure SSH/MOTD
customize()                      ← Apply customizations
    ↓
cleanup_lxc()                    ← Final cleanup
    ↓
Alpine Installation Complete
```

Padrões de Uso Comuns

Configuração Básica do Alpine

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
setting_up_container
update_os

# Install Alpine-specific packages
apk add --no-cache curl wget git

# ... application installation ...

motd_ssh
customize
cleanup_lxc
```

Com IPv6 Habilitado

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
setting_up_container
verb_ip6
update_os
network_check

# ... application installation ...

motd_ssh
customize
cleanup_lxc
```

Instalando Serviços

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
setting_up_container
update_os

# Install via apk
apk add --no-cache nginx

# Enable and start service on Alpine
rc-update add nginx
rc-service nginx start

motd_ssh
customize
cleanup_lxc
```

Melhores Práticas

### ✅ FAÇA

- Use `apk add --no-cache` para reduzir o tamanho da imagem
- Habilite o IPv6 se o aplicativo precisar (`verb_ip6`)
- Use `rc-service` para gerenciamento de serviços no Alpine
- Verifique `/etc/network/interfaces` para persistência de IPv6
- Teste a conectividade de rede antes de operações críticas
- Use `$STD` para supressão de saída em produção

### ❌ NÃO FAÇA

- Use comandos `apt-get` (o Alpine não possui apt)
- Use `systemctl` (o Alpine usa OpenRC, não systemd)
- Use o comando `service` (pode não existir no Alpine)
- Assuma que o systemd existe no Alpine
- Esqueça de adicionar a flag `--no-cache` ao `apk add`
- Codifique caminhos do Debian (diferentes no Alpine)

## Considerações Específicas do Alpine

### Nomes de Pacotes

Alguns pacotes têm nomes diferentes em Alpine:

```bash
# Debian        → Alpine
# curl          → curl (same)
# wget          → wget (same)
# python3       → python3 (same)
# libpq5        → postgresql-client
# libmariadb3   → mariadb-client
```

### Gerenciamento de Serviços

```bash
# Debian (systemd)      → Alpine (OpenRC)
systemctl start nginx   → rc-service nginx start
systemctl enable nginx  → rc-update add nginx
systemctl status nginx  → rc-service nginx status
```

### Configuração de Rede

```bash
# Debian (Netplan)                → Alpine (/etc/network/interfaces)
/etc/netplan/01-*.yaml            → /etc/network/interfaces
netplan apply                      → Configure directly in interfaces

# Enable IPv6 persistently on Alpine:
# Add to /etc/network/interfaces:
# iface eth0 inet6 static
#     address <IPv6_ADDRESS>
```

## Solução de Problemas

### "Comando apk não encontrado"

- Este é o Alpine Linux, não o Debian
- Instale os pacotes com `apk add` em vez de `apt-get install`
- Exemplo: `apk add --no-cache curl wget`

### "IPv6 não persiste após a reinicialização"

- O IPv6 deve ser configurado em `/etc/network/interfaces`
- A função `verb_ip6()` lida com isso automaticamente
- Verifique: `cat /etc/network/interfaces`

### "Serviço não inicia no Alpine"

- O Alpine usa OpenRC, não systemd
- Use `rc-service nginx start` em vez de `systemctl start nginx`
- Habilite o serviço: `rc-update add` nginx
- Verifique os logs: `/var/log/` ou `rc-service nginx status`

### "Contêiner muito grande"

- O Alpine deve ser muito menor que o Debian
- Verifique usando `apk add --no-cache` (remove o cache de pacotes)
- Exemplo: `apk add --no-cache nginx` (não `apk add nginx`)

## Documentação relacionada

- **[alpine-tools.func/](../alpine-tools.func/)** - Instalação de ferramentas Alpine
- **[install.func/](../install.func/)** - Funções de instalação padrão
- **[core.func/](../core.func/)** - Funções utilitárias
- **[error_handler.func/](../error_handler.func/)** - Tratamento de erros
- **[UPDATED_APP-install.md](../../UPDATED_APP-install.md)** - Guia de scripts de aplicativos

## Atualizações recentes

### Versão 2.0 (dezembro de 2025)

- ✅ Configuração de persistência IPv6 aprimorada
- ✅ Gerenciamento de serviço OpenRC aprimorado
- ✅ Melhor tratamento de erros de APK
- ✅ Adicionada documentação de melhores práticas específica para Alpine
- ✅ Configuração SSH simplificada para Alpine

---

**Última atualização**: dezembro de 2025 **Mantenedores**: Equipe community-scripts **Licença**: MIT
