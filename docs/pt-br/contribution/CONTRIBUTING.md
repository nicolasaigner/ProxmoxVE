# Guia de Contribuição para Scripts da Comunidade

## **Bem-vindo ao Repositório de scripts da comunidade!**

📜 Estes documentos descrevem os padrões de codificação essenciais para todos os nossos scripts e arquivos JSON. A adesão a esses padrões garante que nossa base de código permaneça consistente,
legível e de fácil manutenção. Seguindo estas diretrizes, podemos melhorar a colaboração, reduzir erros e aprimorar a qualidade geral do nosso projeto.

### Por que os Padrões de Codificação São Importantes

Os padrões de codificação são cruciais por vários motivos:

1. **Consistência**: Código consistente é mais fácil de ler, entender e manter. Ajuda novos membros da equipe a se adaptarem rapidamente e reduz a curva de aprendizado.

2. **Legibilidade**: Código claro e bem estruturado é mais fácil de depurar e estender. Permite que os desenvolvedores identifiquem e corrijam problemas rapidamente.

3. **Manutenibilidade**: Código que segue uma estrutura padrão é mais fácil de refatorar e atualizar. Garante que as alterações possam ser feitas com o mínimo risco de introduzir novos bugs.
4. **Colaboração**: Quando todos seguem os mesmos padrões, a colaboração no código torna-se mais fácil. Isso reduz atritos e mal-entendidos durante revisões e fusões de código.

### Escopo destes documentos

Estes documentos abrangem os padrões de codificação para os seguintes tipos de arquivos em nosso projeto:

- **Scripts `install/$AppName-install.sh`**: Esses scripts são responsáveis ​​pela instalação de aplicativos.

- **Scripts `ct/$AppName.sh`**: Esses scripts gerenciam a criação e atualização de contêineres.

- **json/$AppName.json`**: Esses arquivos armazenam dados estruturados e são usados ​​para o site.

Cada seção fornece diretrizes detalhadas sobre vários aspectos da codificação, incluindo o uso de shebang, comentários, nomenclatura de variáveis, nomenclatura de funções, indentação, tratamento de
erros, substituição de comandos, citação, estrutura de scripts e registro de logs. Além disso, exemplos são fornecidos para ilustrar a aplicação desses padrões.

Seguindo os padrões de codificação descritos neste documento, garantimos que nossos scripts e arquivos JSON sejam de alta qualidade, tornando nosso projeto mais robusto e fácil de gerenciar. Consulte
este guia sempre que criar ou atualizar scripts e arquivos JSON para manter um alto padrão de qualidade de código em todo o projeto. 📚🔍

Vamos trabalhar juntos para manter nossa base de código limpa, eficiente e de fácil manutenção! 💪🚀

## Primeiros Passos

Antes de contribuir, certifique-se de ter a seguinte configuração:

1. **Visual Studio Code** (recomendado para desenvolvimento de scripts)
2. **Extensões recomendadas para o VS Code:**

- [Shell Syntax](https://marketplace.visualstudio.com/items?itemName=bmalehorn.shell-syntax)

- [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)

- [Shell Format](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format)

### Observações Importantes

- Use [AppName.sh](https://github.com/community-scripts/ProxmoxVE/blob/main/docs/contribution/templates_ct/AppName.sh) e
  [AppName-install.sh](https://github.com/community-scripts/ProxmoxVE/blob/main/docs/contribution/templates_install/AppName-install.sh) como modelo ao criar novos scripts.

---

# 🚀 O Script de Aplicação (ct/AppName.sh)

- Você pode encontrar todos os padrões de codificação, bem como a estrutura deste arquivo [aqui](https://github.com/community-scripts/ProxmoxVE/blob/main/docs/contribution/templates_ct/AppName.md).

- Esses scripts são responsáveis ​​pela criação do contêiner, configuração das variáveis ​​necessárias e gerenciamento da atualização da aplicação após a instalação.

---

# 🛠 O Script de Instalação (install/AppName-install.sh)

- Você pode encontrar todos os padrões de codificação, bem como a estrutura deste arquivo
  [aqui](https://github.com/community-scripts/ProxmoxVE/blob/main/docs/contribution/templates_install/AppName-install.md).

- Esses scripts são responsáveis ​​pela instalação do aplicativo.

---

## 🚀 Criando seus próprios scripts

Comece com o [script modelo](https://github.com/community-scripts/ProxmoxVE/blob/main/docs/contribution/templates_install/AppName-install.sh)

---

## 🤝 Processo de Contribuição

### 1. Faça um fork do repositório

Faça um fork para sua conta do GitHub

### 2. Clone seu fork em seu ambiente local

```bash
git clone https://github.com/yourUserName/ForkName
```

### 3. Crie uma nova branch

```bash
git switch -c your-feature-branch
```

### 4. Execute o setup-fork.sh para configurar automaticamente seu fork

```bash
bash docs/contribution/setup-fork.sh --full
```

Este script automaticamente:

- Detecta seu nome de usuário do GitHub
- Atualiza TODAS as URLs do curl para apontar para seu fork (para testes)
- Cria `.git-setup-info` com sua configuração
- Faz backup de todos os arquivos modificados (\*.backup)

**IMPORTANTE**: Isso modifica mais de 600 arquivos! Use o cherry-pick ao enviar seu PR (veja abaixo).

### 5. Faça commit APENAS dos seus novos arquivos de aplicação

```bash
git commit -m "Your commit message"
```

### 5. Envie para o seu fork

```bash
git push origin your-feature-branch
```

### 6. Cherry-pick: Envie apenas seus arquivos para o PR

⚠️ **IMPORTANTE**: O setup-fork.sh modificou mais de 600 arquivos. Você DEVE enviar apenas seus 3 novos arquivos!

Consulte o [README.md - Guia de Cherry-pick](README.md#-cherry-pick-submitting-only-your-changes) para obter instruções passo a passo.

Versão resumida:

```bash
# Create clean branch from upstream
git fetch upstream
git checkout -b submit/myapp upstream/main

