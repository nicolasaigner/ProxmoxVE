# 🤝 Contribuindo para o ProxmoxVE

Guia completo para contribuir com o projeto ProxmoxVE - desde seu primeiro fork até o envio de seu pull request.

---

## 📋 Sumário

- [Início Rápido](#quick-start)
- [Configurando seu Fork](#setting-up-your-fork)
- [Padrões de Codificação](#coding-standards)
- [Auditoria de Código](#code-audit)
- [Guias e Recursos](#guides--resources)
- [Perguntas Frequentes](#faq)

---

## 🚀 Início Rápido

### 60 Segundos para Contribuir (Desenvolvimento)

Ao desenvolver e testar **em seu fork**:

```bash
# 1. Fork on GitHub
# Visit: https://github.com/community-scripts/ProxmoxVE → Fork (top right)

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/ProxmoxVE.git
cd ProxmoxVE

# 3. Auto-configure your fork (IMPORTANT - updates all links!)
bash docs/contribution/setup-fork.sh --full

# 4. Create a feature branch
git checkout -b feature/my-awesome-app

# 5. Read the guides
cat docs/README.md              # Documentation overview
cat docs/ct/DETAILED_GUIDE.md   # For container scripts
cat docs/install/DETAILED_GUIDE.md  # For install scripts

# 6. Create your contribution
cp docs/contribution/templates_ct/AppName.sh ct/myapp.sh
cp docs/contribution/templates_install/AppName-install.sh install/myapp-install.sh
# ... edit files ...

# 7. Push to your fork and test via GitHub
git push origin feature/my-awesome-app
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/myapp.sh)"
# ⏱️ GitHub may take 10-30 seconds to update files - be patient!

# 8. Create your JSON metadata file
cp docs/contribution/templates_json/AppName.json frontend/public/json/myapp.json
# Edit metadata: name, slug, categories, description, resources, etc.

# 9. No direct install-script test
# Install scripts are executed by the CT script inside the container

# 10. Commit ONLY your new files (see Cherry-Pick section below!)
git add ct/myapp.sh install/myapp-install.sh frontend/public/json/myapp.json
git commit -m "feat: add MyApp container and install scripts"
git push origin feature/my-awesome-app

# 11. Create Pull Request on GitHub
```

⚠️ **IMPORTANTE: Após o setup-fork.sh, muitos arquivos são modificados!**

Consulte a seção **Cherry-Pick: Enviando Apenas Suas Alterações** abaixo para aprender como enviar APENAS seus 3 a 4 arquivos em vez de mais de 600 arquivos modificados! ### Como os usuários executam scripts (após a mesclagem)

Assim que seu script for mesclado ao repositório principal, os usuários o baixarão e executarão a partir do GitHub da seguinte forma:

```bash
# ✅ Users run from GitHub (normal usage after PR merged)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/myapp.sh)"

# Install scripts are called by the CT script and are not run directly by users
```

### Execução em Desenvolvimento vs. Produção

**Durante o Desenvolvimento (você, em seu fork):**

```bash
# You MUST test via curl from your GitHub fork (not local files!)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/myapp.sh)"

# The script's curl commands are updated by setup-fork.sh to point to YOUR fork
# This ensures you're testing your actual changes
# ⏱️ Wait 10-30 seconds after pushing - GitHub updates slowly
```

**Após a mesclagem (usuários, a partir do GitHub):**

```bash
# Users download the script from upstream via curl
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/myapp.sh)"

# The script's curl commands now point back to upstream (community-scripts)
# This is the stable, tested version
```

**Resumo:**

- **Desenvolvimento**: Enviar para o fork, testar via curl → setup-fork.sh altera os URLs do curl para o seu fork
- **Produção**: curl | bash do repositório original → URLs curl apontam para o repositório community-scripts

---

## 🍴 Configurando seu Fork

### Configuração Automática (Recomendado)

Ao clonar seu fork, execute o script de configuração para configurar tudo automaticamente:

```bash
bash docs/contribution/setup-fork.sh --full
```

**O que ele faz:**

- Detecta automaticamente seu nome de usuário do GitHub a partir da configuração do git
- Detecta automaticamente o nome do seu repositório fork
- Atualiza **TODOS** os links fixos para apontarem para o seu fork em vez do repositório principal (`--full`)
- Cria um arquivo `.git-setup-info` com sua configuração
- Permite que você desenvolva e teste independentemente em seu fork

**Por que isso é importante:**

Sem executar este script, todos os links em seu fork ainda apontarão para o repositório original (community-scripts). Isso é um problema durante os testes porque:

- Os links de instalação serão obtidos do repositório original, não do seu fork.
- As atualizações serão direcionadas ao repositório errado.
- Suas contribuições não serão testadas corretamente.

**Após executar o setup-fork.sh:**

Seu fork está totalmente configurado e pronto para desenvolvimento. Você pode:

- Enviar alterações para o seu fork
- Testar via curl: `bash -c "$(curl -fsSL https://raw.githubusercontent.com/SEU_USUÁRIO/ProxmoxVE/main/ct/myapp.sh)"`
- Todos os links farão referência ao seu fork para desenvolvimento
- ⏱️ Aguarde de 10 a 30 segundos após o envio - o GitHub leva um tempo para atualizar
- Confirme e envie com confiança
- Crie um PR para mesclar no repositório principal

**Consulte**: [FORK_SETUP.md](FORK_SETUP.md) para obter instruções detalhadas

### Configuração Manual

Se o script não funcionar, configure manualmente:

```bash
# Set git user
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Add upstream remote for syncing with main repo
git remote add upstream https://github.com/community-scripts/ProxmoxVE.git

# Verify remotes
git remote -v
# Should show: origin (your fork) and upstream (main repo)
```

---

## 📖 Padrões de Codificação

Todos os scripts e configurações devem seguir nossos padrões de codificação para garantir consistência e qualidade.

### Guias Disponíveis

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Padrões de codificação essenciais e melhores práticas
- **[CODE-AUDIT.md](CODE-AUDIT.md)** - Lista de verificação de revisão de código e procedimentos de auditoria
- **[GUIDE.md](GUIDE.md)** - Guia completo de contribuição
- **[HELPER_FUNCTIONS.md](HELPER_FUNCTIONS.md)** - Referência para todas as funções auxiliares tools.func
- **Scripts de Contêiner** - Modelos e diretrizes para `/ct/`
- **Scripts de Instalação** - Modelos e diretrizes para `/install/`
- **Configurações JSON** - Estrutura e formato de `frontend/public/json/`

### Lista de Verificação Rápida

- ✅ Use `/ct/example.sh` como modelo para scripts de contêiner
- ✅ Use `/install/example-install.sh` como modelo para Scripts de instalação
- ✅ Siga as convenções de nomenclatura: `appname.sh` e `appname-install.sh`
- ✅ Inclua o shebang correto: `#!/usr/bin/env bash`
- ✅ Adicione o cabeçalho de direitos autorais com o autor
- ✅ Trate os erros corretamente com `msg_error`, `msg_ok`, etc.
- ✅ Teste antes de enviar o PR (via curl do seu fork, não no bash local)
- ✅ Atualize a documentação, se necessário

---

## 🔍 Auditoria de Código

Antes de enviar um pull request, certifique-se de que seu código passe em nossa auditoria:

**Consulte**: [CODE_AUDIT.md](CODE_AUDIT.md) para obter a lista de verificação completa da auditoria

Pontos-chave:

- Consistência do código com os scripts existentes
- Tratamento de erros adequado
- Nomenclatura correta das variáveis
- Comentários e documentação adequados
- Boas práticas de segurança

---

## 🍒 Cherry-Pick: Submetendo Apenas Suas Alterações

**Problema**: O script `setup-fork.sh` modifica mais de 600 arquivos para atualizar links. Você não quer submeter todas essas alterações — apenas seus 3 ou 4 novos arquivos!

**Solução**: Use o comando `git cherry-pick` para selecionar APENAS os SEUS arquivos.

### Guia Passo a Passo do Cherry-Pick

#### 1. Verifique o que mudou

```bash
# See all modified files
git status

# Verify your files are there
git status | grep -E "ct/myapp|install/myapp|json/myapp"
```

#### 2. Crie uma branch limpa para submissão

```bash
# Go back to upstream main (clean slate)
git fetch upstream
git checkout -b submit/myapp upstream/main

# Don't use your modified main branch!
```

#### 3. Selecione SOMENTE seus arquivos

A seleção extrai alterações específicas de commits:

```bash
# Option A: Cherry-pick commits that added your files
# (if you committed your files separately)
git cherry-pick <commit-hash-of-your-files>

# Option B: Manually copy and commit only your files
# From your work branch, get the file contents
git show feature/my-awesome-app:ct/myapp.sh > /tmp/myapp.sh
git show feature/my-awesome-app:install/myapp-install.sh > /tmp/myapp-install.sh
git show feature/my-awesome-app:frontend/public/json/myapp.json > /tmp/myapp.json

# Add them to the clean branch
cp /tmp/myapp.sh ct/myapp.sh
cp /tmp/myapp-install.sh install/myapp-install.sh
cp /tmp/myapp.json frontend/public/json/myapp.json

# Commit
git add ct/myapp.sh install/myapp-install.sh frontend/public/json/myapp.json
git commit -m "feat: add MyApp"
```

#### 4. Verifique se apenas seus arquivos estão no PR

```bash
# Check git diff against upstream
git diff upstream/main --name-only
# Should show ONLY:
#   ct/myapp.sh
#   install/myapp-install.sh
#   frontend/public/json/myapp.json
```

#### 5. Envie e crie o PR

```bash
# Push your clean submission branch
git push origin submit/myapp

# Create PR on GitHub from: submit/myapp → main
```

### Por que isso é importante

- ✅ PR limpo com apenas suas alterações
- ✅ Mais fácil para os mantenedores revisarem
- ✅ Mesclagem mais rápida sem conflitos
- ❌ Sem a seleção: o PR tem mais de 600 alterações de arquivos (não será mesclado!)

### Se você fez um Erro

```bash
# Delete the messy branch
git branch -D submit/myapp

# Go back to clean branch
git checkout -b submit/myapp upstream/main

# Try cherry-picking again
```

---

Se você estiver usando o **Visual Studio Code** com um assistente de IA, poderá aproveitar nossas diretrizes detalhadas para gerar contribuições de alta qualidade automaticamente.

### Como usar a assistência de IA

1. **Abra as Diretrizes de IA**

```
   docs/contribution/AI.md
```

Este arquivo contém todos os requisitos, padrões e exemplos para escrever scripts adequados.

2. **Prepare suas informações**

Antes de pedir à IA para gerar código, reúna:

- **URL do repositório**: por exemplo, `https://github.com/owner/myapp`

- **Dockerfile/Script**: Cole as instruções de instalação do aplicativo (se disponíveis)

- **Dependências**: Quais pacotes são necessários? (Node, Python, Java, PostgreSQL etc.)

- **Portas**: Em qual porta o aplicativo deve escutar? (ex.: 3000, 8080, 5000)

- **Configuração**: Existem variáveis ​​de ambiente ou arquivos de configuração?

3. **Informe o Assistente de IA**

Compartilhe com a IA:

- A URL do repositório

- O Dockerfile ou as instruções de instalação

- Link para [docs/contribution/AI.md](AI.md) com instruções a seguir

**Exemplo de prompt:**

```
   I want to contribute a container script for MyApp to ProxmoxVE.
   Repository: https://github.com/owner/myapp

   Here's the Dockerfile:
   [paste Dockerfile content]

   Please follow the guidelines in docs/contribution/AI.md to create:
   1. ct/myapp.sh (container script)
   2. install/myapp-install.sh (installation script)
   3. frontend/public/json/myapp.json (metadata)
```

4. **A IA irá gerar**

A IA irá gerar scripts que:

- Seguem todos os padrões e convenções do ProxmoxVE

- Usam as funções auxiliares de `tools.func` corretamente

- Incluem tratamento de erros e mensagens adequadas

- Possuem mecanismos de atualização corretos

- Estão prontos para serem submetidos como um PR (Pull Request)

### Pontos-chave para os Assistentes de IA

- **Localização dos Templates**: `docs/contribution/templates_ct/AppName.sh`, `templates_install/`, `templates_json/`
- **Diretrizes**: Deve seguir `docs/contribution/AI.md` exatamente
- **Funções Auxiliares** **Funções**: Use apenas funções de `misc/tools.func` - nunca escreva funções personalizadas
- **Testes**: Sempre teste antes de enviar via curl a partir do seu fork

```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/myapp.sh)"
  # Wait 10-30 seconds after pushing changes
```

- **Sem Docker**: Os scripts de contêiner devem ser executados diretamente no hardware (bare-metal), não baseados em Docker

### Benefícios

- **Velocidade**: A IA gera código boilerplate em segundos
- **Consistência**: Segue os mesmos padrões de mais de 200 scripts existentes
- **Qualidade**: Menos bugs e código mais fácil de manter
- **Aprendizado**: Veja como seu aplicativo deve ser estruturado

---

### Documentação

- **[docs/README.md](../README.md)** - Central de documentação principal
- **[docs/ct/README.md](../ct/README.md)** - Visão geral dos scripts de contêiner
- **[docs/install/README.md](../install/README.md)** - Visão geral dos scripts de instalação
- **[docs/ct/DETAILED_GUIDE.md](../ct/DETAILED_GUIDE.md)** - Referência completa dos scripts ct/
- **[docs/install/DETAILED_GUIDE.md](../install/DETAILED_GUIDE.md)** - Referência completa dos scripts install/
- **[docs/TECHNICAL_REFERENCE.md](../TECHNICAL_REFERENCE.md)** - Análise detalhada da arquitetura
- **[docs/EXIT_CODES.md](../EXIT_CODES.md)** - Referência dos códigos de saída
- **[docs/DEV_MODE.md](../DEV_MODE.md)** - Guia de depuração

### Guias da Comunidade

Consulte [USER_SUBMITTED_GUIDES.md](USER_SUBMITTED_GUIDES.md) contém excelentes guias escritos pela comunidade:

- Instalação e configuração do Home Assistant
- Configuração do Frigate no Proxmox
- Instalação do Docker e do Portainer
- Configuração e otimização de banco de dados
- E muito mais!

### Modelos

Use estes modelos ao criar novos scripts:

```bash
# Container script template
cp docs/contribution/templates_ct/AppName.sh ct/my-app.sh

# Installation script template
cp docs/contribution/templates_install/AppName-install.sh install/my-app-install.sh

# JSON configuration template
cp docs/contribution/templates_json/AppName.json frontend/public/json/my-app.json
```

**Recursos do Modelo:**

- Atualizado para corresponder aos padrões atuais do código-fonte
- Inclui todas as funções auxiliares disponíveis em `tools.func`

- Exemplos para aplicações Node.js, Python, PHP e Go
- Exemplos de configuração de banco de dados (MariaDB, PostgreSQL)
- Criação e limpeza adequadas de serviços

---

## 🔄 Fluxo de Trabalho Git

### Mantenha seu Fork Atualizado

```bash
# Fetch latest from upstream
git fetch upstream

# Rebase your work on latest main
git rebase upstream/main

# Push to your fork
git push -f origin main
```

### Crie uma Branch de Funcionalidade

```bash
# Create and switch to new branch
git checkout -b feature/my-feature

# Make changes...
git add .
git commit -m "feat: description of changes"

# Push to your fork
git push origin feature/my-feature

# Create Pull Request on GitHub
```

### Antes de Enviar um PR

1. **Sincronize com o repositório original**

```bash
   git fetch upstream
   git rebase upstream/main
```

2. **Teste suas alterações** (via curl a partir do seu fork)

```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/my-app.sh)"
   # Follow prompts and test the container
   # ⏱️ Wait 10-30 seconds after pushing - GitHub takes time to update
```

3. **Verificar padrões de código**

- [ ] Segue a estrutura do modelo

- [ ] Tratamento de erros adequado

- [ ] Documentação atualizada (se necessário)

- [ ] Sem valores fixos no código

- [ ] Controle de versão implementado

4. **Enviar alterações finais**

```bash
   git push origin feature/my-feature
```

---

## 📋 Lista de verificação para Pull Request

Antes de abrir um PR:

- [ ] O código segue os padrões de codificação (consulte CONTRIBUTING.md)
- [ ] Todos os modelos foram usados ​​corretamente
- [ ] Testado no Proxmox VE
- [ ] Tratamento de erros implementado
- [ ] Documentação atualizada (se aplicável)
- [ ] Sem conflitos de mesclagem
- [ ] Sincronizado com o upstream/main
- [ ] Título e descrição do PR claros

---

## ❓ FAQ

### ❌ Por que não consigo testar com `bash ct/myapp.sh` localmente?

Você pode tentar:

```bash
# ❌ WRONG - This won't test your actual changes!
bash ct/myapp.sh
./ct/myapp.sh
sh ct/myapp.sh
```

**Por que isso falha:**

- `bash ct/myapp.sh` usa o arquivo clonado LOCAL
- O arquivo LOCAL não executa os comandos curl - ele já está no disco
- Os URLs curl DENTRO do script são modificados por setup-fork.sh, mas não são executados
- Portanto, você não pode verificar se seus URLs curl realmente funcionam
- Os usuários receberão a versão do URL curl (que pode estar quebrada)

**Solução:** Sempre teste via curl a partir do GitHub:

```bash
# ✅ CORRECT - Tests the actual GitHub URLs
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/myapp.sh)"
```

### ❓ Como testo minhas alterações?

Você **não pode** testar localmente com `bash ct/myapp.sh` a partir do seu diretório clonado!

Você **precisa** enviar as alterações para o GitHub e testar via curl a partir do seu fork:

```bash
# 1. Push your changes to your fork
git push origin feature/my-awesome-app

# 2. Test via curl (this loads the script from GitHub, not local files)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/my-app.sh)"

# 3. For verbose/debug output, pass environment variables
VERBOSE=yes bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/my-app.sh)"
DEV_MODE_LOGS=true bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ProxmoxVE/main/ct/my-app.sh)"
```

**Por quê?**

- O script `bash ct/myapp.sh` local usa arquivos locais do seu clone.
- Mas os comandos curl INTERNOS do script foram modificados pelo `setup-fork.sh` para apontar para o seu fork.
- Essa discrepância significa que você não está testando as URLs do curl corretamente.
- Testar via curl garante que o script baixe as URLs do GitHub do SEU fork.
- ⏱️ **Importante:** O GitHub leva de 10 a 30 segundos para reconhecer arquivos recém-enviados. Aguarde antes de testar!

**E se o bash local funcionasse?**

Você testaria apenas os arquivos locais, não as URLs reais do GitHub que os usuários baixarão. Isso significa que links curl quebrados não seriam detectados durante os testes.

### E se meu PR tiver conflitos?

```bash
# Sync with upstream main repository
git fetch upstream
git rebase upstream/main

# Resolve conflicts in your editor
git add .
git rebase --continue
git push -f origin your-branch
```

### Como mantenho meu fork atualizado?

Duas maneiras:

**Opção 1: Execute o script de configuração novamente**

```bash
bash docs/contribution/setup-fork.sh --full
```

**Opção 2: Sincronização manual**

```bash
git fetch upstream
git rebase upstream/main
git push -f origin main
```

### Onde posso tirar dúvidas?

- **Problemas no GitHub**: Para bugs e solicitações de recursos
- **Discussões no GitHub**: Para perguntas e ideias gerais
- **Discord**: Servidor da comunidade de scripts para bate-papo em tempo real

---

## 🎓 Recursos de Aprendizagem

### Para Colaboradores Iniciantes

1. Leia: [docs/README.md](../README.md) - Visão geral da documentação
2. Leia: [CONTRIBUTING.md](CONTRIBUTING.md) - Padrões de codificação essenciais
3. Escolha seu caminho:

- Contêineres → [docs/ct/DETAILED_GUIDE.md](../ct/DETAILED_GUIDE.md)

- Instalação → [docs/install/DETAILED_GUIDE.md](../install/DETAILED_GUIDE.md)

4. Estude scripts existentes na mesma categoria
5. Crie o seu Contribuição

### Para Desenvolvedores Experientes

1. Revise [CONTRIBUTING.md](CONTRIBUTING.md) - Padrões de codificação
2. Revise [CODE_AUDIT.md](CODE_AUDIT.md) - Lista de verificação de auditoria
3. Verifique os modelos em `/docs/contribution/templates_*/`
4. Use assistentes de IA com [AI.md](AI.md) para geração de código
5. Envie seu PR com confiança

### Para usar assistentes de IA

Consulte a seção "Usando assistentes de IA" acima para:

- Como estruturar os prompts
- Quais informações fornecer
- Como validar a saída da IA

---

## 🚀 Pronto para contribuir?

1. **Faça um fork** do repositório
2. **Clone** seu fork e **configure** com `bash docs/contribution/setup-fork.sh --full`
3. **Escolha** o tipo de contribuição (container, instalação, ferramentas, etc.)
4. **Leia** o guia detalhado apropriado
5. **Crie** sua branch de recurso
6. **Desenvolva** e **teste** suas alterações
7. **Faça commits** com mensagens claras
8. **Envie** as alterações para o seu fork
9. **Crie** um Pull Request

---

## 📞 Contato e Suporte

- **GitHub**: [community-scripts/ProxmoxVE](https://github.com/community-scripts/ProxmoxVE)
- **Issues**: [GitHub Issues](https://github.com/community-scripts/ProxmoxVE/issues)
- **Discussões**: [Discussões no GitHub](https://github.com/community-scripts/ProxmoxVE/discussions)
- **Discord**: [Entrar no servidor](https://discord.gg/UHrpNWGwkH)

---

**Obrigado por contribuir com o ProxmoxVE!** 🙏

Seus esforços ajudam a tornar a automação do Proxmox VE acessível a todos. Boa programação! 🚀
