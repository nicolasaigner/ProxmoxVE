# 🍴 Guia de Configuração do Fork

**Acabou de fazer um fork do ProxmoxVE? Execute este comando primeiro!**

## Início Rápido

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/ProxmoxVE.git
cd ProxmoxVE

# Run setup script (auto-detects your username from git)
bash docs/contribution/setup-fork.sh --full
```

É isso! ✅

---

## O que ele faz?

O script `setup-fork.sh` automaticamente:

1. **Detecta** seu nome de usuário do GitHub a partir da configuração do Git
2. **Atualiza TODOS os links fixos** para apontar para o seu fork:

- Links de documentação apontando para `community-scripts/ProxmoxVE`

- **URLs de download do Curl** em scripts (por exemplo, `curl ... github.com/community-scripts/ProxmoxVE/main/...`)

3. **Cria** um arquivo `.git-setup-info` com os detalhes da sua configuração
4. **Faz backup** de todos os arquivos modificados (arquivos \*.backup para segurança)

### Por que atualizar os links do Curl é importante

Seus scripts contêm comandos `curl` que baixam dependências do GitHub (build.func, tools.func, etc.):

```bash
# First line of ct/myapp.sh
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
```

**SEM o setup-fork.sh:**

- As URLs dos scripts ainda apontam para `community-scripts/ProxmoxVE/main`
- Se você testar localmente com `bash ct/myapp.sh`, estará testando arquivos locais, mas os comandos curl do script farão o download do repositório **upstream**.
- Suas modificações não estão sendo testadas pelos comandos curl! ❌

**APÓS setup-fork.sh:**

- Os URLs do script são atualizados para `SeuNomeDeUsuário/ProxmoxVE/main`
- Quando você testa via curl a partir do GitHub: `bash -c "$(curl ... SEU_NOME_DE_USUÁRIO/ProxmoxVE/main/ct/myapp.sh)"`, o download é feito do **seu fork**.
- Os comandos curl do script também apontam para o seu fork, então você está realmente testando suas alterações! ✅
- ⏱️ **Importante:** O GitHub leva de 10 a 30 segundos para reconhecer arquivos enviados - aguarde antes de testar!

```bash
# Example: What setup-fork.sh changes

# BEFORE (points to upstream):
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

# AFTER (points to your fork):
source <(curl -fsSL https://raw.githubusercontent.com/john/ProxmoxVE/main/misc/build.func)
```

---

## Uso

### Detecção automática (recomendado)

```bash
bash docs/contribution/setup-fork.sh --full
```

Lê automaticamente seu nome de usuário do GitHub a partir de `git remote origin url`

### Especificar nome de usuário

```bash
bash docs/contribution/setup-fork.sh --full john
```

Atualiza links para `github.com/john/ProxmoxVE`

### Nome do repositório personalizado

```bash
bash docs/contribution/setup-fork.sh --full john my-fork
```

Atualiza links para `github.com/john/my-fork`

---

## O que é atualizado?

O script atualiza links fixos nessas áreas ao usar `--full`:

- Scripts `ct/`, `install/`, `vm/`
- Bibliotecas de funções `misc/`
- `docs/` (incluindo `docs/contribution/`)
- Exemplos de código na documentação

---

## Após a Configuração

1. **Revise as alterações**

```bash
   git diff docs/
```

2. **Leia dicas sobre fluxo de trabalho Git**

```bash
   cat .git-setup-info
```

3. **Comece a contribuir**

```bash
   git checkout -b feature/my-app
   # Make your changes...
   git commit -m "feat: add my awesome app"
```

4. **Siga o guia**

```bash
   cat docs/contribution/GUIDE.md
```

---

## Fluxos de Trabalho Comuns

### Mantenha seu Fork Atualizado

```bash
# Add upstream if you haven't already
git remote add upstream https://github.com/community-scripts/ProxmoxVE.git

# Get latest from upstream
git fetch upstream
git rebase upstream/main
git push origin main
```

### Crie um Recurso Branch

```bash
git checkout -b feature/docker-improvements
# Make changes...
git push origin feature/docker-improvements
# Then create PR on GitHub
```

### Sincronizar antes de contribuir

```bash
git fetch upstream
git rebase upstream/main
git push -f origin main  # Update your fork's main
git checkout -b feature/my-feature
```

---

## Solução de problemas

### "Git não está instalado" ou "não é um repositório Git"

```bash
# Make sure you cloned the repo first
git clone https://github.com/YOUR_USERNAME/ProxmoxVE.git
cd ProxmoxVE
bash docs/contribution/setup-fork.sh --full
```

### "Não foi possível detectar automaticamente o nome de usuário do GitHub"

```bash
# Your git origin URL isn't set up correctly
git remote -v
# Should show your fork URL, not community-scripts

# Fix it:
git remote set-url origin https://github.com/YOUR_USERNAME/ProxmoxVE.git
bash docs/contribution/setup-fork.sh --full
```

### "Permissão negada"

```bash
# Make script executable
chmod +x docs/contribution/setup-fork.sh
bash docs/contribution/setup-fork.sh --full
```

### Reverteu alterações por engano?

```bash
# Backups are created automatically
git checkout docs/*.backup
# Or just re-run setup-fork.sh
bash docs/contribution/setup-fork.sh --full
```

---

## Próximos Passos

1. ✅ Execute `bash docs/contribution/setup-fork.sh --full`
2. 📖 Leia [docs/contribution/GUIDE.md](GUIDE.md)
3. 🍴 Escolha o caminho da sua contribuição:

- **Containers** → [docs/ct/README.md](docs/ct/README.md)

- **Installation** → [docs/install/README.md](docs/install/README.md)

- **VMs** → [docs/vm/README.md](docs/vm/README.md)

- **Tools** → [docs/tools/README.md](docs/tools/README.md)

4. 💻 Crie sua branch de recurso e contribua!

---

## Dúvidas?

- **Problemas com a configuração do fork?** → Consulte a seção [Solução de problemas](#troubleshooting) acima
- **Como contribuir?** → [docs/contribution/GUIDE.md](GUIDE.md)
- **Fluxos de trabalho do Git?** → `cat .git-setup-info`
- **Estrutura do projeto?** → [docs/README.md](docs/README.md)

---

## Boas contribuições! 🚀
