# Documentação do build.func

## Visão geral

Este diretório contém a documentação completa do script `build.func`, que é o script principal de orquestração para a criação de contêineres LXC do Proxmox no projeto Community Scripts.

## Arquivos de documentação

### 🎛️ [BUILD_FUNC_ADVANCED_SETTINGS.md](./BUILD_FUNC_ADVANCED_SETTINGS.md)

Referência completa para o assistente de Configurações Avançadas de 28 etapas, incluindo todas as opções configuráveis ​​e seu comportamento de herança.

**Conteúdo:**

- Explicação de todas as 28 etapas do assistente
- Herança de valores padrão
- Matriz de recursos (quando habilitar cada recurso)
- Formato de resumo de confirmação
- Exemplos de uso

### 📊 [BUILD_FUNC_FLOWCHART.md](./BUILD_FUNC_FLOWCHART.md)

Fluxograma visual em ASCII mostrando o fluxo de execução principal, árvores de decisão e pontos de decisão importantes no script build.func.

**Conteúdo:**

- Diagrama do fluxo de execução principal
- Fluxos de seleção do modo de instalação
- Fluxo de trabalho de seleção de armazenamento
- Lógica de decisão de passagem direta da GPU
- Cadeia de precedência de variáveis
- Fluxo de tratamento de erros
- Pontos de integração

### 🔧 [BUILD_FUNC_ENVIRONMENT_VARIABLES.md](./BUILD_FUNC_ENVIRONMENT_VARIABLES.md)

Referência completa de todas as variáveis ​​de ambiente usadas em build.func, organizadas por categoria e contexto de uso.

**Conteúdo:**

- Variáveis ​​principais do contêiner
- Variáveis ​​do sistema operacional
- Variáveis ​​de configuração de recursos
- Variáveis ​​de configuração de rede
- Variáveis ​​de configuração de armazenamento
- Sinalizadores de recursos
- Variáveis ​​de passagem de GPU
- Variáveis ​​de API e diagnóstico
- Variáveis ​​de persistência de configurações
- Cadeia de precedência de variáveis
- Variáveis ​​críticas para uso não interativo
- Combinações comuns de variáveis

### 📚 [BUILD_FUNC_FUNCTIONS_REFERENCE.md](./BUILD_FUNC_FUNCTIONS_REFERENCE.md)

Referência alfabética de funções com descrições detalhadas, parâmetros, dependências e informações de uso.

**Conteúdo:**

- Funções de inicialização
- Funções de interface do usuário e menu
- Funções de armazenamento
- Funções de criação de contêineres
- Funções de GPU e hardware
- Funções de persistência de configurações
- Funções utilitárias
- Fluxo de chamadas de função
- Dependências de funções
- Exemplos de uso de funções
- Tratamento de erros de função

### 🔄 [BUILD_FUNC_EXECUTION_FLOWS.md](./BUILD_FUNC_EXECUTION_FLOWS.md)

Fluxos de execução detalhados para diferentes modos e cenários de instalação, incluindo precedência de variáveis ​​e árvores de decisão.

**Conteúdo:**

- Fluxo de instalação padrão
- Fluxo de instalação avançado
- Fluxo de configurações padrão
- Fluxo de configurações padrão do aplicativo
- Cadeia de precedência de variáveis
- Lógica de seleção de armazenamento
- Fluxo de passagem de GPU
- Fluxo de configuração de rede
- Fluxo de criação de contêiner
- Fluxos de tratamento de erros
- Fluxos de integração
- Considerações de desempenho

### 🏗️ [BUILD_FUNC_ARCHITECTURE.md](./BUILD_FUNC_ARCHITECTURE.md)

Visão geral da arquitetura de alto nível, incluindo dependências de módulos, fluxo de dados, pontos de integração e arquitetura do sistema.

**Conteúdo:**

- Diagrama de arquitetura de alto nível
- Dependências de módulos
- Arquitetura de fluxo de dados
- Arquitetura de integração
- Componentes da arquitetura do sistema
- Componentes da interface do usuário
- Arquitetura de segurança
- Arquitetura de desempenho
- Arquitetura de implantação
- Arquitetura de manutenção
- Considerações sobre arquitetura futura

### 💡 [BUILD_FUNC_USAGE_EXAMPLES.md](./BUILD_FUNC_USAGE_EXAMPLES.md)

Exemplos práticos de uso que abrangem cenários comuns, exemplos de CLI e combinações de variáveis ​​de ambiente.

**Conteúdo:**

- Exemplos básicos de uso
- Exemplos silenciosos/não interativos
- Exemplos de configuração de rede
- Exemplos de configuração de armazenamento
- Exemplos de configuração de recursos
- Exemplos de persistência de configurações
- Exemplos de tratamento de erros
- Exemplos de integração
- Melhores práticas

## Guia de Início Rápido

### Para Novos Usuários

1. Comece com [BUILD_FUNC_FLOWCHART.md](./BUILD_FUNC_FLOWCHART.md) para entender o fluxo geral
2. Consulte [BUILD_FUNC_ENVIRONMENT_VARIABLES.md](./BUILD_FUNC_ENVIRONMENT_VARIABLES.md) para opções de configuração
3. Siga os exemplos em [BUILD_FUNC_USAGE_EXAMPLES.md](./BUILD_FUNC_USAGE_EXAMPLES.md)

### Para Desenvolvedores

1. Leia [BUILD_FUNC_ARCHITECTURE.md](./BUILD_FUNC_ARCHITECTURE.md) para uma visão geral do sistema.
2. Estude [BUILD_FUNC_FUNCTIONS_REFERENCE.md](./BUILD_FUNC_FUNCTIONS_REFERENCE.md) para detalhes da função.
3. Revise [BUILD_FUNC_EXECUTION_FLOWS.md](./BUILD_FUNC_EXECUTION_FLOWS.md) para detalhes da implementação.

