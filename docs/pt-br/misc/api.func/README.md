# Documentação do api.func

## Visão geral

O arquivo `api.func` fornece integração com a API do Proxmox e funcionalidade de geração de relatórios de diagnóstico para o projeto Community Scripts. Ele gerencia a comunicação com a API, o relatório de erros e as atualizações de status da API community-scripts.org.

## Finalidade e Casos de Uso

- **Comunicação com a API**: Enviar dados de instalação e status para a API do community-scripts.org
- **Relatórios de Diagnóstico**: Relatar o progresso e os erros da instalação para fins de análise
- **Descrição de Erros**: Fornecer explicações detalhadas dos códigos de erro
- **Atualizações de Status**: Rastrear o status de sucesso/falha da instalação
- **Análise**: Contribuir com dados de uso anônimos para aprimoramento do projeto

## Referência Rápida

### Grupos de Funções Principais

- **Tratamento de Erros**: `get_error_description()` - Converter códigos de saída em mensagens legíveis
- **Comunicação com a API**: `post_to_api()`, `post_to_api_vm()` - Enviar dados de instalação
- **Atualizações de Status**: `post_update_to_api()` - Relatar o status de conclusão da instalação

### Dependências

- **Externas**: Comando `curl` para requisições HTTP
- **Internas**: Utiliza variáveis ​​de ambiente de outros scripts

### Pontos de Integração

- Utilizado por: Todas as instalações Scripts para geração de relatórios de diagnóstico
- Utiliza: Variáveis ​​de ambiente de build.func e outros scripts
- Fornece: Serviços de comunicação com a API e geração de relatórios de erros

## Arquivos de Documentação

### 📊 [API_FLOWCHART.md](./API_FLOWCHART.md)

Fluxos de execução visuais mostrando os processos de comunicação com a API e o tratamento de erros.

### 📚 [API_FUNCTIONS_REFERENCE.md](./API_FUNCTIONS_REFERENCE.md)

Referência alfabética completa de todas as funções com parâmetros, dependências e detalhes de uso.

### 💡 [API_USAGE_EXAMPLES.md](./API_USAGE_EXAMPLES.md)

Exemplos práticos mostrando como usar as funções da API e padrões comuns.

### 💡 ### 🔗 [API_INTEGRATION.md](./API_INTEGRATION.md)

Como a api.func se integra com outros componentes e fornece serviços de API.

## Principais Recursos

### Descrições de Códigos de Erro

- **Cobertura Abrangente**: Mais de 50 códigos de erro com explicações detalhadas
- **Erros Específicos do LXC**: Erros de criação e gerenciamento de contêineres
- **Erros de Sistema**: Erros gerais de sistema e rede
- **Erros de Sinalização**: Erros de encerramento de processos e de sinalização

### Comunicação com a API

- **Relatórios do LXC**: Envia dados de instalação de contêineres LXC
- **Relatórios da VM**: Envia dados de instalação de máquinas virtuais
- **Atualizações de Status**: Relata o sucesso/falha da instalação
- **Dados de Diagnóstico**: Análises de uso anônimas

### Integração com Diagnóstico

- **Relatórios Opcionais**: Envia dados somente quando o diagnóstico está ativado
- **Respeito à Privacidade**: Respeita as configurações de privacidade do usuário
- **Rastreamento de Erros**: Rastreia erros de instalação para melhorias
- **Análises de Uso**: Contribui para as estatísticas do projeto

## Padrões de Uso Comuns

### API Básica Configuração

```bash
#!/usr/bin/env bash
# Basic API setup

source api.func

# Set up diagnostic reporting
export DIAGNOSTICS="yes"
export RANDOM_UUID="$(uuidgen)"

# Report installation start
post_to_api
```

### Relatório de Erros

```bash
#!/usr/bin/env bash
source api.func

# Get error description
error_msg=$(get_error_description 127)
echo "Error 127: $error_msg"
# Output: Error 127: Command not found: Incorrect path or missing dependency.
```

