# Documentação do cloud-init.func

## Visão geral

O arquivo `cloud-init.func` fornece funções de configuração do cloud-init e inicialização de máquinas virtuais Proxmox VE. Ele gerencia dados do usuário, geração de configuração na nuvem e automação da configuração da máquina virtual.

## Finalidade e Casos de Uso

- **Configuração Cloud-Init de VMs**: Gera e aplica configurações Cloud-Init para VMs
- **Geração de Dados do Usuário**: Cria scripts de dados do usuário para inicialização de VMs
- **Cloud-Config**: Gera o arquivo YAML Cloud-Config para provisionamento de VMs
- **Gerenciamento de Chaves SSH**: Configura chaves SSH para acesso às VMs
- **Configuração de Rede**: Configura a rede para VMs
- **Provisionamento Automatizado de VMs**: Conclua a configuração de VMs sem intervenção manual

## Referência Rápida

### Grupos de Funções Principais

- **Núcleo do Cloud-Init**: Gera e aplica configurações Cloud-Init
- **Dados do Usuário**: Cria scripts de inicialização para VMs
- **Configuração SSH**: Implanta chaves SSH automaticamente
- **Configuração de Rede**: Configura a rede durante o provisionamento de VMs
- **Personalização de VMs**: Aplica configurações personalizadas às VMs

### Dependências

- **Externas**: `cloud-init`, `curl`, `qemu-img`
- **Interno**: Utiliza funções de `core.func` e `error_handler.func`

### Pontos de Integração

- Utilizado por: Scripts de criação de VMs (vm/\*.sh)
- Utiliza: Variáveis ​​de ambiente de build.func
- Fornece: Inicialização de VMs e serviços cloud-init

## Arquivos de Documentação

### 📊 [CLOUD_INIT_FUNC_FLOWCHART.md](./CLOUD_INIT_FUNC_FLOWCHART.md)

Fluxos de execução visuais mostrando os fluxos de trabalho de geração do cloud-init e provisionamento de VMs.

### 📚 [CLOUD_INIT_FUNC_FUNCTIONS_REFERENCE.md](./CLOUD_INIT_FUNC_FUNCTIONS_REFERENCE.md)

Referência alfabética completa de todas as funções do cloud-init.

### 📚 ### 💡 [CLOUD_INIT_FUNC_USAGE_EXAMPLES.md](./CLOUD_INIT_FUNC_USAGE_EXAMPLES.md)

Exemplos práticos para configuração e personalização do cloud-init em máquinas virtuais.

### 🔗 [CLOUD_INIT_FUNC_INTEGRATION.md](./CLOUD_INIT_FUNC_INTEGRATION.md)

Como o cloud-init.func se integra à criação de máquinas virtuais e aos fluxos de trabalho do Proxmox.

## Principais Recursos

### Configuração do Cloud-Init

- **Geração de Dados do Usuário**: Crie scripts de inicialização personalizados
- **YAML do Cloud-Config**: Gere um arquivo de configuração padrão do Cloud-Config
- **Chaves SSH**: Implante chaves públicas automaticamente
- **Instalação de Pacotes**: Instale pacotes durante a inicialização da VM
- **Comandos Personalizados**: Execute comandos arbitrários na primeira inicialização

### Configuração de Rede da VM

- **Configuração DHCP**: Configure o DHCP para atribuição automática de IPs
- **Configuração de IP Estático**: Configure endereços IP estáticos
- **Suporte a IPv6**: Habilite IPv6 nas VMs
- **Configuração DNS**: Defina servidores DNS para a VM
- **Regras de Firewall**: Configuração básica de firewall

### Recursos de Segurança

- **Injeção de Chave SSH**: Implante chaves SSH durante a criação da VM
- **Desabilitar Senhas**: Desabilite a autenticação por senha
- **Configuração do Sudoers**: Configure o acesso sudo
- **Gerenciamento de Usuários**: Crie e configure usuários

## Categorias de Funções

### 🔹 Núcleo do Cloud-Init Funções

- `generate_cloud_init()` - Cria a configuração do cloud-init
- `generate_user_data()` - Gera o script de dados do usuário
- `apply_cloud_init()` - Aplica o cloud-init à VM
- `validate_cloud_init()` - Valida a sintaxe do cloud-config

### 🔹 Funções de SSH e Segurança

- `setup_ssh_keys()` - Implanta chaves públicas SSH
- `setup_sudo()` - Configura o sudoers
- `create_user()` - Cria uma nova conta de usuário
- `disable_password_auth()` - Desativa o login com senha

### 🔹 Funções de Configuração de Rede

- `setup_dhcp()` - Configura a rede DHCP
- `setup_static_ip()` - Configura um IP estático
- `setup_dns()` - Configura os servidores DNS
- `setup_ipv6()` - Habilita o suporte a IPv6

### 🔹 Funções de Personalização de VMs

- `install_packages()` - Instala pacotes durante a inicialização
- `run_custom_commands()` - Executa scripts personalizados
- `configure_hostname()` - Define o nome do host da VM
- `configure_timezone()` - Define o fuso horário da VM

