# Scripts de Contêiner CT - Referência Rápida

> [!WARNING]
> **Esta é uma documentação antiga.** Consulte o **modelo moderno** em [templates_ct/AppName.sh](AppName.sh) para obter as melhores práticas.

> Os modelos atuais usam:
>
> - Funções auxiliares de `tools.func` em vez de padrões manuais
> - `check_for_gh_release` e ​​`fetch_and_deploy_gh_release` de build.func
> - Configuração automática do setup-fork.sh

---

## Antes de criar um script

1. **Crie um fork e clone:**

```bash
   git clone https://github.com/YOUR_USERNAME/ProxmoxVE.git
   cd ProxmoxVE
```

2. **Execute o setup-fork.sh** (atualiza todos os URLs curl para o seu fork):

```bash
   bash docs/contribution/setup-fork.sh
```

3. **Copie o modelo moderno:**

```bash
   cp templates_ct/AppName.sh ct/MyApp.sh
   # Edit ct/MyApp.sh with your app details
```

4. **Teste seu script (via GitHub):**

⚠️ **Importante:** Você deve enviar as alterações para o GitHub e testar via curl, não com `bash ct/MyApp.sh`!

```bash
   # Push your changes to your fork first
   git push origin feature/my-awesome-app

   # Then test via curl (this loads from YOUR fork, not local files)
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/MyApp.sh)"
```

> 💡 **Por quê?** Os comandos curl do script são modificados pelo setup-fork.sh, mas a execução local usa arquivos locais, não os URLs atualizados do GitHub. Testar com curl garante que seu script realmente funcione.

> ⏱️ **Observação:** O GitHub às vezes leva de 10 a 30 segundos para atualizar os arquivos. Se você não vir suas alterações, aguarde e tente novamente.

5. **Cherry-Pick para PR** (envie APENAS seus 3-4 arquivos):

- Consulte o [Guia de Cherry-Pick](../README.md) para obter instruções passo a passo com os comandos git

---

## Estrutura do Template

O template moderno inclui:

### Cabeçalho

```bash
#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# (Note: setup-fork.sh changes this URL to point to YOUR fork during development)
```

### Metadados

```bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: YourUsername
# License: MIT
APP="MyApp"
var_tags="app-category;foss"
var_cpu="2"
var_ram="2048"
var_disk="4"
var_os="alpine"
var_version="3.20"
var_unprivileged="1"
```

### Configuração Principal

```bash
header_info "$APP"
variables
color
catch_errors
```

### Função de Atualização

O template moderno fornece um padrão de atualização padrão:

```bash
function update_script() {
  header_info
  check_container_storage
  check_container_resources

  # Use tools.func helpers:
  check_for_gh_release "myapp" "owner/repo"
  fetch_and_deploy_gh_release "myapp" "owner/repo" "tarball" "latest" "/opt/myapp"
}
```

---

## Padrões Principais

### Verificar Atualizações (Repositório do Aplicativo)

Use `check_for_gh_release` com o **repositório do aplicativo**:

```bash
check_for_gh_release "myapp" "owner/repo"
```

### Implantação Externa Aplicativo

Use `fetch_and_deploy_gh_release` com o **repositório do aplicativo**:

```bash
fetch_and_deploy_gh_release "myapp" "owner/repo"
```

### Evite a verificação manual de versões

❌ ANTIGO (manual):

```bash
RELEASE=$(curl -fsSL https://api.github.com/repos/myapp/myapp/releases/latest | grep tag_name)
```

✅ NOVO (use tools.func):

```bash
fetch_and_deploy_gh_release "myapp" "owner/repo"
```

---

## Boas Práticas

1. **Use as funções auxiliares de tools.func** - Não use curl manualmente para verificar as versões
2. **Adicione apenas dependências específicas do aplicativo** - Não adicione ca-certificates, curl, gnupg (já são gerenciadas por build.func)
3. **Teste com curl a partir do seu fork** - Primeiro, faça o push e depois: `bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/MyApp.sh)"`
4. **Aguarde a atualização do GitHub** - Leva de 10 a 30 segundos após o git push
5. **Selecione apenas SEUS arquivos** - Envie apenas ct/MyApp.sh, install/MyApp-install.sh, frontend/public/json/myapp.json (3 arquivos)
6. **Verifique antes de enviar o PR** - Execute `git diff upstream/main --name-only` para confirmar se apenas seus arquivos foram alterados

