# Documentação de Ferramentas e Complementos (/tools)

Este diretório contém documentação completa para ferramentas, utilitários e complementos no diretório `/tools`.

## Visão Geral

O diretório `/tools` contém:

- **Ferramentas de gerenciamento do Proxmox** - Scripts auxiliares para administração do Proxmox
- **Complementos do Proxmox VE** - Extensões e integrações
- **Scripts de utilitários** - Ferramentas de automação de uso geral

## Estrutura da Documentação

A documentação de ferramentas foca na finalidade, uso e integração com o ecossistema principal.

## Ferramentas Disponíveis

A estrutura de diretórios `/tools` inclui:

### `/tools/pve/`

Ferramentas de gerenciamento e administração do Proxmox VE:

- Utilitários de gerenciamento de contêineres
- Auxiliares de gerenciamento de VMs
- Ferramentas de gerenciamento de armazenamento
- Ferramentas de configuração de rede
- Utilitários de backup e recuperação

### `/tools/addon/`

Complementos e extensões do Proxmox:

- Melhorias na interface web
- Extensões de API
- Módulos de integração
- Scripts personalizados

### `/tools/headers/`

Cabeçalhos e modelos em ASCII para scripts.

## Ferramentas e Scripts Comuns

Exemplos de ferramentas disponíveis:

- **Gerenciamento de contêineres** - Operações em lote em contêineres
- **Provisionamento de VMs** - Configuração automatizada de VMs
- **Automação de backups** - Backups agendados
- **Integração com monitoramento** - Conexão com sistemas de monitoramento
- **Gerenciamento de configuração** - Infraestrutura como código
- **Ferramentas de relatório** - Geração de relatórios e estatísticas

## Pontos de Integração

As ferramentas se integram com:

- **build.func** - Orquestrador principal de contêineres
- **core.func** - Funções utilitárias
- **error_handler.func** - Tratamento de erros
- **tools.func** - Instalação de pacotes

## Contribuindo com Ferramentas

Para contribuir com uma nova ferramenta:

1. Coloque o script no subdiretório `/tools/` apropriado
2. Siga os padrões do projeto:

- Use `#!/usr/bin/env bash`

- Execute o comando `build.func` se necessário

- Trate os erros com `error_handler.func`

3. Documente o uso no script Comentários do cabeçalho
4. Enviar PR

## Tarefas comuns

- **Criar ferramenta de gerenciamento do Proxmox** → Estudar ferramentas existentes
- **Criar complemento** → Seguir as diretrizes de complementos
- **Integração** → Usar build.func e core.func
- **Tratamento de erros** → Usar error_handler.func

---

**Última atualização**: dezembro de 2025
**Mantenedores**: equipe community-scripts
