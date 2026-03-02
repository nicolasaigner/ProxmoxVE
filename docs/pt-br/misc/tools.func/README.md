# Documentação do tools.func

## Visão geral

O arquivo `tools.func` fornece uma coleção abrangente de funções auxiliares para gerenciamento robusto de pacotes, gerenciamento de repositórios e instalação de ferramentas em sistemas baseados em Debian/Ubuntu. Ele é o ponto central para a instalação de serviços, bancos de dados, linguagens de programação e ferramentas de desenvolvimento em contêineres.

## Finalidade e Casos de Uso

- **Gerenciamento de Pacotes**: Operações robustas de APT/DPKG com lógica de repetição
- **Configuração de Repositórios**: Prepare e configure repositórios de pacotes com segurança
- **Instalação de Ferramentas**: Instale mais de 30 ferramentas (Node.js, PHP, bancos de dados, etc.)
- **Gerenciamento de Dependências**: Gerencie fluxos de trabalho de instalação complexos
- **Recuperação de Erros**: Recuperação automática de falhas de rede

## Referência Rápida

### Grupos de Funções Principais

- **Auxiliares de Pacotes**: `pkg_install()`, `pkg_update()`, `pkg_remove()` - Operações de APT com repetição
- **Configuração de Repositórios**: `setup_deb822_repo()` - Configuração moderna de repositórios
- **Instalação de Ferramentas**: `setup_nodejs()`, `setup_php()`, `setup_mariadb()`, etc. - Mais de 30 funções de ferramentas
- **Utilitários do Sistema**: `disable_wait_online()`, `customize()` - Otimização do sistema
- **Configuração do contêiner**: `setting_up_container()`, `motd_ssh()` - Inicialização do contêiner

### Dependências

- **Externas**: `curl`, `wget`, `apt-get`, `gpg`
- **Internas**: Usa funções de `core.func`, `install.func`, `error_handler.func`

### Pontos de integração

- Usado por: Todos os scripts de instalação para instalação de dependências
- Usa: Variáveis ​​de ambiente de build.func e core.func
- Fornece: Instalação de ferramentas, gerenciamento de pacotes e serviços de repositório

## Arquivos de documentação

### 📊 [TOOLS_FUNC_FLOWCHART.md](./TOOLS_FUNC_FLOWCHART.md)

Fluxos de execução visual mostrando os fluxos de trabalho de gerenciamento de pacotes, instalação de ferramentas e configuração de repositório. ### 📚 [TOOLS_FUNC_FUNCTIONS_REFERENCE.md](./TOOLS_FUNC_FUNCTIONS_REFERENCE.md)
Referência alfabética completa de todas as mais de 30 funções com parâmetros, dependências e detalhes de uso.

### 💡 [TOOLS_FUNC_USAGE_EXAMPLES.md](./TOOLS_FUNC_USAGE_EXAMPLES.md)

Exemplos práticos mostrando como usar as funções de instalação de ferramentas e padrões comuns.

### 🔗 [TOOLS_FUNC_INTEGRATION.md](./TOOLS_FUNC_INTEGRATION.md)

Como o tools.func se integra com outros componentes e fornece serviços de pacote/ferramenta.

### 🔧 [TOOLS_FUNC_ENVIRONMENT_VARIABLES.md](./TOOLS_FUNC_ENVIRONMENT_VARIABLES.md)

Referência completa de variáveis ​​de ambiente e opções de configuração.

## Principais Recursos

### Gerenciamento Robusto de Pacotes

- **Lógica de Repetição Automática**: 3 tentativas com recuo para falhas transitórias
- **Modo Silencioso**: Suprimir a saída com a variável `$STD`
- **Recuperação de Erros**: Limpeza automática de pacotes corrompidos
- **Operações Atômicas**: Garantir um estado consistente mesmo em caso de falha

### Cobertura de Instalação de Ferramentas

- **Ecossistema Node.js**: Node.js, npm, yarn, pnpm
- **Pilha PHP**: PHP-FPM, PHP-CLI, Composer
- **Bancos de Dados**: MariaDB, PostgreSQL, MongoDB
- **Ferramentas de Desenvolvimento**: Git, build-essential, Docker
- **Monitoramento**: Grafana, Prometheus, Telegraf
- **E mais de 20 outras...**

### Gerenciamento de Repositórios

- **Formato Deb822**: Formato de repositório moderno e padronizado
- **Gerenciamento de Chaveiros**: Chave GPG automática Gerenciamento
- **Limpeza**: Remove repositórios e chaveiros legados
- **Validação**: Verifica a acessibilidade do repositório antes do uso

## Padrões de Uso Comuns

### Instalando uma Ferramenta

```bash
setup_nodejs "20"     # Install Node.js v20
setup_php "8.2"       # Install PHP 8.2
setup_mariadb         # Install MariaDB (distribution packages)
# MARIADB_VERSION="11.4" setup_mariadb  # Specific version from official repo
```

### Operações Seguras de Pacotes

```bash
pkg_update           # Update package lists with retry
pkg_install curl wget  # Install packages safely
pkg_remove old-tool   # Remove package cleanly
```

### Configurando Repositórios

```bash
setup_deb822_repo "ppa:example/ppa" "example-app" "jammy" "http://example.com" "release"
```

## Categorias de Funções

### 🔹 Funções Principais de Pacotes

