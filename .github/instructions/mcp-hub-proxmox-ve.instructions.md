---
description: Describe when these instructions should be loaded
# applyTo: 'Describe when these instructions should be loaded' # when provided, instructions will automatically be added to the request context when the pattern matches an attached file
---

# MCP Hub Proxmox VE Instructions

Instruções para desenvolver e configurar o MCP Hub para o Proxmox VE. Abaixo estão as especificações geradas pelo Claude fazendo uma documentação geral do projeto.

# Hub MCP Local no Proxmox - Guia Completo

**Autor:** Claude (assistente de Nícolas)  
**Data:** 27 de Fevereiro de 2026  
**Versão:** 1.0

---

## Sumário Executivo

Este documento detalha como criar um **hub centralizado de servidores MCP** em um LXC no Proxmox, permitindo que múltiplos clientes (Claude Desktop, ChatGPT, VSCode, JetBrains) na rede local acessem os MCPs através de um único endpoint.

---

## 1. Análise da Sua Infraestrutura

### Hardware Disponível

| Componente         | Especificação                                 |
| ------------------ | --------------------------------------------- |
| **Proxmox**        | VE 9.1.5 (Kernel 6.17.9)                      |
| **CPU**            | Intel i5-9400F (6 cores @ 2.9-4.1GHz)         |
| **RAM Total**      | ~16GB (15912 MiB)                             |
| **RAM Disponível** | ~4.7GB livre para novos containers            |
| **Storage LXCs**   | ZFS pool "tank" (501GB livres)                |
| **GPU**            | RTX 2060 (passthrough para VM, não afeta LXC) |

### Rede

| Item         | Configuração                            |
| ------------ | --------------------------------------- |
| **Roteador** | Cudy WR3000 + OpenWRT 24.10.5           |
| **Faixa IP** | 192.168.1.0/24                          |
| **Proxmox**  | 192.168.1.3 (fixo)                      |
| **Desktop**  | 192.168.1.2 (fixo)                      |
| **VPN**      | Tailscale (para acesso remoto da Elisa) |

### Recursos Recomendados para o LXC do MCP Hub

| Recurso   | Mínimo                   | Recomendado                  |
| --------- | ------------------------ | ---------------------------- |
| **vCPU**  | 2 cores                  | 2-4 cores                    |
| **RAM**   | 1GB                      | 2-4GB                        |
| **Disco** | 8GB                      | 16-32GB                      |
| **IP**    | Fixo (ex: 192.168.1.150) | Via DHCP estático no OpenWRT |

**Justificativa:** MCPs são processos leves (Node.js/Python). 2GB de RAM comportam ~10-15 MCPs simultâneos tranquilamente.

---

## 2. Conceitos Fundamentais de MCP

### O que é MCP (Model Context Protocol)?

O MCP é um protocolo padronizado para que IAs (Claude, ChatGPT, etc.) interajam com serviços externos (arquivos, APIs, bancos de dados, etc.) através de "servidores MCP".

### Transportes MCP (Importante!)

| Transporte          | Uso                    | Suporte                   |
| ------------------- | ---------------------- | ------------------------- |
| **stdio**           | Local (processo filho) | Universal                 |
| **Streamable HTTP** | Remoto (padrão atual)  | Moderno (spec 2025-03-26) |
| **SSE**             | Remoto (legado)        | Depreciado, mas funcional |

**Problema central:** A maioria dos clientes MCP (Claude Desktop, Cursor, etc.) ainda só suporta **stdio** nativamente. Para acessar MCPs remotos, precisamos de um **proxy/adapter**.

### Arquitetura Proposta

