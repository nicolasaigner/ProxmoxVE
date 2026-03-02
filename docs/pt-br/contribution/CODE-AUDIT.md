# 🧪 Auditoria de Código: Fluxo de Script LXC

Este guia explica o fluxo de execução atual e o que verificar durante as revisões.

## Fluxo de Execução (CT + Instalação)

1. `ct/appname.sh` é executado no host Proxmox e carrega `misc/build.func`.

2. `build.func` orquestra os prompts, a criação do contêiner e invoca o script de instalação.

3. Dentro do contêiner, `misc/install.func` expõe funções auxiliares por meio de `$FUNCTIONS_FILE_PATH`.

4. `install/appname-install.sh` realiza a instalação do aplicativo.

5. O script CT imprime a mensagem de conclusão.

## Lista de Verificação da Auditoria

### Script CT (ct/)

- Carrega `misc/build.func` de `community-scripts/ProxmoxVE/main` (setup-fork.sh atualiza para forks).

- Usa `check_for_gh_release` + `fetch_and_deploy_gh_release` para atualizações.

- Sem instalações baseadas em Docker.

### Script de Instalação (install/)

- Carrega `$FUNCTIONS_FILE_PATH`.

- Usa as funções auxiliares de `tools.func` (setup\_\*).

- Termina com `motd_ssh`, `customize` e `cleanup_lxc`.

### Metadados JSON

- O arquivo em `frontend/public/json/<appname>.json` corresponde ao esquema do modelo.

### Testes

- Teste via curl a partir do seu fork (somente para o script CT).

- Aguarde de 10 a 30 segundos após o push.

## Referências

- `docs/contribution/templates_ct/AppName.sh`
- `docs/contribution/templates_install/AppName-install.sh`
- `docs/contribution/templates_json/AppName.json`
- `docs/contribution/GUIDE.md`
