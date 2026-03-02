# Documentação dos Scripts de Instalação (/install)

Este diretório contém documentação completa para os scripts de instalação no diretório `/install`.

## Visão Geral

Os scripts de instalação (`install/*.sh`) são executados dentro de contêineres LXC e gerenciam a configuração, o setup e a implantação específicos de cada aplicação.

## Estrutura da Documentação

Cada categoria de script de instalação possui documentação seguindo o padrão de projeto.

## Recursos Principais

- **[DETAILED_GUIDE.md](DETAILED_GUIDE.md)** - Referência completa para a criação de scripts de instalação
- **[../contribution/README.md](../contribution/README.md)** - Como contribuir
- **[../misc/install.func/](../misc/install.func/)** - Documentação do fluxo de trabalho de instalação
- **[../misc/tools.func/](../misc/tools.func/)** - Documentação de instalação de pacotes

## Fluxo do Script de Instalação

```
install/appname-install.sh (container-side)
    │
    ├─ Sources: $FUNCTIONS_FILE_PATH
    │  ├─ core.func (messaging)
    │  ├─ error_handler.func (error handling)
    │  ├─ install.func (setup)
    │  └─ tools.func (packages & tools)
    │
    ├─ 10-Phase Installation:
    │  1. OS Setup
    │  2. Base Dependencies
    │  3. Tool Setup
    │  4. Application Download
    │  5. Configuration
    │  6. Database Setup
    │  7. Permissions
    │  8. Services
    │  9. Version Tracking
    │  10. Final Cleanup
    │
    └─ Result: Application ready
```

## Scripts de Instalação Disponíveis

Consulte o diretório `/install` para todos os scripts de instalação. Exemplos:

- `pihole-install.sh` - Instalação do Pi-hole
- `docker-install.sh` - Instalação do Docker
- `wallabag-install.sh` - Configuração do Wallabag
- `nextcloud-install.sh` - Implantação do Nextcloud
- `debian-install.sh` - Configuração básica do Debian
- E mais de 30 outros...

## Início Rápido

Para entender como criar um script de instalação:

1. Leia: [UPDATED_APP-install.md](../UPDATED_APP-install.md)
2. Estude: Um script similar existente em `/install`
3. Copie o modelo e personalize
4. Teste em um contêiner
5. Envie um PR

## Padrão de Instalação em 10 Fases

Todo script de instalação segue esta estrutura:

### Fase 1: Configuração do SO

```bash
setting_up_container
network_check
update_os
```

### Fase 2: Base Dependências

```bash
pkg_update
pkg_install curl wget git
```

### Fase 3: Configuração da Ferramenta

```bash
setup_nodejs "20"
setup_php "8.3"
setup_mariadb  # Uses distribution packages (recommended)
# MARIADB_VERSION="11.4" setup_mariadb  # For specific version
```

### Fase 4: Download do Aplicativo

```bash
git clone https://github.com/user/app /opt/app
cd /opt/app
```

### Fase 5: Configuração

```bash
# Create .env files, config files, etc.
cat > .env <<EOF
SETTING=value
EOF
```

### Fase 6: Configuração do Banco de Dados

```bash
# Create databases, users, etc.
mysql -e "CREATE DATABASE appdb"
```

### Fase 7: Permissões

```bash
chown -R appuser:appgroup /opt/app
chmod -R 755 /opt/app
```

### Fase 8: Serviços

```bash
systemctl enable app
systemctl start app
```

### Fase 9: Controle de Versão

```bash
echo "1.0.0" > /opt/app_version.txt
```

### Fase 10: Limpeza Final

```bash
motd_ssh
customize
cleanup_lxc
```

## Contribuindo com um Script de Instalação

1. Crie `ct/myapp.sh` (host script)
2. Crie `install/myapp-install.sh` (script do contêiner)
3. Siga o padrão de 10 fases em [UPDATED_APP-install.md](../UPDATED_APP-install.md)
4. Teste no contêiner real
5. Envie um PR com ambos os arquivos

## Tarefas Comuns

- **Criar novo script de instalação** → [UPDATED_APP-install.md](../UPDATED_APP-install.md)
- **Instalar Node.js/PHP/Banco de Dados** → [misc/tools.func/](../misc/tools.func/)
- **Configurar o contêiner Alpine** → [misc/alpine-install.func/](../misc/alpine-install.func/)
- **Depurar erros de instalação** → [EXIT_CODES.md](../EXIT_CODES.md)
- **Usar modo de desenvolvedor** → [DEV_MODE.md](../DEV_MODE.md)

## Alpine vs Debian

- **Baseado em Debian** → Use `tools.func`, `install.func`, `systemctl`
- **Baseado em Alpine** → Use `alpine-tools.func`, `alpine-install.func`, `rc-service`

---

**Última atualização**: dezembro de 2025
**Mantenedores**: equipe community-scripts
