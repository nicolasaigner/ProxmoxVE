# Guia de Integração do tools.func

Como o tools.func se integra com outros componentes e fornece serviços de pacotes/ferramentas para o ecossistema ProxmoxVE.

## Relações entre os componentes

### tools.func no pipeline de instalação

```
ct/AppName.sh (host)
    │
    ├─ Calls build.func
    │
    └─ Creates Container
            │
            ▼
install/appname-install.sh (container)
            │
            ├─ Sources: core.func (colors, messaging)
            ├─ Sources: error_handler.func (error handling)
            ├─ Sources: install.func (container setup)
            │
            └─ ★ Sources: tools.func ★
                        │
                        ├─ pkg_update()
                        ├─ pkg_install()
                        ├─ setup_nodejs()
                        ├─ setup_php()
                        ├─ setup_mariadb()
                        └─ ... 30+ functions
```

### Integração com core.func

**tools.func utiliza core.func para**:

- `msg_info()` - Exibir mensagens de progresso
- `msg_ok()` - Exibir mensagens de sucesso
- `msg_error()` - Exibir mensagens de erro
- `msg_warn()` - Exibir avisos
- Códigos de cores (GN, RD, YW, BL) para saída formatada
- Variável `$STD` - Controle de supressão de saída

**Exemplo**:

```bash
# tools.func internally calls:
msg_info "Installing Node.js"      # Uses core.func
setup_nodejs "20"                  # Setup happens
msg_ok "Node.js installed"         # Uses core.func
```

### Integração com error_handler.func

**tools.func utiliza error_handler.func para**:

- Mapeamento de códigos de saída para descrições de erros
- Captura automática de erros (catch_errors)
- Manipuladores de sinais (SIGINT, SIGTERM, SAÍDA)
- Relatório de erros estruturado

**Exemplo**:

```bash
# If setup_nodejs fails, error_handler catches it:
catch_errors    # Calls from error_handler.func
setup_nodejs "20"  # If this exits non-zero
                   # error_handler logs and traps it
```

### Integração com install.func

**tools.func coordena-se com install.func para**:

- Atualizações iniciais do SO (install.func) → em seguida, ferramentas (tools.func)
- Verificação de rede antes da instalação da ferramenta
- Validação do estado do gerenciador de pacotes
- Procedimentos de limpeza após a configuração da ferramenta

**Sequência**:

```bash
setting_up_container()      # From install.func
network_check()             # From install.func
update_os()                 # From install.func

pkg_update                  # From tools.func
setup_nodejs()              # From tools.func

motd_ssh()                  # From install.func
customize()                 # From install.func
cleanup_lxc()               # From install.func
```

---

## Integração com alpine-tools.func (Alpine Containers)

### Quando usar tools.func em vez de alpine-tools.func

| Recurso | tools.func (Debian) | alpine-tools.func (Alpine) |

|---------|:---:|:---:|

| Gerenciador de Pacotes | apt-get | apk | | Scripts de Instalação | install/_.sh | install/_-alpine.sh | | Configuração de Ferramentas | `setup_nodejs()` (apt) | `setup_nodejs()` (apk) | |
Repositório | `setup_deb822_repo()` | `add_community_repo()` | | Serviços | systemctl | rc-service |

### Seleção Automática

Os scripts de instalação detectam o sistema operacional e carregam as funções apropriadas:

```bash
# install/myapp-install.sh
if grep -qi 'alpine' /etc/os-release; then
  # Alpine detected - uses alpine-tools.func
  apk_update
  apk_add package
else
  # Debian detected - uses tools.func
  pkg_update
  pkg_install package
fi
```

---

## Gerenciamento de Dependências

### Dependências Externas

```
tools.func requires:
├─ curl          (for HTTP requests, GPG keys)
├─ wget          (for downloads)
├─ apt-get       (package manager)
├─ gpg           (GPG key management)
├─ openssl       (for encryption)
└─ systemctl     (service management on Debian)
```

### Dependências Internas de Funções

```
setup_nodejs()
    ├─ Calls: setup_deb822_repo()
    ├─ Calls: pkg_update()
    ├─ Calls: pkg_install()
    └─ Uses: msg_info(), msg_ok() [from core.func]

setup_mariadb()
    ├─ Calls: setup_deb822_repo()
    ├─ Calls: pkg_update()
    ├─ Calls: pkg_install()
    └─ Uses: msg_info(), msg_ok()

setup_docker()
    ├─ Calls: cleanup_repo_metadata()
    ├─ Calls: setup_deb822_repo()
    ├─ Calls: pkg_update()
    └─ Uses: msg_info(), msg_ok()
```

---

## Gráfico de Chamadas de Função

### Árvore de Dependências de Instalação Completa

```
install/app-install.sh
    │
    ├─ setting_up_container()         [install.func]
    │
    ├─ network_check()                [install.func]
    │
    ├─ update_os()                    [install.func]
    │
    ├─ pkg_update()                   [tools.func]
    │   └─ Calls: apt-get update (with retry)
    │
    ├─ setup_nodejs("20")             [tools.func]
    │   ├─ setup_deb822_repo()        [tools.func]
    │   │   └─ Calls: apt-get update
    │   ├─ pkg_update()               [tools.func]
    │   └─ pkg_install()              [tools.func]
    │
    ├─ setup_php("8.3")               [tools.func]
    │   └─ Similar to setup_nodejs
    │
    ├─ setup_mariadb("11")            [tools.func]
    │   └─ Similar to setup_nodejs
    │
    ├─ motd_ssh()                     [install.func]
    │
    ├─ customize()                    [install.func]
    │
    └─ cleanup_lxc()                  [install.func]
```

