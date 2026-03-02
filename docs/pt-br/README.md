# 📚 Documentação do ProxmoxVE

Guia completo para toda a documentação do ProxmoxVE - encontre rapidamente o que você precisa.

---

## 🎯 **Navegação rápida por objetivo**

### 👤 **Eu quero...**

**Contribuir com um novo aplicativo** → Comece com: [contribution/README.md](contribution/README.md) → Em seguida: [ct/DETAILED_GUIDE.md](ct/DETAILED_GUIDE.md) +
[install/DETAILED_GUIDE.md](install/DETAILED_GUIDE.md)

**Entender a arquitetura** → Leia: [TECHNICAL_REFERENCE.md](TECHNICAL_REFERENCE.md) → Em seguida: [misc/README.md](misc/README.md)

**Depurar uma instalação com falha** → Verifique: [EXIT_CODES.md](EXIT_CODES.md) → Em seguida: [DEV_MODE.md](DEV_MODE.md) → Veja também: [misc/error_handler.func/](misc/error_handler.func/)

**Configurar padrões do sistema** → Leia: [guides/DEFAULTS_SYSTEM_GUIDE.md](guides/DEFAULTS_SYSTEM_GUIDE.md)

**Implantar contêineres automaticamente** → Leia: [guides/UNATTENDED_DEPLOYMENTS.md](guides/UNATTENDED_DEPLOYMENTS.md)

**Desenvolver uma biblioteca de funções** → Estude: [misc/](misc/) documentação

---

## 👤 **Início Rápido por Função**

### **Eu sou um(a)...**

**Novo Colaborador** → Comece: [contribution/README.md](contribution/README.md) → Em seguida: Escolha seu caminho abaixo

**Criador de Contêineres** → Leia: [ct/README.md](ct/README.md) → Aprofundamento: [ct/DETAILED_GUIDE.md](ct/DETAILED_GUIDE.md) → Referência: [misc/build.func/](misc/build.func/)

**Desenvolvedor de Scripts de Instalação** → Leia: [install/README.md](install/README.md) → Aprofundamento: [install/DETAILED_GUIDE.md](install/DETAILED_GUIDE.md) → Referência:
[misc/tools.func/](misc/tools.func/)

**Provisionador de VMs** → Leia: [vm/README.md](vm/README.md) → Referência: [misc/cloud-init.func/](misc/cloud-init.func/)

**Desenvolvedor de Ferramentas** → Leia: [tools/README.md](tools/README.md) → Referência: [misc/build.func/](misc/build.func/)

**Integrador de API** → Leia: [api/README.md](api/README.md) → Referência: [misc/api.func/](misc/api.func/)

**Operador de Sistema** → Inicie: [EXIT_CODES.md](EXIT_CODES.md) → Em seguida: [guides/DEFAULTS_SYSTEM_GUIDE.md](guides/DEFAULTS_SYSTEM_GUIDE.md) → Automatizar:
[guides/UNATTENDED_DEPLOYMENTS.md](guides/UNATTENDED_DEPLOYMENTS.md) → Depurar: [DEV_MODE.md](DEV_MODE.md)

**Arquitetura** → Ler: [TECHNICAL_REFERENCE.md](TECHNICAL_REFERENCE.md) → Analisar em detalhes: [misc/README.md](misc/README.md)

---

## 📂 **Estrutura da Documentação**

### Diretórios Espelhados do Projeto

Cada diretório principal do projeto contém a seguinte documentação:

```
ProxmoxVE/
├─ ct/                 ↔ docs/ct/ (README.md + DETAILED_GUIDE.md)
├─ install/           ↔ docs/install/ (README.md + DETAILED_GUIDE.md)
├─ vm/                ↔ docs/vm/ (README.md)
├─ tools/            ↔ docs/tools/ (README.md)
├─ api/              ↔ docs/api/ (README.md)
├─ misc/             ↔ docs/misc/ (9 function libraries)
└─ [system-wide]     ↔ docs/guides/ (configuration & deployment guides)
```

### Núcleo Documentação

| Documento | Objetivo | Público-alvo |

|----------|---------|----------|