```
┌─────────────────────────────────────────────────────────────────┐
│                      SUA REDE LOCAL                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐      │
│  │   Desktop    │     │  Galaxy Book │     │  Notebook    │      │
│  │  192.168.1.2 │     │   (WiFi)     │     │  Empresa     │      │
│  └──────┬───────┘     └──────┬───────┘     └──────┬───────┘      │
│         │                    │                    │               │
│         │  Claude Desktop    │  VSCode           │  JetBrains    │
│         │  ChatGPT Desktop   │  JetBrains        │  VSCode       │
│         │  VSCode            │                    │               │
│         │                    │                    │               │
│         └────────────────────┴────────────────────┘               │
│                              │                                    │
│                              ▼                                    │
│                    ┌─────────────────┐                            │
│                    │   Cudy WR3000   │                            │
│                    │  192.168.1.1    │                            │
│                    └────────┬────────┘                            │
│                             │                                     │
│                             ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                  PROXMOX (192.168.1.3)                    │    │
│  │  ┌────────────────────────────────────────────────────┐  │    │
│  │  │          LXC: mcp-hub (192.168.1.150)              │  │    │
│  │  │                                                     │  │    │
│  │  │   ┌─────────────────────────────────────────────┐  │  │    │
│  │  │   │            MCP-HUB (porta 37373)            │  │  │    │
│  │  │   │                                              │  │  │    │
│  │  │   │  Endpoints:                                  │  │  │    │
│  │  │   │  • /mcp (Streamable HTTP) ← Clientes        │  │  │    │
│  │  │   │  • /sse (SSE fallback)                      │  │  │    │
│  │  │   │  • /api/* (Gerenciamento REST)              │  │  │    │
│  │  │   └─────────────────────────────────────────────┘  │  │    │
│  │  │                        │                            │  │    │
│  │  │   ┌────────────────────┼────────────────────────┐  │  │    │
│  │  │   │                    ▼                        │  │  │    │
│  │  │   │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐       │  │  │    │
│  │  │   │  │ MCP  │ │ MCP  │ │ MCP  │ │ MCP  │       │  │  │    │
│  │  │   │  │FS    │ │GitHub│ │Docker│ │Custom│       │  │  │    │
│  │  │   │  │Server│ │Server│ │Server│ │Server│ ...   │  │  │    │
│  │  │   │  └──────┘ └──────┘ └──────┘ └──────┘       │  │  │    │
│  │  │   │           (stdio processes)                 │  │  │    │
│  │  │   └─────────────────────────────────────────────┘  │  │    │
│  │  └────────────────────────────────────────────────────┘  │    │
│  └──────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Opções de Implementação

**Repositório original do projeto:** https://github.com/ravitemer/mcp-hub

**Repositório do MCP-Hub de um fork do projeto original:**: https://github.com/nicolasaigner/mcp-hub

> ! Vamos usar o repositório: `nicolasaigner/mcp-hub`.

**Descrição:** Solução completa e madura para centralizar MCPs. Implementa spec MCP 2025-03-26.

**Vantagens:**

- Interface unificada: `/mcp` para todos os clientes
- Suporta stdio, SSE e Streamable HTTP
- Namespacing automático (evita conflitos entre MCPs)
- Hot reload de configuração
- Marketplace integrado
- REST API para gerenciamento
- SSE para eventos em tempo real

**Desvantagens:**

- Requer Node.js 18+
- Projeto relativamente novo (mas ativo)

---

## 4. Implementação Detalhada com MCP-Hub

### 4.1 Criar o LXC no Proxmox

```bash
# No shell do Proxmox (192.168.1.3)

# 1. Baixar template Debian 12 (se não tiver)
pveam download local debian-12-standard_12.2-1_amd64.tar.zst

# 2. Criar LXC
pct create 130 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname mcp-hub \
  --storage tank \
  --rootfs tank:32 \
  --memory 2048 \
  --swap 512 \
  --cores 2 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --features nesting=1 \
  --unprivileged 1 \
  --start 1

# 3. Entrar no container
pct enter 130
```

### 4.2 Configurar IP Fixo no OpenWRT

Adicione no DHCP Static Leases do OpenWRT:

- **Hostname:** mcp-hub
- **MAC:** (ver com `ip link show eth0` dentro do LXC)
- **IP:** 192.168.1.150

### 4.3 Instalar Dependências no LXC

```bash
# Atualizar sistema
apt update && apt upgrade -y

# Instalar Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Verificar versões
node --version  # v20.x
npm --version   # 10.x

# Instalar ferramentas auxiliares
apt install -y git curl wget htop

# Instalar MCP-Hub globalmente
npm install -g mcp-hub

# Verificar instalação
mcp-hub --help
```

### 4.4 Criar Estrutura de Configuração

```bash
# Criar diretórios
mkdir -p /etc/mcp-hub
mkdir -p /var/log/mcp-hub