---

## Padrões comuns de atualização

Consulte o [modelo moderno](AppName.sh) e o [AI.md](../AI.md) para exemplos completos e funcionais.

Scripts de referência recentes com boas funções de atualização:

- [Trip](https://github.com/community-scripts/ProxmoxVE/blob/main/ct/trip.sh)
- [Thingsboard](https://github.com/community-scripts/ProxmoxVE/blob/main/ct/thingsboard.sh)
- [UniFi](https://github.com/community-scripts/ProxmoxVE/blob/main/ct/unifi.sh)

---

## Precisa de ajuda?

- **[README.md](../README.md)** - Fluxo de trabalho completo para contribuições
- **[AI.md](../AI.md)** - Diretrizes para scripts gerados por IA
- **[FORK_SETUP.md](../FORK_SETUP.md)** - Por que o setup-fork.sh é importante
- **[Comunidade no Slack](https://discord.gg/your-link)** - Tire suas dúvidas

````

### 3.4 **Verbosity**

- Use the appropriate flag (**-q** in the examples) for a command to suppress its output.
  Example:

```bash
curl -fsSL
unzip -q
````

- If a command does not come with this functionality use `$STD` to suppress it's output.

Example:

```bash
$STD php artisan migrate --force
$STD php artisan config:clear
```

### 3.5 **Backups**

- Backup user data if necessary.
- Move all user data back in the directory when the update is finished.

> [!NOTE]
> This is not meant to be a permanent backup

Example backup:

```bash
mv /opt/snipe-it /opt/snipe-it-backup
```

Example config restore:

```bash
cp /opt/snipe-it-backup/.env /opt/snipe-it/.env

cp -r /opt/snipe-it-backup/public/uploads/ /opt/snipe-it/public/uploads/
cp -r /opt/snipe-it-backup/storage/private_uploads /opt/snipe-it/storage/private_uploads
```

### 3.6 **Cleanup**

- Do not forget to remove any temporary files/folders such as zip-files or temporary backups.
  Example:

```bash

rm -rf /opt/v${RELEASE}.zip

rm -rf /opt/snipe-it-backup
```

### 3.7 **No update function**

- In case you can not provide an update function use the following code to provide user feedback.

```bash
function update_script() {
header_info

check_container_storage

check_container_resources
if [[ ! -d /opt/snipeit ]]; então

msg_error "Nenhuma instalação do ${APP} encontrada!"

exit

fi
msg_error "Atualmente, não fornecemos uma função de atualização para este ${APP}."

exit
}
```

---

## 4 **End of the script**

- `start`: Launches Whiptail dialogue
- `build_container`: Collects and integrates user settings
- `description`: Sets LXC container description
- With `echo -e "${TAB}${GATEWAY}${BGN}http://${IP}${CL}"` you can point the user to the IP:PORT/folder needed to access the app.

```bash
start
build_container
description

msg_ok "Concluído com sucesso!\n"
echo -e "A instalação do ${CREATING}${GN}${APP} foi inicializada com sucesso!${CL}"
echo -e "${INFO}${YW} Acesse-a usando a seguinte URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}${CL}"
```

---

## 5. **Lista de verificação de contribuição**

- [ ] O shebang está configurado corretamente (`#!/usr/bin/env bash`).
- [ ] Link correto para _build.func_
- [ ] Os metadados (autor, licença) estão incluídos no início.
- [ ] As variáveis ​​seguem as convenções de nomenclatura.
- [ ] A função de atualização existe.
- [ ] A função de atualização verifica se o aplicativo está instalado e se há uma nova versão.
- [ ] A função de atualização limpa os arquivos temporários.
- [ ] O script termina com uma mensagem útil para o usuário acessar o aplicativo.