### Para Administradores de Sistemas

1. Consulte o arquivo [BUILD_FUNC_USAGE_EXAMPLES.md](./BUILD_FUNC_USAGE_EXAMPLES.md) para cenários de implantação.
2. Consulte o arquivo [BUILD_FUNC_ENVIRONMENT_VARIABLES.md](./BUILD_FUNC_ENVIRONMENT_VARIABLES.md) para gerenciamento de configuração.
3. Verifique o arquivo [BUILD_FUNC_ARCHITECTURE.md](./BUILD_FUNC_ARCHITECTURE.md) para considerações de segurança e desempenho.

## Conceitos-chave

### Precedência de Variáveis

As variáveis ​​são resolvidas nesta ordem (da maior para a menor prioridade):

1. Variáveis ​​de ambiente fixas (definidas antes da execução do script)
2. Arquivo .vars específico do aplicativo (`/usr/local/community-scripts/defaults/<app>.vars`)
3. Arquivo default.vars global (`/usr/local/community-scripts/default.vars`)
4. Valores padrão integrados (definidos na função `base_settings()`)

### Modos de Instalação

- **Instalação Padrão**: Usa os valores padrão integrados, com o mínimo de avisos
- **Instalação Avançada**: Configuração interativa completa via whiptail
- **Meus Valores Padrão**: Carrega do arquivo global default.vars
- **Valores Padrão do Aplicativo**: Carrega do arquivo .vars específico do aplicativo

### Lógica de Seleção de Armazenamento

1. Se houver apenas um armazenamento disponível para o tipo de conteúdo → seleção automática
2. Se pré-selecionado por meio de variáveis ​​de ambiente → validar e usar
3. Caso contrário → solicitar confirmação ao usuário via whiptail

### Fluxo de Passagem de GPU

1. Detectar hardware (Intel/AMD/NVIDIA)
2. Verificar se o aplicativo está na lista GPU_APPS OU se o contêiner possui privilégios
3. Seleção automática se houver apenas um tipo de GPU, solicitar confirmação se houver várias
4. Configurar `/etc/pve/lxc/<ctid>.conf` com as entradas de dispositivo corretas
5. Corrija os GIDs após a criação para corresponder aos grupos de vídeo/renderização do contêiner

## Casos de Uso Comuns

### Criação Básica de Contêiner

```bash
export APP="plex"
export CTID="100"
export var_hostname="plex-server"
export var_os="debian"
export var_version="12"
export var_cpu="4"
export var_ram="4096"
export var_disk="20"
export var_net="vmbr0"
export var_gateway="192.168.1.1"
export var_ip="192.168.1.100"
export var_template_storage="local"
export var_container_storage="local"

source build.func
```

### Passagem de GPU

```bash
export APP="jellyfin"
export CTID="101"
export var_hostname="jellyfin-server"
export var_os="debian"
export var_version="12"
export var_cpu="8"
export var_ram="16384"
export var_disk="30"
export var_net="vmbr0"
export var_gateway="192.168.1.1"
export var_ip="192.168.1.101"
export var_template_storage="local"
export var_container_storage="local"
export GPU_APPS="jellyfin"
export var_gpu="nvidia"
export ENABLE_PRIVILEGED="true"

source build.func
```

### Implantação Silenciosa/Não Interativa

```bash
#!/bin/bash
# Automated deployment
export APP="nginx"
export CTID="102"
export var_hostname="nginx-proxy"
export var_os="alpine"
export var_version="3.18"
export var_cpu="1"
export var_ram="512"
export var_disk="2"
export var_net="vmbr0"
export var_gateway="192.168.1.1"
export var_ip="192.168.1.102"
export var_template_storage="local"
export var_container_storage="local"
export ENABLE_UNPRIVILEGED="true"

source build.func
```

## Solução de Problemas

### Problemas Comuns

1. **Falha na criação do contêiner**: Verifique a disponibilidade de recursos e a validade da configuração
2. **Erros de armazenamento**: Verifique se o armazenamento existe e suporta os tipos de conteúdo necessários
3. **Erros de rede**: Valide a configuração de rede e a disponibilidade do endereço IP
4. **Problemas de passagem de GPU**: Verifique a detecção de hardware e os privilégios do contêiner
5. **Erros de permissão**: Verifique as permissões do usuário e os privilégios do contêiner

### Modo de Depuração

Ative a saída detalhada para Depuração:

```bash
export VERBOSE="true"
export DIAGNOSTICS="true"
source build.func
```

### Arquivos de Log

Verifique os logs do sistema para obter informações detalhadas sobre erros:

- `/var/log/syslog`
- `/var/log/pve/lxc/<ctid>.log`
- Logs específicos do contêiner

## Contribuições

Ao contribuir para a documentação do build.func:

1. Atualize os arquivos de documentação relevantes
2. Adicione exemplos para novos recursos
3. Atualize os diagramas de arquitetura, se necessário
4. Teste todos os exemplos antes de enviar
5. Siga o estilo de documentação existente

## Documentação Relacionada

- [README Principal](../../README.md) - Visão geral do projeto
- [Guia de Instalação](../../install/) - Scripts de instalação
- [Modelos de Contêiner](../../ct/) - Modelos de contêiner
- [Ferramentas](../../tools/) - Ferramentas e utilitários adicionais

## Suporte

Para problemas e Perguntas:

1. Consulte esta documentação primeiro
2. Consulte a [seção de solução de problemas](#troubleshooting)
3. Verifique os problemas existentes no repositório do projeto
4. Crie um novo problema com informações detalhadas

---

_Última atualização: $(date)_
_Versão da documentação: 1.0_