# Criar arquivo de configuração principal
cat > /etc/mcp-hub/servers.json << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/data"],
      "env": {}
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "env": {}
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {}
    }
  }
}
EOF

# Criar diretório de dados compartilhados
mkdir -p /data
chmod 755 /data
```

### 4.5 Criar Serviço Systemd

```bash
cat > /etc/systemd/system/mcp-hub.service << 'EOF'
[Unit]
Description=MCP Hub Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/mcp-hub
ExecStart=/usr/bin/mcp-hub --port 37373 --config /etc/mcp-hub/servers.json --watch
Restart=always
RestartSec=10
StandardOutput=append:/var/log/mcp-hub/stdout.log
StandardError=append:/var/log/mcp-hub/stderr.log

# Variáveis de ambiente globais para todos os MCPs
Environment="NODE_ENV=production"
Environment="HOME=/root"

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar
systemctl daemon-reload
systemctl enable mcp-hub
systemctl start mcp-hub

# Verificar status
systemctl status mcp-hub
```

### 4.6 Verificar Funcionamento

```bash
# Testar endpoint de saúde
curl http://192.168.1.150:37373/api/health

# Listar servidores
curl http://192.168.1.150:37373/api/servers

# Ver logs
journalctl -u mcp-hub -f
```

---

## 5. Configuração dos Clientes

### 5.1 Claude Desktop (Windows/Mac)

**Localização do config:**

- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`

**Método 1: Usando mcp-remote (Recomendado)**

```json
{
  "mcpServers": {
    "hub": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "http://192.168.1.150:37373/mcp"]
    }
  }
}
```

**Método 2: Se Claude Desktop suportar HTTP diretamente (versões mais recentes)**

```json
{
  "mcpServers": {
    "hub": {
      "type": "streamable-http",
      "url": "http://192.168.1.150:37373/mcp"
    }
  }
}
```

### 5.2 VSCode

**Extensão:** Instale uma extensão MCP compatível (ex: Roo Code, Continue.dev)

**Configuração em `.vscode/settings.json`:**

```json
{
  "mcp.servers": {
    "hub": {
      "type": "streamable-http",
      "url": "http://192.168.1.150:37373/mcp"
    }
  }
}
```

**Ou com mcp-remote via stdio:**

```json
{
  "mcp.servers": {
    "hub": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "http://192.168.1.150:37373/mcp"]
    }
  }
}
```

### 5.3 JetBrains (IntelliJ, WebStorm, etc.)

Depende do plugin MCP que você usa. Geralmente aceita configuração similar ao VSCode.

### 5.4 ChatGPT Desktop

O ChatGPT Desktop usa formato similar ao Claude Desktop. Verifique a documentação específica da versão que você usa.

---

## 6. MCPs Úteis para Desenvolvimento

### MCPs Oficiais (Anthropic/ModelContextProtocol)

| MCP            | Descrição           | Comando                                                |
| -------------- | ------------------- | ------------------------------------------------------ |
| **filesystem** | Acesso a arquivos   | `npx -y @modelcontextprotocol/server-filesystem /path` |
| **fetch**      | Requisições HTTP    | `npx -y @modelcontextprotocol/server-fetch`            |
| **memory**     | Memória persistente | `npx -y @modelcontextprotocol/server-memory`           |
| **postgres**   | PostgreSQL          | `npx -y @modelcontextprotocol/server-postgres`         |
| **sqlite**     | SQLite              | `npx -y @modelcontextprotocol/server-sqlite`           |
| **git**        | Operações Git       | `npx -y @modelcontextprotocol/server-git`              |

### MCPs de Terceiros Populares

| MCP                     | Descrição            | Repositório              |
| ----------------------- | -------------------- | ------------------------ |
| **github**              | GitHub API           | github/github-mcp-server |
| **docker**              | Gerenciar containers | ...                      |
| **browser-use**         | Automação de browser | ...                      |
| **sequential-thinking** | Chain of thought     | ...                      |

### Exemplo de Configuração Completa

```json
{
  "mcpServers": {
    "filesystem-home": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/data/home"],
      "env": {}
    },
    "filesystem-projects": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/data/projects"],
      "env": {}
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "env": {}
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {}
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git", "--repository", "/data/projects"],
      "env": {}
    },
    "github": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

---

## 7. Acesso Remoto via Tailscale

### 7.1 Instalar Tailscale no LXC

```bash
# Instalar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Autenticar
tailscale up

