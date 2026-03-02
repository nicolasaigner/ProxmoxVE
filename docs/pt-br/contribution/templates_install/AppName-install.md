# Scripts de Instalação - Referência Rápida

> [!WARNING]
> **Esta é uma documentação antiga.** Consulte o **modelo moderno** em [templates_install/AppName-install.sh](AppName-install.sh) para obter as melhores práticas.

> Os modelos atuais utilizam:
>
> - Funções auxiliares `tools.func` (setup_nodejs, setup_uv, setup_postgresql_db, etc.)
> - Instalação automática de dependências via build.func
> - Padrões padronizados de variáveis ​​de ambiente

---

## Antes de Criar um Script

1. **Copie o Modelo Moderno:**

```bash
   cp templates_install/AppName-install.sh install/MyApp-install.sh
   # Edit install/MyApp-install.sh
```

2. **Padrão Principal:**

- Os scripts CT carregam build.func e chamam o script de instalação

- Os scripts de instalação utilizam o FUNCTIONS_FILE_PATH carregado (via build.func)

- Ambos os scripts funcionam juntos no contêiner

3. **Teste via GitHub:**

```bash
   # Push your changes to your fork first
   git push origin feature/my-awesome-app

   # Test the CT script via curl (it will call the install script)
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/MyApp.sh)"
   # ⏱️ Wait 10-30 seconds after pushing - GitHub takes time to update
```

---

## Estrutura do Modelo

### Cabeçalho

```bash
#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/install.func)
# (setup-fork.sh modifies this URL to point to YOUR fork during development)
```

### Dependências (Específicas do Aplicativo) Somente)

```bash
# Don't add: ca-certificates, curl, gnupg, wget, git, jq
# These are handled by build.func
msg_info "Installing dependencies"
$STD apt-get install -y app-specific-deps
msg_ok "Installed dependencies"
```

### Configuração do ambiente de execução

Use as funções auxiliares tools.func em vez da instalação manual:

```bash
# ✅ NEW (use tools.func):
NODE_VERSION="20"
setup_nodejs
# OR
PYTHON_VERSION="3.12"
setup_uv
# OR
PG_DB_NAME="myapp_db"
PG_DB_USER="myapp"
setup_postgresql_db
```

### Configuração do serviço

```bash
# Create .env file
msg_info "Configuring MyApp"
cat << EOF > /opt/myapp/.env
DEBUG=false
PORT=8080
DATABASE_URL=postgresql://...
EOF
msg_ok "Configuration complete"

# Create systemd service
msg_info "Creating systemd service"
cat << EOF > /etc/systemd/system/myapp.service
[Unit]
Description=MyApp
[Service]
ExecStart=/usr/bin/node /opt/myapp/app.js
[Install]
WantedBy=multi-user.target
EOF
msg_ok "Service created"
```

### Finalização

```bash
msg_info "Finalizing MyApp installation"
systemctl enable --now myapp
motd_ssh
customize
msg_ok "MyApp installation complete"
cleanup_lxc
```

---

## Padrões de chave

### Evitar verificação manual de versão

❌ ANTIGO (manual):

```bash
RELEASE=$(curl -fsSL https://api.github.com/repos/app/repo/releases/latest | grep tag_name)
wget https://github.com/app/repo/releases/download/$RELEASE/app.tar.gz
```

✅ NOVO (use tools.func através do script fetch_and_deploy_gh_release do CT):

```bash
# In CT script, not install script:
fetch_and_deploy_gh_release "myapp" "app/repo" "app.tar.gz" "latest" "/opt/myapp"
```

### Configuração do banco de dados

```bash
# Use setup_postgresql_db, setup_mysql_db, etc.
PG_DB_NAME="myapp"
PG_DB_USER="myapp"
setup_postgresql_db
```

### Node.js Configuração

```bash
NODE_VERSION="20"
setup_nodejs
npm install --no-save
```

---

## Boas Práticas

1. **Adicione apenas dependências específicas do aplicativo**

- Não adicione: ca-certificates, curl, gnupg, wget, git, jq

