# Guias de Configuração e Implantação

Este diretório contém guias completos para configurar e implantar contêineres Proxmox VE usando scripts da comunidade.

## 📚 Guias Disponíveis

### [Referência de Configuração](CONFIGURATION_REFERENCE.md)

Referência completa para todas as opções de configuração, variáveis ​​de ambiente e configurações avançadas disponíveis no sistema de compilação.

**Tópicos abordados:**

- Especificações do contêiner (CPU, RAM, Disco)
- Configuração de rede (IPv4/IPv6, VLAN, MTU)
- Seleção e gerenciamento de armazenamento
- Modos e recursos de privilégio
- Seleção e versões do sistema operacional

### [Guia de Configurações Padrão do Sistema](DEFAULTS_SYSTEM_GUIDE.md)

Entendendo e personalizando as configurações padrão para implantações de contêineres.

**Tópicos abordados:**

- Configurações padrão do sistema
- Substituições por script
- Configuração personalizada de padrões
- Precedência de variáveis ​​de ambiente

### [Implantações automatizadas](UNATTENDED_DEPLOYMENTS.md)

Automatizando implantações de contêineres sem interação do usuário.

**Tópicos abordados:**

- Configuração de variáveis ​​de ambiente
- Implantações em lote
- Integração com CI/CD
- Instalações automatizadas
- Modelos pré-configurados

## 🔗 Documentação relacionada

- **[Guia de Scripts do CT](../ct/)** - Estrutura e uso de scripts de contêiner
- **[Guia de Scripts de Instalação](../install/)** - Funcionamento interno dos scripts de instalação
- **[Documentação da API](../api/)** - Integração e endpoints da API
- **[Funções de Build](../misc/build.func/)** - Referência de funções do sistema de build
- **[Funções de Ferramentas](../misc/tools.func/)** - Referência de funções de utilitários

## 💡 Início rápido

Para a maioria dos usuários, comece com o guia de **Implantações Autônomas** para aprender como automatizar suas configurações de contêiner.

Para opções de configuração avançadas, consulte a **Referência de Configuração**.

## 🤝 Contribuindo

Se você quiser melhorar estes guias ou adicionar novos, consulte nosso [Guia de Contribuição](../contribution/).
