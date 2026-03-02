# Arquivos de Metadados JSON - Referência Rápida

O arquivo de metadados (`frontend/public/json/myapp.json`) informa à interface web como exibir seu aplicativo.

---

## Início Rápido

**Use a Ferramenta Geradora de JSON:** [https://community-scripts.github.io/ProxmoxVE/json-editor](https://community-scripts.github.io/ProxmoxVE/json-editor)

1. Insira os detalhes do aplicativo
2. O gerador cria o arquivo `frontend/public/json/myapp.json`
3. Copie o resultado para sua contribuição

---

## Estrutura do Arquivo

```json
{
  "name": "MyApp",
  "slug": "myapp",
  "categories": [1],
  "date_created": "2026-01-18",
  "type": "ct",
  "updateable": true,
  "privileged": false,
  "interface_port": 3000,
  "documentation": "https://docs.example.com/",
  "website": "https://example.com/",
  "logo": "https://cdn.jsdelivr.net/gh/selfhst/icons@main/webp/myapp.webp",
  "config_path": "/opt/myapp/.env",
  "description": "Brief description of what MyApp does",
  "install_methods": [
    {
      "type": "default",
      "script": "ct/myapp.sh",
      "resources": {
        "cpu": 2,
        "ram": 2048,
        "hdd": 8,
        "os": "Debian",
        "version": "13"
      }
    }
  ],
  "default_credentials": {
    "username": null,
    "password": null
  },
  "notes": [
    {
      "text": "Change the default password after first login!",
      "type": "warning"
    }
  ]
}
```

---

## Referência dos Campos

| Campo                 | Obrigatório | Exemplo                   | Observações                                               |
| --------------------- | ----------- | ------------------------- | --------------------------------------------------------- |
| `name`                | Sim         | "MyApp"                   | Nome de exibição                                          |
| `slug`                | Sim         | "myapp"                   | Identificador amigável para URL (minúsculas, sem espaços) |
| `categories`          | Sim         | [1]                       | Um ou mais IDs de categoria                               |
| `date_created`        | Sim         | "2026-01-18"              | Formato: AAAA-MM-DD                                       |
| `type`                | Sim         | "ct"                      | Tipo de contêiner: "ct" ou "vm"                           |
| `interface_port`      | Sim         | 3000                      | Porta padrão da interface web                             |
| `logo`                | Não         | "https://..."             | URL do logotipo (PNG de 64px x 64px)                      |
| `config_path`         | Sim         | "/opt/myapp/.env"         | Local do arquivo de configuração principal                |
| `description`         | Sim         | "Descrição do aplicativo" | Breve descrição (100 caracteres)                          |
| `install_methods`     | Sim         | Veja abaixo               | Recursos de instalação (array)                            |
| `default_credentials` | Não         | Veja abaixo               | Login padrão opcional                                     |
| `notes`               | Não         | Veja abaixo               | Notas adicionais (array)                                  |

---

## Métodos de Instalação

Cada método de instalação especifica os requisitos de recursos:

```json
"install_methods": [
  {
    "type": "default",
    "script": "ct/myapp.sh",
    "resources": {
      "cpu": 2,
      "ram": 2048,
      "hdd": 8,
      "os": "Debian",
      "version": "13"
    }
  }
]
```

**Recursos Padrão:**

- CPU: Núcleos (1-8)
- RAM: Megabytes (256-4096)
- Disco: Gigabytes (4-50)

---

## Categorias Comuns

- `0` Diversos
- `1` Proxmox e Virtualização
- `2` Sistemas Operacionais
- `3` Contêineres e Docker
- `4` Rede e Firewall
- `5` Adblock e DNS
- `6` Autenticação e Segurança
- `7` Backup e Recuperação
- `8` Bancos de Dados
- `9` Monitoramento e Análise
- `10` Painéis e Interfaces
- `11` Arquivos e Downloads
- `12` Documentos e Anotações
- `13` Mídia e Streaming
- `14` \*Arr Suite
- `15` NVR e Câmeras
- `16` IoT e Casa Inteligente
- `17` ZigBee, Z-Wave e Matter
- `18` MQTT e Mensagens
- `19` Automação e Agendamento
- `20` IA / Programação e Ferramentas de Desenvolvimento
- `21` Servidores Web e Proxies
- `22` Bots e ChatOps
- `23` Finanças e Orçamento
- `24` Jogos e Lazer
- `25` Negócios e ERP

---

## Boas Práticas

1. **Use o Gerador JSON** - Ele valida a estrutura
2. **Mantenha as descrições curtas** - Máximo de 100 caracteres
3. **Use requisitos de recursos reais** - Com base em seus testes
4. **Inclua valores padrão adequados** - Preenchidos previamente em install_methods
5. **O slug deve estar em minúsculas** - Sem espaços, use hífens

---

## Referências Exemplos

Veja exemplos reais no repositório:

- [frontend/public/json/trip.json](https://github.com/community-scripts/ProxmoxVE/blob/main/frontend/public/json/trip.json)
- [frontend/public/json/thingsboard.json](https://github.com/community-scripts/ProxmoxVE/blob/main/frontend/public/json/thingsboard.json)
- [frontend/public/json/unifi.json](https://github.com/community-scripts/ProxmoxVE/blob/main/frontend/public/json/unifi.json)

---

## Precisa de ajuda?

- **[Gerador JSON](https://community-scripts.github.io/ProxmoxVE/json-editor)** - Ferramenta interativa
- **[README.md](../README.md)** - Fluxo de trabalho completo para contribuição
- **[Início Rápido](../README.md)** - Guia passo a passo