# Copy only your files
cp ../your-work-branch/ct/myapp.sh ct/myapp.sh
cp ../your-work-branch/install/myapp-install.sh install/myapp-install.sh
cp ../your-work-branch/frontend/public/json/myapp.json frontend/public/json/myapp.json

# Commit and verify
git add ct/myapp.sh install/myapp-install.sh frontend/public/json/myapp.json
git commit -m "feat: add MyApp"
git diff upstream/main --name-only  # Should show ONLY your 3 files

# Push and create PR
git push origin submit/myapp
```

### 7. Criar um Pull Request

Abra um Pull Request em `submit/myapp` → `community-scripts/ProxmoxVE/main`.

Verifique se o PR mostra APENAS estes 3 arquivos:

- `ct/myapp.sh`
- `install/myapp-install.sh`
- `frontend/public/json/myapp.json`

---

# 🛠️ Modo Desenvolvedor e Depuração

Ao compilar ou testar scripts, você pode usar a variável `dev_mode` para habilitar recursos avançados de depuração. Essas flags podem ser combinadas (separadas por vírgula).

**Uso**:

```bash
# Example: Run with trace and keep the container even if it fails
dev_mode="trace,keep" bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/myapp.sh)"
```

### Flags disponíveis:

| Flag         | Descrição                                                                   |
| :----------- | :-------------------------------------------------------------------------- |
| `trace`      | Habilita `set -x` para obter o máximo de detalhes durante a execução.       |
| `keep`       | Impede que o contêiner seja excluído se a compilação falhar.                |
| `pause`      | Pausa a execução em pontos-chave (por exemplo, antes da personalização).    |
| `breakpoint` | Permite que chamadas `breakpoint` codificadas em scripts executem um shell. |
| `logs`       | Salva logs de compilação detalhados em `/var/log/community-scripts/`.       |
| `dryrun`     | Ignora a criação real do contêiner (suporte limitado).                      |
| `motd`       | Força uma atualização da Mensagem do Dia (MOTD).                            |

---

## 📚 Páginas

- [Modelo CT: AppName.sh](https://github.com/community-scripts/ProxmoxVE/blob/main/docs/contribution/templates_ct/AppName.sh)
- [Modelo de Instalação: AppName-install.sh](https://github.com/community-scripts/ProxmoxVE/blob/main/docs/contribution/templates_install/AppName-install.sh)
- [Modelo JSON: AppName.json](https://github.com/community-scripts/ProxmoxVE/blob/main/docs/contribution/templates_json/AppName.json)
