# Documentação de Scripts de Contêiner (/ct)

Este diretório contém documentação completa para os scripts de criação de contêineres no diretório `/ct`.

## Visão Geral

Os scripts de contêiner (`ct/*.sh`) são os pontos de entrada para a criação de contêineres LXC no Proxmox VE. Eles são executados no host e orquestram todo o processo de criação de contêineres.

## Estrutura da Documentação

Cada script possui documentação padronizada seguindo o padrão de projeto.

## Recursos Principais

- **[DETAILED_GUIDE.md](DETAILED_GUIDE.md)** - Referência completa para a criação de scripts ct
- **[../contribution/README.md](../contribution/README.md)** - Como contribuir
- **[../misc/build.func/](../misc/build.func/)** - Documentação principal do orquestrador

## Fluxo de Criação de Contêineres

```
ct/AppName.sh (host-side)
    │
    ├─ Calls: build.func (orchestrator)
    │
    ├─ Variables: var_cpu, var_ram, var_disk, var_os
    │
    └─ Creates: LXC Container
                │
                └─ Runs: install/appname-install.sh (inside)
```

## Scripts Disponíveis

Consulte o diretório `/ct` para todos os scripts de criação de contêineres. Exemplos comuns:

- `pihole.sh` - Servidor DNS/DHCP Pi-hole
- `docker.sh` - Ambiente de execução de contêineres Docker
- `wallabag.sh` - Leitura e arquivamento de artigos
- `nextcloud.sh` - Armazenamento em nuvem privada
- `debian.sh` - Contêiner Debian básico
- E mais de 30 outros...

## Início Rápido

Para entender como criar um script de contêiner:

1. Leia: [UPDATED_APP-ct.md](../UPDATED_APP-ct.md)
2. Estude: Um script semelhante existente em `/ct`
3. Copie o modelo e personalize-o
4. Teste localmente
5. Envie um PR (Pull Request)

## Contribuindo com um Novo Contêiner

1. Crie `ct/myapp.sh`
2. Crie `install/myapp-install.sh`
3. Siga o modelo em [UPDATED_APP-ct.md](../UPDATED_APP-ct.md)
4. Teste minuciosamente
5. Envie o PR com ambos os arquivos

## Tarefas Comuns

- **Adicionar novo aplicativo de contêiner** → [CONTRIBUTION_GUIDE.md](../CONTRIBUTION_GUIDE.md)
- **Depurar a criação do contêiner** → [EXIT_CODES.md](../EXIT_CODES.md)
- **Entender build.func** → [misc/build.func/](../misc/build.func/)
- **Depuração em modo de desenvolvimento** → [DEV_MODE.md](../DEV_MODE.md)

---

**Última atualização**: dezembro de 2025
**Responsáveis ​​pela manutenção**: equipe community-scripts
