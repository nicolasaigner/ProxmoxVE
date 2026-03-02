# Documentação do alpine-tools.func

## Visão geral

O arquivo `alpine-tools.func` fornece funções de instalação de ferramentas específicas do Alpine Linux para gerenciamento de pacotes e serviços em contêineres Alpine LXC. Ele complementa o
`tools.func` com implementações específicas do Alpine usando o gerenciador de pacotes apk.

## Finalidade e Casos de Uso

- **Instalação de Ferramentas Alpine**: Instalar serviços e ferramentas usando apk no Alpine
- **Gerenciamento de Pacotes**: Operações seguras com apk e tratamento de erros
- **Configuração de Serviços**: Instalar e configurar serviços comuns no Alpine
- **Gerenciamento de Dependências**: Lidar com dependências de pacotes específicos do Alpine
- **Gerenciamento de Repositórios**: Configurar e gerenciar repositórios de pacotes do Alpine

## Referência Rápida

### Grupos de Funções Principais

- **Operações de Pacotes**: Comandos apk específicos do Alpine com tratamento de erros
- **Instalação de Serviços**: Instalar bancos de dados, servidores web e ferramentas no Alpine
- **Configuração de Repositórios**: Configurar repositórios de comunidade e de teste do Alpine
- **Configuração de Ferramentas**: Instalar ferramentas e utilitários de desenvolvimento

### Dependências

- **Externas**: `apk`, `curl`, `wget`
- **Internas**: Utiliza funções de `core.func` e `error_handler.func`

### Pontos de Integração

- Utilizado por: Scripts de instalação de aplicativos baseados em Alpine
- Utiliza: Variáveis ​​de ambiente de build.func
- Fornece: Serviços de instalação de pacotes e ferramentas Alpine

## Arquivos de Documentação

### 📊 [ALPINE_TOOLS_FUNC_FLOWCHART.md](./ALPINE_TOOLS_FUNC_FLOWCHART.md)

Fluxos de execução visual para operações de pacotes e instalação de ferramentas no Alpine.

### 📚 [ALPINE_TOOLS_FUNC_FUNCTIONS_REFERENCE.md](./ALPINE_TOOLS_FUNC_FUNCTIONS_REFERENCE.md)

Referência alfabética completa de todas as funções de ferramentas Alpine.

### 💡 [ALPINE_TOOLS_FUNC_USAGE_EXAMPLES.md](./ALPINE_TOOLS_FUNC_USAGE_EXAMPLES.md)

Exemplos práticos para padrões comuns de instalação no Alpine.

### 🔗 [ALPINE_TOOLS_FUNC_INTEGRATION.md](./ALPINE_TOOLS_FUNC_INTEGRATION.md)

Como o alpine-tools.func se integra aos fluxos de trabalho de instalação do Alpine.

## Principais Recursos

### Gerenciamento de Pacotes Alpine

- **apk Add**: Instalação segura de pacotes com tratamento de erros
- **apk Update**: Atualização da lista de pacotes com lógica de repetição
- **apk Del**: Remoção de pacotes e dependências
- **Configuração de Repositórios**: Adição de repositórios da comunidade e de teste

### Cobertura de Ferramentas Alpine

- **Servidores Web**: nginx, lighttpd
- **Bancos de Dados**: mariadb, postgresql, sqlite
- **Desenvolvimento**: gcc, make, git, node.js (via apk)
- **Serviços**: sshd, docker, podman
- **Utilitários**: curl, wget, htop, vim

### Tratamento de Erros

- **Lógica de Repetição**: Recuperação automática de falhas transitórias
- **Resolução de Dependências**: Tratamento de dependências ausentes
- **Gerenciamento de Bloqueios**: Aguarda a liberação de bloqueios do apk
- **Relatório de Erros**: Limpeza de mensagens de erro

## Categorias de Funções

### 🔹 Gerenciamento de Pacotes

- `apk_update()` - Atualiza pacotes Alpine com tentativas de atualização
- `apk_add()` - Instala pacotes com segurança
- `apk_del()` - Remove pacotes completamente

### 🔹 Funções de Repositório

- `add_community_repo()` - Habilita repositórios da comunidade
- `add_testing_repo()` - Habilita repositórios de teste
- `setup_apk_repo()` - Configura repositórios APK personalizados

### 🔹 Funções de Instalação de Serviços

- `setup_nginx()` - Instala e configura o nginx
- `setup_mariadb()` - Instala o MariaDB no Alpine
- `setup_postgresql()` - Instala o PostgreSQL
- `setup_docker()` - Instala o Docker no Alpine
- `setup_nodejs()` - Instala o Node.js a partir dos repositórios Alpine

### 🔹 Ferramentas de Desenvolvimento

- `setup_build_tools()` - Instala gcc, make e build-essential
- `setup_git()` - Instala o controle de versão git
- `setup_python()` - Instala Python 3 e pip

## Diferenças entre pacotes Alpine e Debian

| Pacote | Debian | Alpine |