# Verificar IP Tailscale
tailscale ip -4
```

### 7.2 Configuração para Elisa

1. Elisa instala Tailscale no dispositivo dela
2. Você convida ela para sua Tailnet
3. Ela configura o cliente MCP apontando para o IP Tailscale do LXC:

```json
{
  "mcpServers": {
    "nicolas-hub": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "http://100.x.x.x:37373/mcp"]
    }
  }
}
```

---

## 8. Segurança

### 8.1 Recomendações Mínimas

1. **Não expor na internet** - Use apenas na rede local ou via Tailscale
2. **API Key** - MCP-Hub suporta autenticação via `ALLOWED_KEYS`
3. **Firewall** - Configure o OpenWRT para limitar acesso à porta 37373

### 8.2 Configurar API Key no MCP-Hub

```bash
# Adicionar ao service
Environment="ALLOWED_KEYS=sua-chave-secreta-aqui"
```

Clientes precisam passar header:

```
X-Api-Key: sua-chave-secreta-aqui
```

---

## 9. Monitoramento e Logs

### 9.1 Endpoints Úteis

| Endpoint                  | Descrição             |
| ------------------------- | --------------------- |
| `GET /api/health`         | Status geral do hub   |
| `GET /api/servers`        | Lista de MCPs         |
| `GET /api/events`         | Stream SSE de eventos |
| `POST /api/servers/tools` | Executar ferramenta   |
| `POST /api/restart`       | Reiniciar hub         |

### 9.2 Logs

```bash
# Logs do systemd
journalctl -u mcp-hub -f

# Logs estruturados
tail -f ~/.local/state/mcp-hub/logs/mcp-hub.log
```

---

## 10. Troubleshooting

### Problema: Cliente não conecta

**Verificar:**

1. Ping do cliente para `192.168.1.150`
2. `curl http://192.168.1.150:37373/api/health`
3. Firewall do LXC: `iptables -L`
4. Node.js instalado no cliente (para `npx mcp-remote`)

### Problema: MCP específico não funciona

```bash
# Testar MCP manualmente
npx -y @modelcontextprotocol/server-filesystem /data

# Ver logs do hub
journalctl -u mcp-hub | grep "server-name"
```

### Problema: Timeout nas requisições

- Aumentar timeout no cliente
- Verificar se o MCP não está travado (htop no LXC)
- Verificar conectividade de rede

---

## 11. Referências

### Documentação Oficial

- **MCP Specification:** https://modelcontextprotocol.io/specification/2025-03-26
- **MCP Servers Oficiais:** https://github.com/modelcontextprotocol/servers
- **MCP-Hub:** https://github.com/ravitemer/mcp-hub
- **mcp-remote:** https://www.npmjs.com/package/mcp-remote
- **mcp-proxy (Python):** https://github.com/sparfenyuk/mcp-proxy

### Artigos e Tutoriais

