# Documentação de Integração da API (/api)

Este diretório contém documentação completa para integração da API e o diretório `/api`.

## Visão Geral

O diretório `/api` contém o backend da API de Scripts da Comunidade Proxmox para geração de relatórios de diagnóstico, telemetria e integração de análises.

## Componentes Principais

### Serviço Principal da API

Localizado em `/api/main.go`:

- API RESTful para recebimento de dados de telemetria
- Rastreamento de estatísticas de instalação
- Relatórios e análises de erros
- Monitoramento de desempenho

### Integração com Scripts

A API é integrada a todos os scripts de instalação por meio de `api.func`:

- Envia eventos de início/conclusão da instalação
- Reporta erros e códigos de saída
- Coleta estatísticas de uso anônimas
- Permite análises do projeto

## Estrutura da Documentação

A documentação da API abrange:

- Especificações dos endpoints da API
- Métodos de integração
- Formatos e esquemas de dados
- Tratamento de erros
- Privacidade e tratamento de dados

## Recursos Principais

- **[misc/api.func/](../misc/api.func/)** - Documentação da biblioteca de funções da API
- **[misc/api.func/README.md](../misc/api.func/README.md)** - Guia de referência rápida
- **[misc/api.func/API_FUNCTIONS_REFERENCE.md](../misc/api.func/API_FUNCTIONS_REFERENCE.md)** - Referência completa das funções

## Funções da API

A biblioteca `api.func` fornece:

### `post_to_api()`

Envia dados de instalação do contêiner para a API.

**Uso**:

```bash
post_to_api CTID STATUS APP_NAME
```

### `post_update_to_api()`

Relata o status da atualização do aplicativo.

**Uso**:

```bash
post_update_to_api CTID APP_NAME VERSION
```

### `get_error_description()`

Obtém uma descrição de erro legível a partir do código de saída.

**Uso**:

```bash
ERROR_DESC=$(get_error_description EXIT_CODE)
```

## Pontos de Integração da API

### Na Criação do Contêiner (`ct/AppName.sh`)

- Chamado por build.func para reportar a criação do contêiner
- Envia os dados iniciais de configuração do contêiner
- Reporta sucesso ou falha

### Nos Scripts de Instalação (`install/appname-install.sh`)

- Chamado no início da instalação
- Chamado na conclusão da instalação
- Chamado em caso de erro

### Dados Coletados

- ID do Contêiner/VM
- Nome e versão do aplicativo
- Duração da instalação
- Status de sucesso/falha
- Códigos de erro (em caso de falha)
- Métricas de uso anônimas

## Privacidade

Todos os dados da API:

- ✅ Anônimos (sem dados pessoais)
- ✅ Agregados para estatísticas
- ✅ Usados ​​apenas para melhoria do projeto
- ✅ Sem rastreamento de identidades de usuários
- ✅ Podem ser desativados, se desejado

## API Arquitetura

```
Installation Scripts
    │
    ├─ Call: api.func functions
    │
    └─ POST to: https://api.community-scripts.org
                │
                ├─ Receives data
                ├─ Validates format
                ├─ Stores metrics
                └─ Aggregates statistics
                    │
                    └─ Used for:
                       ├─ Download tracking
                       ├─ Error trending
                       ├─ Feature usage stats
                       └─ Project health monitoring
```

## Tarefas comuns da API

- **Habilitar relatório da API** → Integrado por padrão, sem necessidade de configuração
- **Desabilitar API** → Defina `api_disable="yes"` antes de executar
- **Visualizar dados da API** → Acesse https://community-scripts.org/stats
- **Reportar erros da API** → [Problemas no GitHub](https://github.com/community-scripts/ProxmoxVE/issues)

## Depurando problemas da API

Se as chamadas da API falharem:

1. Verifique a conectividade com a internet
2. Verifique a disponibilidade do endpoint da API
3. Revise os códigos de erro em [EXIT_CODES.md](../EXIT_CODES.md)
4. Verifique os logs da função da API
5. Relate os problemas no GitHub

## Endpoint da API

**URL base**: `https://api.community-scripts.org`

**Endpoints**:

- `POST /install` - Relatar instalação de contêiner
- `POST /update` - Relatar atualização do aplicativo
- `GET /stats` - Estatísticas públicas

---

**Última atualização**: Dezembro de 2025
**Mantenedores**: Equipe community-scripts