### Atualizações de Status

```bash
#!/usr/bin/env bash
source api.func

# Report successful installation
post_update_to_api "success" 0

# Report failed installation
post_update_to_api "failed" 127
```

## Variáveis ​​de Ambiente

### Variáveis ​​Obrigatórias

- `DIAGNOSTICS`: Habilitar/desabilitar o relatório de diagnóstico ("sim"/"não")
- `RANDOM_UUID`: Identificador único para rastreamento

### Variáveis ​​Opcionais

- `CT_TYPE`: Tipo de contêiner (1 para LXC, 2 para VM)
- `DISK_SIZE`: Tamanho do disco em GB
- `CORE_COUNT`: Número de núcleos da CPU
- `RAM_SIZE`: Tamanho da RAM em MB
- `var_os`: Tipo de sistema operacional
- `var_version`: Versão do SO
- `DISABLEIP6`: Configuração para desabilitar IPv6
- `NSAPP`: Nome do aplicativo de namespace
- `METHOD`: Instalação Método

### Variáveis ​​Internas

- `POST_UPDATE_DONE`: Impede atualizações de status duplicadas
- `API_URL`: Endpoint da API de scripts da comunidade
- `JSON_PAYLOAD`: Payload da requisição à API
- `RESPONSE`: Resposta da API

## Categorias de Códigos de Erro

### Erros Gerais do Sistema

- **0-9**: Erros básicos do sistema
- **18, 22, 28, 35**: Erros de rede e E/S
- **56, 60**: Erros TLS/SSL
- **125-128**: Erros de execução de comando
- **129-143**: Erros de sinal
- **152**: Erros de limite de recurso
- **255**: Erros críticos desconhecidos

### Erros Específicos do LXC

- **100-101**: Erros de instalação do LXC
- **200-209**: Erros de criação e gerenciamento do LXC

### Docker Erros

- **125**: Erros ao iniciar o contêiner Docker

## Boas Práticas

### Relatórios de Diagnóstico

1. Sempre verifique se os diagnósticos estão ativados
2. Respeite as configurações de privacidade do usuário
3. Use identificadores exclusivos para rastreamento
4. Relate casos de sucesso e falha

### Tratamento de Erros

1. Use códigos de erro apropriados
2. Forneça descrições de erro significativas
3. Lide com falhas de comunicação da API de forma adequada
4. Não bloqueie a instalação em caso de falhas na API

### Uso da API

1. Verificar a disponibilidade do curl
2. Lidar com falhas de rede de forma adequada
3. Usar os métodos HTTP apropriados
4. Incluir todos os dados necessários

## Solução de Problemas

### Problemas Comuns

1. **Falha na comunicação com a API**: Verificar a conectividade de rede e a disponibilidade do curl
2. **Diagnóstico não funciona**: Verificar a configuração DIAGNOSTICS e RANDOM_UUID
3. **Descrições de erro ausentes**: Verificar a cobertura do código de erro
4. **Atualizações duplicadas**: POST_UPDATE_DONE impede duplicatas

### Modo de Depuração

Habilitar relatório de diagnóstico para depuração:

```bash
export DIAGNOSTICS="yes"
export RANDOM_UUID="$(uuidgen)"
```

### Teste da API

Testar a comunicação com a API:

```bash
source api.func
export DIAGNOSTICS="yes"
export RANDOM_UUID="test-$(date +%s)"
post_to_api
```

## Documentação Relacionada

- [core.func](../core.func/) - Utilitários principais e tratamento de erros
- [error_handler.func](../error_handler.func/) - Utilitários para tratamento de erros
- [build.func](../build.func/) - Criação de contêineres com integração de API
- [tools.func](../tools.func/) - Utilitários estendidos com integração de API

---

_Esta documentação abrange o arquivo api.func, que fornece comunicação com a API e geração de relatórios de diagnóstico para todos os scripts da comunidade Proxmox._