- [Why MCP Deprecated SSE](https://blog.fka.dev/blog/2025-06-06-why-mcp-deprecated-sse-and-go-with-streamable-http/)
- [MCP Transports Explained](https://docs.roocode.com/features/mcp/server-transports)
- [Building Remote MCP Servers](https://support.claude.com/en/articles/11503834-building-custom-connectors-via-remote-mcp-servers)

### Repositórios Úteis

- https://github.com/ravitemer/mcp-hub (Hub centralizado)
- https://github.com/sparfenyuk/mcp-proxy (Proxy Python)
- https://github.com/punkpeye/mcp-proxy (Proxy TypeScript)
- https://github.com/modelcontextprotocol/servers (MCPs oficiais)
- https://github.com/github/github-mcp-server (GitHub MCP)

---

## 12. Limitações e Considerações

### O que É VIÁVEL

✅ Centralizar MCPs baseados em stdio no Proxmox  
✅ Acessar de qualquer máquina na rede local  
✅ Usar com Claude Desktop, VSCode, JetBrains (via mcp-remote)  
✅ Acesso remoto via Tailscale  
✅ Hot reload de configuração  
✅ Múltiplos MCPs simultâneos

### O que NÃO É VIÁVEL (ou tem limitações)

⚠️ **MCPs que precisam de GUI** - Não funcionam em LXC headless  
⚠️ **MCPs que precisam de hardware específico** - Ex: GPU, USB  
⚠️ **ChatGPT Desktop** - Verificar se suporta MCP remote (pode variar por versão)  
⚠️ **Latência** - Adiciona ~1-5ms por requisição (rede local), negligenciável  
⚠️ **Stateful MCPs** - Alguns MCPs mantêm estado; reiniciar o hub perde estado

### Clientes com Suporte Nativo a HTTP MCP

| Cliente           | stdio     | SSE               | Streamable HTTP   |
| ----------------- | --------- | ----------------- | ----------------- |
| Claude Desktop    | ✅        | ⚠️ via mcp-remote | ⚠️ via mcp-remote |
| Claude Code       | ✅        | ✅                | ✅                |
| VSCode (Roo Code) | ✅        | ✅                | ✅                |
| Cursor            | ✅        | ✅                | ✅                |
| Continue.dev      | ✅        | ✅                | ✅                |
| ChatGPT Desktop   | Verificar | Verificar         | Verificar         |

**Nota:** Claude Desktop e outros clientes "desktop" frequentemente usam `mcp-remote` como bridge para acessar servidores HTTP remotos.

---

## 13. Próximos Passos

1. **Criar o LXC** seguindo a seção 4.1
2. **Instalar MCP-Hub** seguindo a seção 4.3
3. **Configurar MCPs iniciais** (filesystem, fetch, memory)
4. **Testar do Desktop** com curl e depois com Claude Desktop
5. **Adicionar mais MCPs** conforme necessidade
6. **Configurar Tailscale** para acesso remoto
7. **Documentar seus MCPs customizados**

---

## Conclusão

Com o **MCP-Hub** rodando em um LXC no seu Proxmox, você terá:

- **Um único endpoint** (`http://192.168.1.150:37373/mcp`) para todos os clientes
- **Gerenciamento centralizado** de todos os MCPs
- **Economia de recursos** - não precisa rodar MCPs em cada máquina
- **Flexibilidade** - adicione/remova MCPs via config sem reiniciar clientes
- **Acesso remoto** via Tailscale quando necessário

A configuração é relativamente simples e o MCP-Hub cuida de toda a complexidade de proxy e agregação de capabilities.

---

_Documento gerado em 27/02/2026 - Verifique as versões mais recentes dos componentes antes de implementar._

---

Informações do repositório particular:

- Repositório:
  - URL: https://github.com/nicolasaigner/ProxmoxVE
  - Descrição: Repositório que foi feito o fork do projeto original do `community-scripts` para o desenvolvimento do MCP Hub no Proxmox VE.
  - Visibilidade: Público
  - Branch principal: main
  - Branch de desenvolvimento: feature/mcp-hub

- Informações sobre o Proxmox local:
  - Estamos usando o Proxmox VE 9.1.5 com kernel 6.17.9.
  - Estamos em um ambiente do Windows 11, porém dentro do WSL2 com o Ubuntu 24.04;
  - É possível acessar o Proxmox na rede local através do SSH sem senha, pois o mesmo já está configurado para isso. Basta executar "ssh proxmox" no terminal do WSL2 para acessar o Proxmox.
  - O Proxmox tem um IP fixo na rede local: 192.168.1.3
  - O Desktop Windows 11 tem um IP fixo na rede local: 192.168.1.2
  - O roteador é um OpenWRT 24.10.5, modelo Cudy WR3000, com IP: 192.168.1.1

A ideia do projeto é criar um script por enquanto para ficar no meu repositório pessoal no github antes de tentar fazer qualquer fork ou algo do tipo. Tentei seguir o máximo possível das especificações do `community-scripts` para manter o padrão. A ideia é utilizar o projeto do MCP-Hub (https://github.com/nicolasaigner/mcp-hub) para criar um hub centralizado de servidores MCP em um LXC no Proxmox, permitindo que múltiplos clientes (Claude Desktop, ChatGPT, VSCode, JetBrains) na rede local acessem os MCPs através de um único endpoint. Agora é necessário criar o script de instalação configuração e etc. Tudo conforme é feito o desenvolvimento dos scripts do community-scripts.