- `pkg_install()` - Instala pacotes com lógica de repetição
- `pkg_update()` - Atualiza listas de pacotes com segurança
- `pkg_remove()` - Remove pacotes completamente

### 🔹 Funções de Repositório

- `setup_deb822_repo()` - Adiciona um repositório no formato deb822
- `cleanup_repo_metadata()` - Limpa chaves GPG e repositórios antigos
- `check_repository()` - Verifica se o repositório está acessível

### 🔹 Funções de Instalação de Ferramentas (mais de 30)

**Linguagens de Programação**:

- `setup_nodejs()` - Node.js com npm
- `setup_php()` - PHP-FPM e CLI
- `setup_python()` - Python 3 com pip
- `setup_ruby()` - Ruby com gem
- `setup_golang()` - Linguagem de programação Go

**Bancos de Dados**:

- `setup_mariadb()` - Servidor MariaDB
- `setup_postgresql()` - Banco de dados PostgreSQL
- `setup_mongodb()` - MongoDB NoSQL
- `setup_redis()` - Cache Redis

**Servidores Web e Proxies**:

- `setup_nginx()` - Servidor web Nginx
- `setup_apache()` - Servidor HTTP Apache
- `setup_caddy()` - Servidor web Caddy
- `setup_traefik()` - Proxy reverso Traefik

**Contêineres e Virtualização**:

- `setup_docker()` - Ambiente de execução de contêineres Docker
- `setup_podman()` - Ambiente de execução de contêineres Podman

**Ferramentas de Desenvolvimento e Sistema**:

- `setup_git()` - Controle de versão Git
- `setup_docker_compose()` - Docker Compose
- `setup_composer()` - Gerenciador de dependências PHP
- `setup_build_tools()` - Ferramentas de compilação C/C++

**Monitoramento e Registro de Logs**:

- `setup_grafana()` - Painéis do Grafana
- `setup_prometheus()` - Monitoramento do Prometheus
- `setup_telegraf()` - Coletor de métricas do Telegraf

### 🔹 Funções de Configuração do Sistema

- `setting_up_container()` - Mensagem de inicialização do contêiner
- `network_check()` - Verificar conectividade de rede
- `update_os()` - Atualizar pacotes do sistema operacional com segurança
- `customize()` - Aplicar Personalizações do contêiner
- `motd_ssh()` - Configurar SSH e MOTD
- `cleanup_lxc()` - Limpeza final do contêiner

## Boas Práticas

### ✅ FAÇA

- Use `$STD` para suprimir a saída em scripts de produção
- Instale várias ferramentas em sequência
- Verifique a disponibilidade da ferramenta antes de usá-la
- Use parâmetros de versão quando disponíveis
- Teste novos repositórios antes de usá-los em produção

### ❌ NÃO FAÇA

- Misture gerenciadores de pacotes (apt e apk no mesmo script)
- Codifique as versões das ferramentas diretamente
- Ignore a verificação de erros em operações de pacotes
- Use `apt-get install -y` sem `$STD`
- Deixe arquivos temporários após a instalação

## Atualizações Recentes

### Versão 2.0 (Dez 2025)

- ✅ Adicionada `setup_deb822_repo()` para o formato de repositório moderno
- ✅ Melhoria no tratamento de erros com limpeza automática
- ✅ Adicionadas 5 novas ferramentas Funções de instalação
- ✅ Lógica de repetição de pacotes aprimorada com recuo
- ✅ Manipulação padronizada de versões de ferramentas

## Integração com outras funções

```
tools.func
    ├── Uses: core.func (messaging, colors)
    ├── Uses: error_handler.func (exit codes, trapping)
    ├── Uses: install.func (network_check, update_os)
    │
    └── Used by: All install/*.sh scripts
        ├── For: Package installation
        ├── For: Tool setup
        └── For: Repository management
```

## Solução de problemas

### "Gerenciador de pacotes bloqueado"

```bash
# Wait for apt lock to release
sleep 10
pkg_update
```

### "Chave GPG não encontrada"

```bash
# Repository setup will handle this automatically
# If manual fix needed:
cleanup_repo_metadata
setup_deb822_repo ...
```

### "Falha na instalação da ferramenta"

```bash
# Enable verbose output
export var_verbose="yes"
setup_nodejs "20"
```

## Contribuições

Ao adicionar novas funções de instalação de ferramentas:

1. Siga a convenção de nomenclatura `setup_TOOLNAME()`
2. Aceite a versão como primeiro parâmetro
3. Verifique se a ferramenta já está instalada
4. Use `$STD` para suprimir a saída
5. Defina o arquivo de versão: `/opt/TOOLNAME_version.txt`
6. Documente em TOOLS_FUNC_FUNCTIONS_REFERENCE.md

## Documentação relacionada

- **[build.func/](../build.func/)** - Orquestrador de criação de contêineres
- **[core.func/](../core.func/)** - Funções utilitárias e mensagens
- **[install.func/](../install.func/)** - Gerenciamento do fluxo de trabalho de instalação
- **[error_handler.func/](../error_handler.func/)** - Tratamento e recuperação de erros
- **[UPDATED_APP-install.md](../../UPDATED_APP-install.md)** - Guia de scripts de aplicativos

---

**Última atualização**: dezembro de 2025
**Mantenedores**: Equipe community-scripts
**Licença**: MIT