| [contribution/README.md](contribution/README.md) | Como contribuir | Colaboradores | | [ct/DETAILED_GUIDE.md](ct/DETAILED_GUIDE.md) | Criar scripts ct | Desenvolvedores de contêineres | |
[install/DETAILED_GUIDE.md](install/DETAILED_GUIDE.md) | Criar scripts de instalação | Desenvolvedores de instalação | | [TECHNICAL_REFERENCE.md](TECHNICAL_REFERENCE.md) | Análise detalhada da
arquitetura | Arquitetos, usuários avançados | | [guides/DEFAULTS_SYSTEM_GUIDE.md](guides/DEFAULTS_SYSTEM_GUIDE.md) | Sistema de configuração | Operadores, usuários avançados | |
[guides/CONFIGURATION_REFERENCE.md](guides/CONFIGURATION_REFERENCE.md) | Referência de opções de configuração | Usuários avançados | |
[guides/UNATTENDED_DEPLOYMENTS.md](guides/UNATTENDED_DEPLOYMENTS.md) | Implantações automatizadas | DevOps, automação | | [EXIT_CODES.md](EXIT_CODES.md) | Referência de códigos de saída | Solução de
problemas | | [DEV_MODE.md](DEV_MODE.md) | Ferramentas de depuração | Desenvolvedores |

---

## 📂 **Guia de diretórios**

### [ct/](ct/) - Scripts de contêiner

Documentação para `/ct` - Scripts de criação de contêiner que são executados no host Proxmox.

**Inclui**:

- Visão geral do processo de criação de contêineres
- Guia detalhado: [DETAILED_GUIDE.md](ct/DETAILED_GUIDE.md) - Referência completa com exemplos
- Referência a [misc/build.func/](misc/build.func/)
- Guia rápido para criação de novos contêineres

### [install/](install/) - Scripts de instalação

Documentação para `/install` - Scripts executados dentro de contêineres para instalar aplicativos.

**Inclui**:

- Visão geral do padrão de instalação em 10 fases
- Análise detalhada: [DETAILED_GUIDE.md](install/DETAILED_GUIDE.md) - Referência completa com exemplos
- Referência a [misc/tools.func/](misc/tools.func/)
- Diferenças entre Alpine e Debian

### [vm/](vm/) - Scripts de Máquina Virtual

Documentação para `/vm` - Scripts de criação de VMs usando o provisionamento cloud-init.

**Inclui**:

- Visão geral do provisionamento de VMs
- Link para [misc/cloud-init.func/](misc/cloud-init.func/)
- Comparação entre VMs e Contêineres
- Exemplos de cloud-init

### [tools/](tools/) - Ferramentas e Utilitários

Documentação para `/tools` - Ferramentas de gerenciamento e complementos.

**Inclui**:

- Visão geral da estrutura das ferramentas
- Pontos de integração
- Contribuição com novas ferramentas
- Operações comuns

### [api/](api/) - Integração de API

Documentação para `/api` - Telemetria e backend da API.

**Inclui**:

- Visão geral da API
- Métodos de integração
- Endpoints da API
- Informações de privacidade

### [misc/](misc/) - Bibliotecas de funções

Documentação para `/misc` - 9 bibliotecas de funções principais com referências completas. ... 9 bibliotecas de funções principais com referências completas. **Contém**:

