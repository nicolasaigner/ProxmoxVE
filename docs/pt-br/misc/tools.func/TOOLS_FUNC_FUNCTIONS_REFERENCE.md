# Referência de funções do tools.func

Referência alfabética completa de todas as funções do tools.func, com parâmetros, uso e exemplos.

## Índice de Funções

### Gerenciamento de Pacotes

- `pkg_install()` - Instala pacotes com segurança e com possibilidade de novas tentativas
- `pkg_update()` - Atualiza listas de pacotes com possibilidade de novas tentativas
- `pkg_remove()` - Remove pacotes de forma limpa

### Gerenciamento de Repositórios

- `setup_deb822_repo()` - Adiciona um repositório no formato moderno deb822
- `cleanup_repo_metadata()` - Limpa chaves GPG e repositórios antigos
- `check_repository()` - Verifica a acessibilidade do repositório

### Funções de Instalação de Ferramentas (mais de 30)

**Linguagens de Programação**:

- `setup_nodejs(VERSION)` - Instala Node.js e npm
- `setup_php(VERSION)` - Instala PHP-FPM e CLI
- `setup_python(VERSION)` - Instala Python 3 com pip
- `setup_uv()` - Instala o Python uv (moderno e rápido)
- `setup_ruby(VERSION)` - Instala o Ruby com gem
- `setup_golang(VERSION)` - Instala a linguagem de programação Go
- `setup_java(VERSION)` - Instala o OpenJDK (Adoptium)

**Bancos de Dados**:

- `setup_mariadb()` - Instala o servidor MariaDB
- `setup_mariadb_db()` - Cria usuário/banco de dados no MariaDB
- `setup_postgresql(VERSION)` - Instala o PostgreSQL
- `setup_postgresql_db()` - Cria usuário/banco de dados no PostgreSQL
- `setup_mongodb(VERSION)` - Instala o MongoDB
- `setup_redis(VERSION)` - Instala o cache Redis
- `setup_meilisearch()` - Instala o mecanismo Meilisearch

**Servidores Web**:

- `setup_nginx()` - Instala o Nginx
- `setup_apache()` - Instala o servidor HTTP Apache
- `setup_caddy()` **Contêineres**:
- `setup_docker()` - Instalar o Docker
- `setup_podman()` - Instalar o Podman

**Desenvolvimento**:

- `setup_git()` - Instalar o Git
- `setup_docker_compose()` - Instalar o Docker Compose
- `setup_composer()` - Instalar o PHP Composer
- `setup_build_tools()` - Instalar o build-essential
- `setup_yq()` - Instalar o processador mikefarah/yq

**Monitoramento**:

- `setup_grafana()` - Instalar o Grafana
- `setup_prometheus()` - Instalar o Prometheus
- `setup_telegraf()` - Instalar o Telegraf

**Sistema**:

- `setup_wireguard()` - Instalar o WireGuard VPN
- `setup_netdata()` - Instalar o monitoramento Netdata `setup_tailscale()` - Instala o Tailscale
- (+ mais...)

---

## Funções principais

### install_packages_with_retry()

Instala um ou mais pacotes com segurança, com lógica de repetição automática (3 tentativas), atualização do APT e gerenciamento de bloqueios.

**Assinatura**:

```bash
install_packages_with_retry PACKAGE1 [PACKAGE2 ...]
```

**Parâmetros**:

- `PACKAGE1, PACKAGE2, ...` - Nomes dos pacotes a serem instalados

**Retornos**:

- `0` - Todos os pacotes instalados com sucesso
- `1` - A instalação falhou após todas as tentativas

**Recursos**:

- Define automaticamente `DEBIAN_FRONTEND=noninteractive`
- Lida com erros de bloqueio do DPKG com `dpkg --configure -a`
- Tenta novamente em caso de falhas transitórias de rede ou do APT

**Exemplo**:

```bash
install_packages_with_retry curl wget git
```

---

### upgrade_packages_with_retry()

Atualiza os pacotes instalados com a mesma lógica robusta de repetição do auxiliar de instalação.