## Fluxo de Trabalho do Cloud-Init

```
VM Created
    ↓
cloud-init (system) boot phase
    ↓
User-Data Script Execution
    ↓
├─ Install packages
├─ Deploy SSH keys
├─ Configure network
└─ Create users
    ↓
cloud-init config phase
    ↓
Apply cloud-config settings
    ↓
cloud-init final phase
    ↓
VM Ready for Use
```

## Padrões de Uso Comuns

### Configuração Básica de VM com Cloud-Init

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

# Generate cloud-init configuration
cat > cloud-init.yaml <<EOF
#cloud-config
hostname: myvm
timezone: UTC

packages:
  - curl
  - wget
  - git

users:
  - name: ubuntu
    ssh_authorized_keys:
      - ssh-rsa AAAAB3...
    sudo: ALL=(ALL) NOPASSWD:ALL

bootcmd:
  - echo "VM initializing..."

runcmd:
  - apt-get update
  - apt-get upgrade -y
EOF

# Apply to VM
qm set VMID --cicustom local:snippets/cloud-init.yaml
```

### Com Implantação de Chave SSH

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

# Get SSH public key
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

# Generate cloud-init with SSH key
generate_user_data > user-data.txt

# Inject SSH key
setup_ssh_keys "$VMID" "$SSH_KEY"

# Create VM with cloud-init
qm create $VMID ... --cicustom local:snippets/user-data
```

### Configuração de Rede

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

# Static IP setup
setup_static_ip "192.168.1.100" "255.255.255.0" "192.168.1.1"

# DNS configuration
setup_dns "8.8.8.8 8.8.4.4"

# IPv6 support
setup_ipv6
```

## Melhores Práticas

### ✅ FAÇA

- Valide a sintaxe do cloud-config antes de aplicar
- Use o cloud-init para configuração automatizada
- Implante chaves SSH para acesso seguro
- Teste a configuração do cloud-init em um ambiente de não produção primeiro
- Use DHCP para Implantação de VMs mais fácil
- Documentar configurações personalizadas do cloud-init
- Controle de versão de modelos do cloud-init

### ❌ NÃO FAÇA

- Usar chaves ou senhas SSH fracas
- Deixar a autenticação por senha SSH habilitada
- Inserir credenciais diretamente no cloud-init
- Ignorar a validação do cloud-config
- Usar fontes não confiáveis ​​do cloud-init
- Esquecer de definir o fuso horário nas VMs
- Misturar versões do cloud-init

## Formato do Cloud-Config

### Exemplo de Cloud-Config

```yaml
#cloud-config
# This is a comment

# System configuration
hostname: myvm
timezone: UTC
package_upgrade: true

# Packages to install
packages:
  - curl
  - wget
  - git
  - build-essential

# SSH keys for users
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC...

# Users to create
users:
  - name: ubuntu
    home: /home/ubuntu
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    ssh_authorized_keys:
      - ssh-rsa AAAAB3...

# Commands to run on boot
runcmd:
  - apt-get update
  - apt-get upgrade -y
  - systemctl restart ssh

# Files to create
write_files:
  - path: /etc/profile.d/custom.sh
    content: |
      export CUSTOM_VAR="value"
```

## Configuração de Rede da VM

### Configuração DHCP

```bash
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: true
```

### Configuração de IP Estático

```bash
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

## Solução de Problemas

### "Configuração do Cloud-Init Não Aplicada"

```bash
# Check cloud-init status in VM
cloud-init status
cloud-init status --long

# View cloud-init logs
tail /var/log/cloud-init.log
```

### "Chaves SSH Não Implantadas"

```bash
# Verify SSH key in cloud-config
grep ssh_authorized_keys user-data.txt

# Check permissions
ls -la ~/.ssh/authorized_keys
```

### "Rede Não Configurado"

```bash
# Check network configuration
ip addr show
ip route show

# View netplan (if used)
cat /etc/netplan/*.yaml
```

### "Falha na instalação de pacotes"

```bash
# Check cloud-init package log
tail /var/log/cloud-init-output.log

# Manual package installation
apt-get update && apt-get install -y package-name
```

## Documentação relacionada

- **[install.func/](../install.func/)** - Instalação de contêiner (fluxo de trabalho semelhante)
- **[core.func/](../core.func/)** - Funções utilitárias
- **[error_handler.func/](../error_handler.func/)** - Tratamento de erros
- **[UPDATED_APP-install.md](../../UPDATED_APP-install.md)** - Guia de configuração do aplicativo
- **Documentação do Proxmox**: https://pve.proxmox.com/wiki/Cloud-Init

## Atualizações recentes

### Versão 2.0 (dezembro de 2025)

- ✅ Cloud-init aprimorado Validação
- ✅ Implantação de chave SSH aprimorada
- ✅ Melhor suporte à configuração de rede
- ✅ Adicionado suporte a IPv6
- ✅ Configuração simplificada de usuários e pacotes

---

**Última atualização**: dezembro de 2025
**Mantenedores**: Equipe community-scripts
**Licença**: MIT