---

## Gerenciamento de Configuração

### Variáveis ​​de Ambiente Usadas por tools.func

```bash
# Output control
STD="silent"              # Suppress apt/apk output
VERBOSE="yes"             # Show all output

# Package management
DEBIAN_FRONTEND="noninteractive"

# Tool versions (optional)
NODEJS_VERSION="20"
PHP_VERSION="8.3"
POSTGRES_VERSION="16"
```

### Arquivos de Configuração de Ferramentas Criados

```
/opt/
├─ nodejs_version.txt       # Node.js version
├─ php_version.txt          # PHP version
├─ mariadb_version.txt      # MariaDB version
├─ postgresql_version.txt   # PostgreSQL version
├─ docker_version.txt       # Docker version
└─ [TOOL]_version.txt       # For all installed tools

/etc/apt/sources.list.d/
├─ nodejs.sources           # Node.js repo (deb822)
├─ docker.sources           # Docker repo (deb822)
└─ [name].sources           # Other repos (deb822)
```

---

## Integração de Tratamento de Erros

### Códigos de Saída de tools.func

| Código | Significado | Tratado por |

|------|:---:|:---:| | 0 | Sucesso | Fluxo normal | | 1 | Falha na instalação do pacote | error_handler.func | | 100-101 | Erro do APT | error_handler.func | | 127 | Comando não encontrado |
error_handler.func |

### Limpeza Automática em Caso de Falha

```bash
# If any step fails in install script:
catch_errors
pkg_update        # Fail here?
setup_nodejs      # Doesn't get here

# error_handler automatically:
├─ Logs error
├─ Captures exit code
├─ Calls cleanup_lxc()
└─ Exits with proper code
```

---

## Integração com build.func

### Fluxo Variável

```
ct/app.sh
    │
    ├─ var_cpu="2"
    ├─ var_ram="2048"
    ├─ var_disk="10"
    │
    └─ Calls: build_container()     [build.func]
              │
              └─ Creates container
                 │
                 └─ Calls: install/app-install.sh
                    │
                    └─ Uses: tools.func for installation
```

### Considerações sobre Recursos

tools.func respeita os limites de recursos do contêiner:

- Instalações de pacotes grandes respeitam a RAM alocada
- Configurações de banco de dados usam o espaço em disco alocado
- Ferramentas de compilação (gcc, make) permanecem dentro da alocação de CPU

---

## Gerenciamento de Versões

### Como tools.func Controla as Versões

Cada instalação de ferramenta cria um arquivo de versão:

```bash
# setup_nodejs() creates:
echo "20.10.5" > /opt/nodejs_version.txt

# Used by update scripts:
CURRENT=$(cat /opt/nodejs_version.txt)
LATEST=$(curl ... # fetch latest)
if [[ "$LATEST" != "$CURRENT" ]]; then
  # Update needed
fi
```

### Integração com Funções de Atualização

```bash
# In ct/app.sh:
function update_script() {
  # Check Node version
  RELEASE=$(curl ... | jq '.version')
  CURRENT=$(cat /opt/nodejs_version.txt)

  if [[ "$RELEASE" != "$CURRENT" ]]; then
    # Use tools.func to upgrade
    setup_nodejs "$RELEASE"
  fi
}
```

---

## Melhores Práticas para Integração

### ✅ FAÇA

1. **Chame as funções na ordem correta** ```bash pkg_update setup_tool "version"

   ```

   ```

2. **Use $STD para produção**

```bash
   export STD="silent"
   pkg_install curl wget
```

3. **Verifique se há instalações existentes**

```bash
   command -v nodejs >/dev/null || setup_nodejs "20"
```

4. **Coordene com install.func**

```bash
   setting_up_container
   update_os                    # From install.func
   setup_nodejs                 # From tools.func
   motd_ssh                     # Back to install.func
```

### ❌ NÃO FAÇA

1. **Não ignore pkg_update**

```bash
   # Bad - may fail due to stale cache
   pkg_install curl
```

2. **Não codifique versões diretamente no código**

```bash
   # Bad
   apt-get install nodejs=20.x

   # Good
   setup_nodejs "20"
```

3. **Não misture gerenciadores de pacotes**

```bash
   # Bad
   apt-get install curl
   apk add wget
```

4. **Não ignore erros**

```bash
   # Bad
   setup_docker || true

   # Good
   if ! setup_docker; then
     msg_error "Docker failed"
     exit 1
   fi
```

---

## Integração de Solução de Problemas Problemas

### "Falha na instalação do pacote"

- Verificação: `pkg_update` foi chamado primeiro
- Verificação: O nome do pacote está correto para o sistema operacional
- Solução: Verificar manualmente no contêiner

### "Ferramenta inacessível após a instalação"

- Verificação: A ferramenta foi adicionada ao PATH
- Verificação: O arquivo de versão foi criado
- Solução: `which toolname` para verificar

### "Conflitos de repositório"

- Verificação: Não há repositórios duplicados
- Solução: `cleanup_repo_metadata()` antes de adicionar

### "Erros específicos do Alpine ao usar ferramentas Debian"

- Problema: Uso de funções tools.func no Alpine
- Solução: Usar alpine-tools.func em vez disso

---

**Última atualização**: Dezembro de 2025 **Mantenedores**: Equipe community-scripts **Status da integração**: Todos os componentes totalmente integrados