**Assinatura**:

```bash
upgrade_packages_with_retry
```

**Retornos**:

- `0` - Atualização bem-sucedida
- `1` - Atualização falhou

---

### fetch_and_deploy_gh_release()

A principal ferramenta para baixar e instalar softwares a partir de versões do GitHub. Suporta binários, arquivos tar e pacotes Debian.

**Assinatura**:

```bash
fetch_and_deploy_gh_release APPREPO TYPE [VERSION] [DEST] [ASSET_PATTERN]
```

**Variáveis ​​de Ambiente**:

- `APPREPO`: Repositório do GitHub (ex.: `owner/repo`)
- `TYPE`: Tipo de recurso (`binary`, `tarball`, `prebuild`, `singlefile`)
- `VERSION`: Tag específica ou `latest` (Padrão: `latest`)
- `DEST`: Diretório de destino (Padrão: `/opt/$APP`)
- `ASSET_PATTERN`: Expressão regular ou padrão de string para corresponder ao recurso da versão (Obrigatório para `prebuild` e `singlefile`)

**Modos de Operação Suportados**:

- `tarball`: Baixa e extrai o arquivo tarball de origem.

- `binary`: Detecta a arquitetura do host e instala um pacote `.deb` usando `apt` ou `dpkg`.

- `prebuild`: Baixa e extrai um arquivo binário pré-compilado (suporta `.tar.gz`, `.zip`, `.tgz`, `.txz`).

- `singlefile`: Baixa um único arquivo binário para o destino.

**Variáveis ​​de Ambiente**:

- `CLEAN_INSTALL=1`: Remove todo o conteúdo do diretório de destino antes da extração.

- `DPKG_FORCE_CONFOLD=1`: Força o `dpkg` a manter os arquivos de configuração antigos durante as atualizações de pacotes.

- `SYSTEMD_OFFLINE=1`: Usado automaticamente para instalações `.deb` para evitar falhas do systemd-tmpfiles em contêineres sem privilégios.

**Exemplo**:

```bash
fetch_and_deploy_gh_release "muesli/duf" "binary" "latest" "/opt/duf" "duf_.*_linux_amd64.tar.gz"
```

---

### check_for_gh_release()

Verifica se uma versão mais recente está disponível no GitHub em comparação com a versão instalada.

**Assinatura**:

```bash
check_for_gh_release APP REPO
```

**Exemplo**:

```bash
if check_for_gh_release "nodejs" "nodesource/distributions"; then
  # update logic
fi
```

---

### prepare_repository_setup()

Realiza a preparação segura do repositório, limpando arquivos antigos, chaveiros e garantindo que o sistema APT esteja funcionando corretamente.

**Assinatura**:

```bash
prepare_repository_setup REPO_NAME [REPO_NAME2 ...]
```

**Exemplo**:

```bash
prepare_repository_setup "mariadb" "mysql"
```

---

### verify_tool_version()

Valida se a versão principal instalada corresponde à versão esperada.

**Assinatura**:

```bash
verify_tool_version NAME EXPECTED INSTALLED
```

**Exemplo**:

```bash
verify_tool_version "nodejs" "22" "$(node -v | grep -oP '^v\K[0-9]+')"
```

---

### setup_deb822_repo()

Adiciona o repositório no formato moderno deb822.

**Assinatura**:

```bash
setup_deb822_repo NAME GPG_URL REPO_URL SUITE COMPONENT [ARCHITECTURES] [ENABLED]
```

**Parâmetros**:

- `NAME` - Nome do repositório (ex.: "nodejs")
- `GPG_URL` - URL da chave GPG (ex.: https://example.com/key.gpg)
- `REPO_URL` - URL do repositório principal (ex.: https://example.com/repo)
- `SUITE` - Conjunto de repositórios (ex.: "jammy", "bookworm")
- `COMPONENT` - Componente do repositório (ex.: "main", "testing")
- `ARCHITECTURES` - Lista opcional de arquiteturas separadas por vírgula (ex.: "amd64,arm64")
- `ENABLED` - Opcional "true" ou "false" (padrão: "true")

**Retorna**:

- `0` - Repositório Adicionado com sucesso
- `1` - Falha na configuração do repositório

**Exemplo**:

```bash
setup_deb822_repo \
  "nodejs" \
  "https://deb.nodesource.com/gpgkey/nodesource.gpg.key" \
  "https://deb.nodesource.com/node_20.x" \
  "jammy" \
  "main"
```

---

### cleanup_repo_metadata()

Limpa as chaves GPG e as configurações antigas do repositório.

**Assinatura**:

```bash
cleanup_repo_metadata
```

**Parâmetros**: Nenhum

**Retorno**:

- `0` - Limpeza concluída

**Exemplo**:

```bash
cleanup_repo_metadata
```

---

## Funções de Instalação de Ferramentas

### setup_nodejs()

Instala o Node.js e o npm a partir dos repositórios oficiais. Lida com a limpeza de versões antigas (nvm) automaticamente.

**Assinatura**:

```bash
setup_nodejs
```

**Variáveis ​​de Ambiente**:

- `NODE_VERSION`: Versão principal a ser instalada (ex.: "20", "22", "24"). Padrão: "24".

- `NODE_MODULE`: Pacote npm opcional a ser instalado globalmente durante a configuração (ex.: "pnpm", "yarn").

**Exemplo**:

```bash
NODE_VERSION="22" NODE_MODULE="pnpm" setup_nodejs
```

---

### setup_php()

Instala o PHP com extensões configuráveis ​​e integração com FPM/Apache.

**Assinatura**:

```bash
setup_php
```

**Variáveis ​​de Ambiente**:

- `PHP_VERSION`: Versão a ser instalada (ex.: "8.3", "8.4"). Padrão: "8.4".

- `PHP_MODULE`: Lista de extensões adicionais separadas por vírgulas.
- `PHP_FPM`: Defina como "YES" para instalar o php-fpm.

- `PHP_APACHE`: Defina como "YES" para instalar o libapache2-mod-php.

**Exemplo**:

```bash
PHP_VERSION="8.3" PHP_FPM="YES" PHP_MODULE="mysql,xml,zip" setup_php
```

---

### setup_mariadb_db()

Cria um novo banco de dados MariaDB e um usuário dedicado com todos os privilégios. Gera automaticamente uma senha, caso não seja fornecida, e a salva em um arquivo de credenciais.

**Variáveis ​​de Ambiente**:

- `MARIADB_DB_NAME`: Nome do banco de dados (obrigatório)
- `MARIADB_DB_USER`: Nome do usuário do banco de dados (obrigatório)
- `MARIADB_DB_PASS`: Senha do usuário (opcional, gerada automaticamente se omitida)

**Exemplo**:

```bash
MARIADB_DB_NAME="myapp" MARIADB_DB_USER="myapp_user" setup_mariadb_db
```

---

### setup_postgresql_db()

Cria um novo banco de dados PostgreSQL e um usuário/função dedicado com todos os privilégios. Gera automaticamente uma senha se ela não for fornecida e a salva em um arquivo de credenciais.

**Variáveis ​​de Ambiente**:

- `PG_DB_NAME`: Nome do banco de dados (obrigatório)
- `PG_DB_USER`: Nome do usuário do banco de dados (obrigatório)
- `PG_DB_PASS`: Senha do usuário (opcional, gerada automaticamente se omitida)

---

### setup_java()

Instala o Temurin JDK.

**Assinatura**:

```bash
JAVA_VERSION="21" setup_java
```

**Parâmetros**:

- `JAVA_VERSION` - Versão do JDK (ex.: "17", "21") (padrão: "21")

**Exemplo**:

```bash
JAVA_VERSION="17" setup_java
```

---

### setup_uv()

Instala o `uv` (gerenciador de pacotes Python moderno).

**Assinatura**:

```bash
PYTHON_VERSION="3.13" setup_uv
```

**Parâmetros**:

- `PYTHON_VERSION` - Versão opcional do Python a ser pré-instalada via uv (ex.: "3.12", "3.13")

**Exemplo**:

```bash
PYTHON_VERSION="3.13" setup_uv
```

---

### setup_go()

Instala a linguagem de programação Go.

**Assinatura**:

```bash
GO_VERSION="1.23" setup_go
```

**Parâmetros**:

- `GO_VERSION` - Versão do Go a ser instalada (padrão: "1.23")

**Exemplo**:

```bash
GO_VERSION="1.24" setup_go
```

---

### setup_yq()

Instala o `yq` (processador YAML).

**Assinatura**:

```bash
setup_yq
```

**Exemplo**:

```bash
setup_yq
```

---

### setup_composer()

Instala o PHP Composer.

**Assinatura**:

```bash
setup_composer
```

**Exemplo**:

```bash
setup_composer
```

---

### setup_meilisearch()

Instala e configura o mecanismo de busca Meilisearch.

**Variáveis ​​de Ambiente**:

- `MEILISEARCH_BIND`: Endereço e porta para vinculação (Padrão: "127.0.0.1:7700")
- `MEILISEARCH_ENV`: Modo de ambiente (Padrão: "produção")

---

### setup_yq()

Instala o processador YAML `mikefarah/yq`. Remove versões incompatíveis existentes.

**Exemplo**:

```bash
setup_yq
yq eval '.app.version = "1.0.0"' -i config.yaml
```

---

### setup_composer()

Instala ou atualiza o gerenciador de pacotes PHP Composer. Lida com `COMPOSER_ALLOW_SUPERUSER` automaticamente e realiza atualizações automáticas se já estiver instalado.

**Exemplo**:

```bash
setup_php
setup_composer
$STD composer install --no-dev
```

---

### setup_build_tools()

Instale o pacote `build-essential` para compilar software.

---

### setup_uv()

Instale o gerenciador de pacotes Python moderno `uv`. Uma alternativa extremamente rápida ao pip/venv.

**Variáveis ​​de Ambiente**:

- `PYTHON_VERSION`: Versão principal/secundária a ser instalada.

**Exemplo**:

```bash
PYTHON_VERSION="3.12" setup_uv
uv sync --locked
```

---

### setup_java()

Instale o OpenJDK através do repositório Adoptium.

**Variáveis ​​de Ambiente**:

- `JAVA_VERSION`: Versão principal a ser instalada (ex.: "17", "21"). Padrão: "21".

**Exemplo**:

```bash
JAVA_VERSION="21" setup_java
```

---

```bash
setup_nodejs VERSION
```

**Parâmetros**:

- `VERSION` - Versão do Node.js (ex.: "20", "22", "lts")

**Retorna**:

- `0` - Instalação bem-sucedida
- `1` - Falha na instalação

**Cria**:

- `/opt/nodejs_version.txt` - Arquivo de versão

**Exemplo**:

```bash
setup_nodejs "20"
```

---

### setup_php(VERSION)

Instala o PHP-FPM, a CLI e extensões comuns.

**Assinatura**:

```bash
setup_php VERSION
```

**Parâmetros**:

- `VERSION` - Versão do PHP (ex.: "8.2", "8.3")

**Retorna**:

- `0` - Instalação bem-sucedida
- `1` - Falha na instalação

**Cria**:

- `/opt/php_version.txt` - Arquivo de versão

**Exemplo**:

```bash
setup_php "8.3"
```

---

### setup_mariadb()

Instala o servidor e os utilitários do cliente MariaDB.

**Assinatura**:

```bash
setup_mariadb                         # Uses distribution packages (recommended)
MARIADB_VERSION="11.4" setup_mariadb  # Uses official MariaDB repository
```

**Variáveis**:

- `MARIADB_VERSION` - (opcional) Versão específica do MariaDB

- Não definida ou `"latest"`: Usa pacotes de distribuição (mais confiável, evita problemas de espelhamento)

- Versão específica (ex.: `"11.4"`, `"12.2"`): Usa o repositório oficial do MariaDB

**Retorna**:

- `0` - Instalação bem-sucedida
- `1` - Instalação falhou

**Cria**:

- `/opt/mariadb_version.txt` - Arquivo de versão

**Exemplo**:

```bash
# Recommended: Use distribution packages (stable, no mirror issues)
setup_mariadb

# Specific version from official repository
MARIADB_VERSION="11.4" setup_mariadb
```

---

### setup_postgresql(VERSION)

Instala o servidor PostgreSQL e os utilitários de cliente.

**Assinatura**:

```bash
setup_postgresql VERSION
```

**Parâmetros**:

- `VERSION` - Versão do PostgreSQL (ex.: "14", "15", "16")

**Retorna**:

- `0` - Instalação bem-sucedida
- `1` - Falha na instalação

**Cria**:

- `/opt/postgresql_version.txt` - Arquivo de versão

**Exemplo**:

```bash
setup_postgresql "16"
```

---

### setup_docker()

Instala o Docker e a CLI do Docker.

**Assinatura**:

```bash
setup_docker
```

**Parâmetros**: Nenhum

**Retorna**:

- `0` - Instalação bem-sucedida
- `1` - Instalação falhou

**Cria**:

- `/opt/docker_version.txt` - Arquivo de versão

**Exemplo**:

```bash
setup_docker
```

---

### setup_composer()

Instala o PHP Composer (gerenciador de dependências).

**Assinatura**:

```bash
setup_composer
```

**Parâmetros**: Nenhum

**Retorna**:

- `0` - Instalação bem-sucedida
- `1` - Instalação falhou

**Cria**:

- `/usr/local/bin/composer` - Executável do Composer

**Exemplo**:

```bash
setup_composer
```

---

### setup_build_tools()

Instala as ferramentas essenciais de compilação e desenvolvimento (gcc, make, etc.).

**Assinatura**:

```bash
setup_build_tools
```

**Parâmetros**: Nenhum

**Retornos**:

- `0` - Instalação bem-sucedida
- `1` - Falha na instalação

**Exemplo**:

```bash
setup_build_tools
```

---

## Configuração do Sistema

### setting_up_container()

Exibe a mensagem de configuração e inicializa o ambiente do contêiner.

**Assinatura**:

```bash
setting_up_container
```

**Exemplo**:

```bash
setting_up_container
# Output: ⏳ Setting up container...
```

---

### motd_ssh()

Configura o daemon SSH e a mensagem do dia (MOTD) para o contêiner.

**Assinatura**:

```bash
motd_ssh
```

**Exemplo**:

```bash
motd_ssh
# Configures SSH and creates MOTD
```

---

### customize()

Aplica as personalizações do contêiner e a configuração final.

**Assinatura**:

```bash
customize
```

**Exemplo**:

```bash
customize
```

---

### cleanup_lxc()

Limpeza final de arquivos temporários e logs.

**Assinatura**:

```bash
cleanup_lxc
```

**Exemplo**:

```bash
cleanup_lxc
# Removes temp files, finalizes installation
```

---

## Padrões de Uso

### Sequência Básica de Instalação

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

pkg_update                    # Update package lists
setup_nodejs "20"             # Install Node.js
setup_mariadb                 # Install MariaDB (distribution packages)

# ... application installation ...

motd_ssh                      # Setup SSH/MOTD
customize                     # Apply customizations
cleanup_lxc                   # Final cleanup
```

### Instalação da Cadeia de Ferramentas

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

# Install full web stack
pkg_update
setup_nginx
setup_php "8.3"
setup_mariadb  # Uses distribution packages
setup_composer
```

### Com Configuração do Repositório

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

pkg_update

# Add Node.js repository
setup_deb822_repo \
  "https://deb.nodesource.com/gpgkey/nodesource.gpg.key" \
  "nodejs" \
  "jammy" \
  "https://deb.nodesource.com/node_20.x" \
  "main"

pkg_update
setup_nodejs "20"
```

---

**Última Atualização**: Dezembro de 2025
**Total de Funções**: Mais de 30
**Mantido por**: Equipe community-scripts