- Essas dependências são gerenciadas por build.func

2. **Use as funções auxiliares de tools.func**

- setup_nodejs, setup_python, setup_uv, setup_postgresql_db, setup_mysql_db, etc.

3. **Não faça verificações de versão no script de instalação**

- A verificação de versão ocorre no script update_script() do CT

- O script de instalação instala apenas a versão mais recente

4. **Estrutura:**

- Dependências

- Configuração em tempo de execução (tools.func)

- Implantação (busca do script CT)

- Arquivos de configuração

- Serviço systemd

- Finalização

---

## Scripts de Referência

Veja exemplos em funcionamento:

- [Trip](https://github.com/community-scripts/ProxmoxVE/blob/main/install/trip-install.sh)
- [Thingsboard](https://github.com/community-scripts/ProxmoxVE/blob/main/install/thingsboard-install.sh)
- [UniFi](https://github.com/community-scripts/ProxmoxVE/blob/main/install/unifi-install.sh)

---

## Precisa de ajuda?

- **[Modelo Moderno](AppName-install.sh)** - Comece aqui
- **[Modelo CT](../templates_ct/AppName.sh)** - Como os scripts CT funcionam
- **[README.md](../README.md)** - Fluxo de trabalho completo de contribuição
- **[AI.md](../AI.md)** - Diretrizes para scripts gerados por IA

### 1.2 **Comentários**

- Adicione comentários claros para os metadados do script, incluindo informações sobre autor, direitos autorais e licença.

- Use comentários em linha significativos para explicar comandos ou lógica complexos.

Exemplo:

```bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: [YourUserName]
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: [SOURCE_URL]
```

> [!NOTE]:
>
> - Adicione seu nome de usuário
> - Ao atualizar/remodelar scripts, adicione "| Coautor [SeuNomeDeUsuário]"

### 1.3 **Importação de variáveis ​​e funções**

- Esta seção adiciona suporte para todas as funções e variáveis ​​necessárias.

```bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os
```

---

## 2. **Nomeação e gerenciamento de variáveis**

### 2.1 **Convenções de nomenclatura**

- Use letras maiúsculas para constantes e variáveis ​​de ambiente.

- Use letras minúsculas para variáveis ​​locais do script.

Exemplo:

```bash
DB_NAME=snipeit_db    # Environment-like variable (constant)
db_user="snipeit"     # Local variable
```

---

## 3. **Dependências**

### 3.1 **Instalar tudo de uma vez**

- Instale todas as dependências com um único comando, se possível.

Exemplo:

```bash
$STD apt-get install -y \
  curl \
  composer \
  git \
  sudo \
  mc \
  nginx
```

### 3.2 **Agrupar dependências**

Agrupe as dependências para manter o código legível.

Exemplo:

Use

```bash
php8.2-{bcmath,common,ctype}
```

em vez de

```bash
php8.2-bcmath php8.2-common php8.2-ctype
```

---

## 4. **Caminhos para os arquivos do aplicativo**

Se possível, instale o aplicativo e todos os arquivos necessários em `/opt/`

---

## 5. **Gerenciamento de versões**

### 5.1 **Instale a versão mais recente**

- Sempre tente instalar a versão mais recente.
- Não especifique nenhuma versão diretamente no código, a menos que seja absolutamente necessário.

Exemplo para uma versão do Git:

```bash
RELEASE=$(curl -fsSL https://api.github.com/repos/snipe/snipe-it/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
curl -fsSL "https://github.com/snipe/snipe-it/archive/refs/tags/v${RELEASE}.zip"
```

### 5.2 **Salve a versão para verificações de atualização**

- Grave a versão instalada em um arquivo.

- Isso é usado pela função de atualização em **AppName.sh** para verificar se uma atualização é necessária.

Exemplo:

```bash
echo "${RELEASE}" >"/opt/AppName_version.txt"
```

---

## 6. **Gerenciamento de entrada e saída**

### 6.1 **Feedback do usuário**

- Use funções padrão como `msg_info`, `msg_ok` ou `msg_error` para imprimir mensagens de status.

- Cada `msg_info` deve ser seguido por um `msg_ok` antes de qualquer outra saída ser gerada.

- Exiba mensagens de progresso significativas em etapas importantes.

Exemplo:

```bash
msg_info "Installing Dependencies"
$STD apt-get install -y ...
msg_ok "Installed Dependencies"
```

### 6.2 **Verbosidade**

- Use a flag apropriada (**-q** nos exemplos) para um comando para suprimir sua saída.

Exemplo:

```bash
curl -fsSL
unzip -q
```

- Se um comando não possuir essa funcionalidade, use `$STD` (uma variável de redirecionamento padrão personalizada) para gerenciar o nível de detalhamento da saída.

Exemplo:

```bash
$STD apt-get install -y nginx
```

---

## 7. **Manipulação de Strings/Arquivos**

### 7.1 **Manipulação de Arquivos**

- Use `sed` para substituir valores de espaço reservado em arquivos de configuração.

Exemplo:

```bash
sed -i -e "s|^DB_DATABASE=.*|DB_DATABASE=$DB_NAME|" \
       -e "s|^DB_USERNAME=.*|DB_USERNAME=$DB_USER|" \
       -e "s|^DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|" .env
```

---

## 8. **Práticas de Segurança**

### 8.1 **Geração de Senhas**

- Use `openssl` para gerar senhas aleatórias.

- Use apenas valores alfanuméricos para evitar comportamentos inesperados.

Exemplo:

```bash
DB_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)
```

### 8.2 **Permissões de Arquivo**

Defina explicitamente a propriedade e as permissões seguras para arquivos sensíveis.

Exemplo:

```bash
chown -R www-data: /opt/snipe-it
chmod -R 755 /opt/snipe-it
```

---

## 9. **Configuração do Serviço**

### 9.1 **Arquivos de Configuração**

Use `cat <<EOF` para gravar arquivos de configuração de forma limpa e legível.

Exemplo:

```bash
cat <<EOF >/etc/nginx/conf.d/snipeit.conf
server {
    listen 80;
    root /opt/snipe-it/public;
    index index.php;
}
EOF
```

### 9.2 **Gerenciamento de Credenciais**

Armazene as credenciais geradas em um arquivo.

Exemplo:

```bash
USERNAME=username
PASSWORD=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)
{
    echo "Application-Credentials"
    echo "Username: $USERNAME"
    echo "Password: $PASSWORD"
} >> ~/application.creds
```

### 9.3 **Arquivos de Ambiente**

Use `cat <<EOF` para gravar arquivos de ambiente de forma limpa e legível.

Exemplo:

```bash
cat <<EOF >/path/to/.env
VARIABLE="value"
PORT=3000
DB_NAME="${DB_NAME}"
EOF
```

### 9.4 **Serviços**

Habilite os serviços afetados após as alterações de configuração e inicie-os imediatamente.

Exemplo:

```bash
systemctl enable -q --now nginx
```

---

## 10. **Limpeza**

### 10.1 **Remover arquivos temporários**

Remova arquivos temporários e downloads após o uso.

Exemplo:

```bash
rm -rf /opt/v${RELEASE}.zip
```

### 10.2 **Remoção automática e limpeza automática**

Remova dependências não utilizadas para reduzir o uso de espaço em disco.

Exemplo:

```bash
apt-get -y autoremove
apt-get -y autoclean
```

---

## 11. **Lista de verificação de boas práticas**

- [ ] O shebang está configurado corretamente (`#!/usr/bin/env bash`).

- [ ] Os metadados (autor, licença) estão incluídos no início.
- [ ] As variáveis ​​seguem convenções de nomenclatura.
- [ ] Valores sensíveis são gerados dinamicamente.

- [ ] Arquivos e serviços têm as permissões adequadas.

- [ ] O script limpa arquivos temporários.

---

### Exemplo: Fluxo de Script de Alto Nível

1. Instalação de dependências
2. Configuração do banco de dados
3. Download e configuração do aplicativo
4. Configuração do serviço
5. Limpeza final