- **build.func/** - Orquestração de contêineres (7 arquivos)
- **core.func/** - Utilitários e mensagens (5 arquivos)
- **error_handler.func/** - Tratamento de erros (5 arquivos)
- **api.func/** - Integração de API (5 arquivos)
- **install.func/** - Configuração de contêineres (5 arquivos)
- **tools.func/** - Instalação de pacotes (6 arquivos)
- **alpine-install.func/** - Configuração do Alpine (5 arquivos)
- **alpine-tools.func/** - Ferramentas do Alpine (5 arquivos)
- **cloud-init.func/** - Provisionamento de VMs (5 arquivos)

---

## 🎓 **Caminhos de Aprendizagem**

### Caminho 1: Contribuidor Iniciante (2-3 horas)

1. [contribution/README.md](contribution/README.md) - Início Rápido
2. Escolha o seu Área:

- Contêineres → [ct/README.md](ct/README.md) + [ct/DETAILED_GUIDE.md](ct/DETAILED_GUIDE.md)

- Instalação → [install/README.md](install/README.md) + [install/DETAILED_GUIDE.md](install/DETAILED_GUIDE.md)

- VMs → [vm/README.md](vm/README.md)

3. Estude scripts similares existentes
4. Crie sua contribuição
5. Envie o PR

### Caminho 2: Desenvolvedor Intermediário (4-6 horas)

1. [TECHNICAL_REFERENCE.md](TECHNICAL_REFERENCE.md)
2. Explore as bibliotecas de funções:

- [misc/build.func/README.md](misc/build.func/README.md)

- [misc/tools.func/README.md](misc/tools.func/README.md)

- [misc/install.func/README.md](misc/install.func/README.md)

3. Estude exemplos avançados
4. Crie aplicações complexas

### Caminho 3: Arquiteto Avançado (8+ horas)

1. Todo o Caminho Intermediário
2. Estude todas as 9 bibliotecas de funções em profundidade
3. [guides/DEFAULTS_SYSTEM_GUIDE.md](guides/DEFAULTS_SYSTEM_GUIDE.md) - Sistema de configuração
4. [DEV_MODE.md](DEV_MODE.md) - Depuração e desenvolvimento
5. Projete novos recursos ou bibliotecas de funções

### Caminho 4: Solução de Problemas (30 minutos - 1 hora)

1. [EXIT_CODES.md](EXIT_CODES.md) - Encontrar o código de erro
2. [DEV_MODE.md](DEV_MODE.md) - Executar com depuração
3. Verificar a documentação da biblioteca de funções relevante
4. Analisar os logs e corrigir

---

## 📊 **Em Números**

| Métrica | Contagem |

|--------|:---:|

| **Arquivos de Documentação** | 63 | | **Total de Linhas** | Mais de 15.000 | | **Bibliotecas de Funções** | 9 | | **Funções Documentadas** | Mais de 150 | | **Exemplos de Código** | Mais de 50 | |
**Fluxogramas** | Mais de 15 | | **Seções de Recomendações** | Mais de 20 | | **Exemplos do Mundo Real** | Mais de 30 |

---

## 🔍 **Encontre Rapidamente**

### Por Recurso

- **Como criar um contêiner?** → [ct/DETAILED_GUIDE.md](ct/DETAILED_GUIDE.md)
- **Como criar um script de instalação?** → [install/DETAILED_GUIDE.md](install/DETAILED_GUIDE.md)
- **Como criar uma VM?** → [vm/README.md](vm/README.md)
- **Como instalar o Node.js?** → [misc/tools.func/](misc/tools.func/)
- **Como depurar?** → [DEV_MODE.md](DEV_MODE.md)

### Por Erro

- **Código de saída 206?** → [EXIT_CODES.md](EXIT_CODES.md)
- **Falha na rede?** → [misc/install.func/](misc/install.func/)
- **Erro no pacote?** → [misc/tools.func/](misc/tools.func/)

### Por função

- **Colaborador** → [contribution/README.md](contribution/README.md)
- **Operador** → [guides/DEFAULTS_SYSTEM_GUIDE.md](guides/DEFAULTS_SYSTEM_GUIDE.md)
- **Automação** → [guides/UNATTENDED_DEPLOYMENTS.md](guides/UNATTENDED_DEPLOYMENTS.md)
- **Desenvolvedor** → [TECHNICAL_REFERENCE.md](TECHNICAL_REFERENCE.md)
- **Arquiteto** → [misc/README.md](misc/README.md)

---

## ✅ **Recursos da Documentação**

- ✅ **Estrutura espelhada do projeto** - Organizada como o projeto real
- ✅ **Referências completas de funções** - Todas as funções documentadas
- ✅ **Exemplos práticos** - Código pronto para copiar e colar
- ✅ **Fluxogramas visuais** - Diagramas ASCII de fluxos de trabalho
- ✅ **Guias de integração** - Como os componentes se conectam
- ✅ **Solução de problemas** - Problemas comuns e suas soluções
- ✅ **Melhores práticas** - Seções de "FAÇA/NÃO FAÇA" ao longo do documento
- ✅ **Trilhas de aprendizado** - Currículo estruturado por função
- ✅ **Referências rápidas** - Busca rápida por código de erro
- ✅ **Navegação completa** - Esta página

---

## 🚀 **Comece aqui**

**Novo no ProxmoxVE?** → [contribution/README.md](contribution/README.md)

**Procurando algo específico?** → Escolha sua função acima ou navegue por diretório

**Precisa depurar?** → [EXIT_CODES.md](EXIT_CODES.md)

**Quer entender a arquitetura?** → [TECHNICAL_REFERENCE.md](TECHNICAL_REFERENCE.md)

---

## 🤝 **Contribuindo com a Documentação**

Encontrou um erro? Quer melhorar a documentação?

1. Consulte: [contribution/README.md](contribution/README.md) para o guia completo de contribuição
2. Abra uma issue: [GitHub Issues](https://github.com/community-scripts/ProxmoxVE/issues)
3. Ou envie um PR com melhorias

---

## 📝 **Status**

- **Última atualização**: Dezembro de 2025
- **Versão**: 2.3 (Consolidada e reorganizada)
- **Completude**: ✅ 100% - Todos os componentes documentados
- **Qualidade**: ✅ Pronta para produção
- **Estrutura**: ✅ Limpa e organizada

---

**Bem-vindo ao ProxmoxVE!** Comece com [CONTRIBUTION_GUIDE.md](CONTRIBUTION_GUIDE.md) ou escolha sua função acima.\*\* 🚀