|---------|:---:|:---:|

| nginx | ​​`apt-get install nginx` | `apk add nginx` | | mariadb | `apt-get install mariadb-server` | `apk add mariadb` | | PostgreSQL | `apt-get install postgresql` | `apk add postgresql` | |
Node.js | `apt-get install nodejs npm` | `apk add nodejs npm` | | Docker | Configuração especial | `apk add docker` | | Python | `apt-get install python3 python3-pip` | `apk add python3 py3-pip` |

## Padrões de Uso Comuns

### Instalação Básica de Ferramentas Alpine

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

# Update package lists
apk_update

# Install nginx
apk_add nginx

# Start service
rc-service nginx start
rc-update add nginx
```

### Com Repositório da Comunidade

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

# Enable community repo for more packages
add_community_repo

# Update and install
apk_update
apk_add postgresql postgresql-client

# Start service
rc-service postgresql start
```

### Ambiente de Desenvolvimento

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

# Install build tools
setup_build_tools
setup_git
setup_nodejs "20"

# Install application
git clone https://example.com/app
cd app
npm install
```

## Melhores Práticas

### ✅ FAÇA

- Sempre use `apk add --no-cache` para manter as imagens pequenas
- Chame `apk_update()` antes de instalar pacotes
- Use o repositório da comunidade para obter mais pacotes (`add_community_repo`)
- Lide com bloqueios de APK de forma adequada, utilizando lógica de repetição
- Use a variável `$STD` para controle de saída
- Verifique se a ferramenta já está instalada antes de reinstalar

### ❌ NÃO FAÇA

- Use comandos `apt-get` (o Alpine não possui apt)
- Instale pacotes sem a flag `--no-cache`
- Defina caminhos específicos do Alpine diretamente no código
- Misture comandos do Alpine e do Debian
- Esqueça de habilitar os serviços com `rc-update`
- Use `systemctl` (o Alpine possui OpenRC, não systemd)

## Configuração de Repositórios do Alpine

### Repositórios Padrão

O Alpine vem com o repositório principal habilitado por padrão. Repositórios adicionais:

```bash
# Community repository (apk add php, go, rust, etc.)
add_community_repo

# Testing repository (bleeding edge packages)
add_testing_repo
```

### Localizações dos repositórios

```bash
/etc/apk/repositories      # Main repo list
/etc/apk/keys/             # GPG keys for repos
/var/cache/apk/            # Package cache
```

## Otimização do tamanho do pacote

O Alpine foi projetado para imagens de contêiner pequenas:

```bash
# DON'T: Leaves package cache (increases image size)
apk add nginx

# DO: Remove cache to reduce size
apk add --no-cache nginx

# Expected sizes:
# Alpine base: ~5MB
# Alpine + nginx: ~10-15MB
# Debian base: ~75MB
# Debian + nginx: ~90-95MB
```

## Gerenciamento de serviços no Alpine

### Usando o OpenRC

```bash
# Start service immediately
rc-service nginx start

# Stop service
rc-service nginx stop

# Restart service
rc-service nginx restart

# Enable at boot
rc-update add nginx

# Disable at boot
rc-update del nginx

# List enabled services
rc-update show
```

## Solução de problemas

### "apk: bloqueio mantido pelo PID"

```bash
# Alpine apk database is locked (another process using apk)
# Wait a moment
sleep 5
apk_update

# Or manually:
rm /var/lib/apk/lock 2>/dev/null || true
apk update
```

### "Pacote não encontrado"

```bash
# May be in community or testing repository
add_community_repo
apk_update
apk_add package-name
```

### "Repositório não responde"

```bash
# Alpine repo may be slow or unreachable
# Try updating again with retry logic
apk_update  # Built-in retry logic

# Or manually retry
sleep 10
apk update
```

### "Falha ao iniciar o serviço"

```bash
# Check service status on Alpine
rc-service nginx status

# View logs
tail /var/log/nginx/error.log

# Verify configuration
nginx -t
```

## Documentação relacionada

- **[alpine-install.func/](../alpine-install.func/)** - Funções de instalação do Alpine
- **[tools.func/](../tools.func/)** - Instalação de ferramentas Debian/standard
- **[core.func/](../core.func/)** - Funções utilitárias
- **[error_handler.func/](../error_handler.func/)** - Tratamento de erros
- **[UPDATED_APP-install.md](../../UPDATED_APP-install.md)** - Guia de scripts de aplicativos

## Atualizações recentes

### Versão 2.0 (Dez 2025)

- ✅ Tratamento de erros e lógica de repetição de APK aprimorados
- ✅ Gerenciamento de repositórios aprimorado
- ✅ Melhor gerenciamento de serviços com OpenRC
- ✅ Adicionadas orientações de otimização específicas para Alpine
- ✅ Cache de pacotes aprimorado Gestão

---

**Última atualização:** Dezembro de 2025 **Responsáveis ​​pela manutenção:** Equipe community-scripts **Licença:** MIT
