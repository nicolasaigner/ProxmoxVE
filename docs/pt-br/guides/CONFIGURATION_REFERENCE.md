# Referência de Configuração

**Referência completa para todas as variáveis ​​e opções de configuração em scripts da comunidade para Proxmox VE.**

---

## Sumário

1. [Convenção de Nomenclatura de Variáveis](#variable-naming-convention)
2. [Referência Completa de Variáveis](#complete-variable-reference)
3. [Configuração de Recursos](#resource-configuration)
4. [Configuração de Rede](#network-configuration)
5. [Configuração IPv6](#ipv6-configuration)
6. [Configuração SSH](#ssh-configuration)
7. [Recursos de Contêineres](#container-features)
8. [Configuração de Armazenamento](#storage-configuration)
9. [Configurações de Segurança](#security-settings)
10. [Opções Avançadas](#advanced-options)
11. [Referência Rápida Tabela](#quick-reference-table)

---

## Convenção de Nomenclatura de Variáveis

Todas as variáveis ​​de configuração seguem um padrão consistente:

```
var_<setting>=<value>
```

**Regras:**

- ✅ Sempre começa com `var_`
- ✅ Somente letras minúsculas
- ✅ Sublinhados para separação de palavras
- ✅ Sem espaços ao redor de `=`
- ✅ Os valores podem ser colocados entre aspas, se necessário

**Exemplos:**

```bash
# ✓ Correct
var_cpu=4
var_hostname=myserver
var_ssh_authorized_key=ssh-rsa AAAA...

# ✗ Wrong
CPU=4                    # Missing var_ prefix
var_CPU=4                # Uppercase not allowed
var_cpu = 4              # Spaces around =
var-cpu=4                # Hyphens not allowed
```

---

## Referência Completa de Variáveis

### var_unprivileged

**Tipo:** Booleano (0 ou 1) **Padrão:** `1` (sem privilégios) **Descrição:** Determina se o contêiner é executado sem privilégios (recomendado) ou com privilégios.

```bash
var_unprivileged=1    # Unprivileged (safer, recommended)
var_unprivileged=0    # Privileged (less secure, more features)
```

**Quando usar privilégios (0):**

- Acesso ao hardware necessário
- Determinados módulos do kernel necessários
- Aplicativos legados
- Virtualização aninhada com todos os recursos

**Impacto na segurança:**

- Sem privilégios: O usuário root do contêiner é mapeado para um usuário sem privilégios no host
- Com privilégios: O usuário root do contêiner é igual ao usuário root do host (risco de segurança)

---

### var_cpu

**Tipo:** Inteiro **Padrão:** Varia de acordo com o aplicativo (geralmente de 1 a 4) **Intervalo:** De 1 até a quantidade de CPUs do host **Descrição:** Número de núcleos de CPU alocados ao contêiner.

```bash
var_cpu=1     # Single core (minimal)
var_cpu=2     # Dual core (typical)
var_cpu=4     # Quad core (recommended for apps)
var_cpu=8     # High performance
```

**Melhores Práticas:**

- Comece com 2 núcleos para a maioria das aplicações
- Monitore o uso com `pct exec <id> -- htop`
- Pode ser alterado após a criação
- Considere a quantidade de CPUs do host (não aloque em excesso)

---

### var_ram

**Tipo:** Inteiro (MB) **Padrão:** Varia de acordo com a aplicação (geralmente de 512 a 2048) **Intervalo:** 512 MB até a RAM do host **Descrição:** Quantidade de RAM em megabytes.

```bash
var_ram=512      # 512 MB (minimal)
var_ram=1024     # 1 GB (typical)
var_ram=2048     # 2 GB (comfortable)
var_ram=4096     # 4 GB (recommended for databases)
var_ram=8192     # 8 GB (high memory apps)
```

**Guia de Conversão:**

```
512 MB   = 0.5 GB
1024 MB  = 1 GB
2048 MB  = 2 GB
4096 MB  = 4 GB
8192 MB  = 8 GB
16384 MB = 16 GB
```

**Melhores Práticas:**

- Mínimo de 512 MB para Linux básico
- 1 GB para aplicações típicas
- 2-4 GB para servidores web e bancos de dados
- Monitore com `free -h` dentro do contêiner

---

### var_disk

**Tipo:** Inteiro (GB) **Padrão:** Varia de acordo com a aplicação (geralmente de 2 a 8) **Intervalo:** 0,001 GB até a capacidade de armazenamento **Descrição:** Tamanho do disco raiz em gigabytes.

\*\* ```bash var_disk=2 # 2 GB (minimal OS only) var_disk=4 # 4 GB (typical) var_disk=8 # 8 GB (comfortable) var_disk=20 # 20 GB (recommended for apps) var_disk=50 # 50 GB (large applications)
var_disk=100 # 100 GB (databases, media)

```

**Observações importantes:**
- Pode ser expandido após a criação (não reduzido)
- O espaço real depende do tipo de armazenamento
- Provisionamento dinâmico (thin provisioning) é compatível com a maioria dos armazenamentos
- Planeje para logs, dados e atualizações

**Tamanhos recomendados por caso de uso:**
```

Basic Linux container: 4 GB Web server (Nginx/Apache): 8 GB Application server: 10-20 GB Database server: 20-50 GB Docker host: 30-100 GB Media server: 100+ GB

````

---

### var_hostname

**Tipo:** String
**Padrão:** Nome do aplicativo
**Comprimento máximo:** 63 caracteres
**Descrição:** Nome do host do contêiner (formato FQDN permitido).

```bash
var_hostname=myserver
var_hostname=pihole
var_hostname=docker-01
var_hostname=web.example.com
````

**Regras:**

- Letras minúsculas, números e hífens
- Não pode começar nem terminar com hífen
- Sublinhados não são permitidos
- Espaços não são permitidos

**Boas Práticas:**

```bash
# ✓ Good
var_hostname=web-server
var_hostname=db-primary
var_hostname=app.domain.com

# ✗ Avoid
var_hostname=Web_Server    # Uppercase, underscore
var_hostname=-server       # Starts with hyphen
var_hostname=my server     # Contains space
```

---

### var_brg

**Tipo:** String **Padrão:** `vmbr0` **Descrição:** Interface de ponte de rede.

```bash
var_brg=vmbr0    # Default Proxmox bridge
var_brg=vmbr1    # Custom bridge
var_brg=vmbr2    # Isolated network
```

**Configurações comuns:**

```
vmbr0 → Main network (LAN)
vmbr1 → Guest network
vmbr2 → DMZ
vmbr3 → Management
vmbr4 → Storage network
```

**Verificar pontes disponíveis:**

```bash
ip link show | grep vmbr
# or
brctl show
```

---

### var_net

**Tipo:** String **Opções:** `dhcp` ou `static` **Padrão:** `dhcp` **Descrição:** Método de configuração de rede IPv4.

```bash
var_net=dhcp     # Automatic IP via DHCP
var_net=static   # Manual IP configuration
```

**Modo DHCP:**

- Atribuição automática de IP
- Configuração fácil
- Ideal para desenvolvimento
- Requer um servidor DHCP na rede

**Modo Estático:**

- Endereço IP fixo
- Requer configuração de gateway
- Melhor para servidores
- Configure através das configurações avançadas ou após a criação

---

### var_gateway

**Tipo:** Endereço IPv4 **Padrão:** Detectado automaticamente pelo host **Descrição:** Endereço IP do gateway de rede.

```bash
var_gateway=192.168.1.1
var_gateway=10.0.0.1
var_gateway=172.16.0.1
```

**Detecção automática:** Se não for especificado, o sistema detecta o gateway a partir do host:

```bash
ip route | grep default
```

**Quando especificar:**

- Vários gateways disponíveis
- Configuração de roteamento personalizada
- Segmento de rede diferente

---

### var_vlan

**Tipo:** Inteiro **Intervalo:** 1-4094 **Padrão:** Nenhum **Descrição:** Tag VLAN para isolamento de rede.

```bash
var_vlan=10      # VLAN 10
var_vlan=100     # VLAN 100
var_vlan=200     # VLAN 200
```

**Esquemas de VLAN comuns:**

```
VLAN 10  → Management
VLAN 20  → Servers
VLAN 30  → Desktops
VLAN 40  → Guest WiFi
VLAN 50  → IoT devices
VLAN 99  → DMZ
```

**Requisitos:**

- O switch deve suportar VLANs
- Bridge Proxmox configurada para reconhecimento de VLAN
- Gateway na mesma VLAN

---

### var_mtu

**Tipo:** Inteiro **Padrão:** `1500` **Intervalo:** 68-9000 **Descrição:** Tamanho máximo da Unidade de Transmissão.

```bash
var_mtu=1500     # Standard Ethernet
var_mtu=1492     # PPPoE
var_mtu=9000     # Jumbo frames
```

**Valores comuns:**

```
1500 → Standard Ethernet (default)
1492 → PPPoE connections
1400 → Some VPN setups
9000 → Jumbo frames (10GbE networks)
```

**Quando alterar:**

- Jumbo frames para melhor desempenho em 10GbE
- Conexões de internet PPPoE
- Túneis VPN com sobrecarga
- Requisitos específicos de rede

---

### var_mac

**Tipo:** Endereço MAC **Formato:** `XX:XX:XX:XX:XX:XX` **Padrão:** Gerado automaticamente **Descrição:** Endereço MAC do contêiner.

```bash
var_mac=02:00:00:00:00:01
var_mac=DE:AD:BE:EF:00:01
```

**Quando especificar:**

- Licenciamento baseado em MAC
- Reservas DHCP estáticas
- Controle de acesso à rede
- Clonagem de configurações

**Melhores práticas:**

- Use endereços administrados localmente (segundo bit definido)
- Comece com `02:`, `06:`, `0A:`, `0E:`
- Evite OUIs de fornecedores
- Documente MACs personalizados

---

### var_ipv6_method

**Tipo:** String **Opções:** `auto`, `dhcp`, `static`, `none`, `disable` **Padrão:** `none` **Descrição:** Método de configuração IPv6.

```bash
var_ipv6_method=auto      # SLAAC (auto-configuration)
var_ipv6_method=dhcp      # DHCPv6
var_ipv6_method=static    # Manual configuration
var_ipv6_method=none      # IPv6 enabled but not configured
var_ipv6_method=disable   # IPv6 completely disabled
```

**Opções Detalhadas:**

**auto (SLAAC)**

- Autoconfiguração de Endereços sem Estado
- Anúncios de roteador
- Não requer servidor DHCPv6
- Recomendado na maioria dos casos

**dhcp (DHCPv6)**

- Configuração com Estado
- Requer servidor DHCPv6
- Mais controle sobre o endereçamento

**static**

- Endereço IPv6 manual
- Gateway manual
- Controle total

**none**

- Pilha IPv6 ativa
- Nenhum endereço configurado
- Pode ser configurado posteriormente

**disable**

- IPv6 completamente desativado no nível do kernel
- Usar quando o IPv6 causar problemas
- Define `net.ipv6.conf.all.disable_ipv6=1`

---

### var_ns

**Tipo:** Endereço IP **Padrão:** Auto (do host) **Descrição:** IP do servidor de nomes DNS.

```bash
var_ns=8.8.8.8           # Google DNS
var_ns=1.1.1.1           # Cloudflare DNS
var_ns=9.9.9.9           # Quad9 DNS
var_ns=192.168.1.1       # Local DNS
```

**Servidores DNS comuns:**

```
8.8.8.8, 8.8.4.4         → Google Public DNS
1.1.1.1, 1.0.0.1         → Cloudflare DNS
9.9.9.9, 149.112.112.112 → Quad9 DNS
208.67.222.222           → OpenDNS
192.168.1.1              → Local router/Pi-hole
```

---

### var_ssh

**Tipo:** Booleano **Opções:** `yes` ou `no` **Padrão:** `no` **Descrição:** Habilita o servidor SSH no contêiner.

```bash
var_ssh=yes      # SSH server enabled
var_ssh=no       # SSH server disabled (console only)
```

**Quando habilitado:**

- Servidor OpenSSH instalado
- Iniciado na inicialização do sistema
- Porta 22 aberta
- Login do usuário root permitido

**Considerações de segurança:**

- Desabilite se não for necessário
- Use chaves SSH em vez de senhas
- Considere o uso de portas não padrão
- Regras de firewall recomendadas

---

### var_ssh_authorized_key

**Tipo:** String (chave pública SSH) **Padrão:** Nenhum **Descrição:** Chave pública SSH para o usuário root.

```bash
var_ssh_authorized_key=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... user@host
var_ssh_authorized_key=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... user@host
```

**Tipos de chave suportados:**

- RSA (2048-4096 bits)
- Ed25519 (recomendado)
- ECDSA
- DSA (obsoleto)

**Como obter sua chave pública:**

```bash
cat ~/.ssh/id_rsa.pub
# or
cat ~/.ssh/id_ed25519.pub
```

**Múltiplas chaves:** Separe-as com quebras de linha (no arquivo) ou use várias implantações.

---

### var_pw

**Tipo:** String **Padrão:** Vazio (login automático) **Descrição:** Senha de root.

```bash
var_pw=SecurePassword123!    # Set password
var_pw=                      # Auto-login (empty)
```

**Comportamento de login automático:**

- Não é necessária senha para o console
- Login automático ao acessar o console
- SSH ainda requer chave se estiver habilitado
- Adequado para desenvolvimento

**Melhores práticas para senhas:**

- Mínimo de 12 caracteres
- Misture letras maiúsculas/minúsculas/números/símbolos
- Use um gerenciador de senhas
- Troque a senha regularmente

---

### var_nesting

**Tipo:** Booleano (0 ou 1) **Padrão:** `1` **Descrição:** Permite contêineres aninhados (necessário para Docker).

```bash
var_nesting=1    # Nested containers allowed
var_nesting=0    # Nested containers disabled
```

**Necessário para:**

- Docker
- LXC dentro de LXC
- Recursos do Systemd
- Orquestração de contêineres

**Impacto na segurança:**

- Isolamento ligeiramente reduzido
- Necessário para plataformas de contêineres
- Geralmente seguro quando não privilegiado

---

### var_diagnostics

**Tipo:** Booleano (sim ou não) **Padrão:** `sim` **Descrição:** Determina se dados anônimos de telemetria e diagnóstico são enviados para a API Community-Scripts.

```bash
var_diagnostics=yes      # Allow telemetry (helps us improve scripts)
var_diagnostics=no       # Disable all telemetry
```

**Privacidade e Uso:**

- Os dados são estritamente anônimos (ID de sessão aleatório)
- Reporta o sucesso/falha das instalações
- Mapeia códigos de erro (por exemplo, bloqueio do APT, falta de RAM)
- Nenhum dado específico do usuário, nome de host ou chave secreta é enviado

---

### var_gpu

**Tipo:** Booleano/Alternar **Opções:** `yes` ou `no` **Padrão:** `no` **Descrição:** Habilita o encaminhamento de GPU para o contêiner.

```bash
var_gpu=yes      # Enable GPU passthrough (auto-detect)
var_gpu=no       # Disable GPU passthrough (default)
```

**Recursos habilitados:**

- Detecta automaticamente GPUs Intel (QuickSync), NVIDIA e AMD
- Passa por `/dev/dri` e nós de renderização
- Configura as permissões de contêiner apropriadas
- Essencial para servidores de mídia (Plex, Jellyfin, Immich)

**Pré-requisitos:**

- Drivers do host instalados corretamente
- Hardware presente e visível para o Proxmox
- IOMMU habilitado (para algumas configurações)

---

### var_tun

**Tipo:** Booleano/Alternar **Opções:** `yes` ou `no` **Padrão:** `no` **Descrição:** Habilita o suporte a dispositivos TUN/TAP.

```bash
var_tun=yes      # Enable TUN/TAP support
var_tun=no       # Disable TUN/TAP support (default)
```

**Necessário para:**

- Software VPN (WireGuard, OpenVPN)
- Tunelamento de rede (Tailscale, ZeroTier)
- Pontes de rede personalizadas

---

### var_keyctl

**Tipo:** Booleano (0 ou 1) **Padrão:** `0` **Descrição:** Habilita a chamada de sistema keyctl.

```bash
var_keyctl=1     # Keyctl enabled
var_keyctl=0     # Keyctl disabled
```

**Necessário para:**

- Docker em algumas configurações
- Recursos do keyring do Systemd
- Gerenciamento de chaves de criptografia
- Alguns sistemas de autenticação

---

### var_fuse

**Tipo:** Booleano/Alternar **Opções:** `yes` ou `no` **Padrão:** `no` **Descrição:** Habilita o suporte ao sistema de arquivos FUSE.

```bash
var_fuse=yes     # FUSE enabled
var_fuse=no      # FUSE disabled
```

**Necessário para:**

- sshfs
- AppImage
- Algumas ferramentas de backup
- Sistemas de arquivos do espaço do usuário

---

### var_mknod

**Tipo:** Booleano (0 ou 1) **Padrão:** `0` **Descrição:** Permite a criação de nós de dispositivo.

```bash
var_mknod=1      # Device nodes allowed
var_mknod=0      # Device nodes disabled
```

**Requisitos:**

- Kernel 5.3 ou superior
- Recurso experimental
- Usar com cautela

---

### var_mount_fs

**Tipo:** String (separada por vírgulas) **Padrão:** Vazio **Descrição:** Sistemas de arquivos montáveis ​​permitidos.

```bash
var_mount_fs=nfs
var_mount_fs=nfs,cifs
var_mount_fs=ext4,xfs,nfs
```

**Opções comuns:**

```
nfs      → NFS network shares
cifs     → SMB/CIFS shares
ext4     → Ext4 filesystems
xfs      → XFS filesystems
btrfs    → Btrfs filesystems
```

---

### var_protection

**Tipo:** Booleano **Opções:** `yes` ou `no` **Padrão:** `no` **Descrição:** Impede a exclusão acidental.

```bash
var_protection=yes    # Protected from deletion
var_protection=no     # Can be deleted normally
```

**Quando protegido:**

- Não pode ser excluído via GUI
- Não pode ser excluído via `pct destroy`
- Deve-se desativar a proteção primeiro
- Bom para contêineres de produção

---

### var_tags

**Tipo:** String (separada por vírgulas) **Padrão:** `community-script` **Descrição:** Tags de contêiner para a organização.

```bash
var_tags=production
var_tags=production,webserver
var_tags=dev,testing,temporary
```

**Melhores Práticas:**

```bash
# Environment tags
var_tags=production
var_tags=development
var_tags=staging

# Function tags
var_tags=webserver,nginx
var_tags=database,postgresql
var_tags=cache,redis

# Project tags
var_tags=project-alpha,frontend
var_tags=customer-xyz,billing

# Combined
var_tags=production,webserver,project-alpha
```

---

### var_timezone

**Tipo:** String (formato de banco de dados TZ) **Padrão:** Fuso horário do host **Descrição:** Fuso horário do contêiner.

```bash
var_timezone=Europe/Berlin
var_timezone=America/New_York
var_timezone=Asia/Tokyo
```

**Fusos horários comuns:**

```
Europe/London
Europe/Berlin
Europe/Paris
America/New_York
America/Chicago
America/Los_Angeles
Asia/Tokyo
Asia/Singapore
Australia/Sydney
UTC
```

**Listar todos os fusos horários:**

```bash
timedatectl list-timezones
```

---

### var_verbose

**Tipo:** Booleano **Opções:** `yes` ou `no` **Padrão:** `no` **Descrição:** Ativar a saída detalhada.

```bash
var_verbose=yes    # Show all commands
var_verbose=no     # Silent mode
```

**Quando ativado:**

- Mostra todos os comandos executados
- Exibe o progresso detalhado
- Útil para depuração
- Mais informações de log

---

### var_apt_cacher

**Tipo:** Booleano **Opções:** `yes` ou `no` **Padrão:** `no` **Descrição:** Usar o proxy de cache do APT.

```bash
var_apt_cacher=yes
var_apt_cacher=no
```

**Benefícios:**

- Instalação de pacotes mais rápida
- Redução do consumo de banda
- Cache de pacotes offline
- Acelera a execução de múltiplos contêineres

---

### var_apt_cacher_ip

**Tipo:** Endereço IP **Padrão:** Nenhum **Descrição:** Endereço IP do proxy do cache APT.

```bash
var_apt_cacher=yes
var_apt_cacher_ip=192.168.1.100
```

**Configuração do apt-cacher-ng:**

```bash
apt install apt-cacher-ng
# Runs on port 3142
```

---

### var_container_storage

**Tipo:** String **Padrão:** Detectado automaticamente **Descrição:** Armazenamento para contêineres.

```bash
var_container_storage=local
var_container_storage=local-zfs
var_container_storage=pve-storage
```

**Listar armazenamento disponível:**

```bash
pvesm status
```

---

### var_template_storage

**Tipo:** String **Padrão:** Detectado automaticamente **Descrição:** Armazenamento para modelos.

```bash
var_template_storage=local
var_template_storage=nfs-templates
```

---

## Tabela de Referência Rápida

| Variável | Tipo | Padrão | Exemplo |

|----------|------|---------|---------|

| `var_unprivileged` | 0/1 | 1 | `var_unprivileged=1` | | `var_cpu` | int | varia | `var_cpu=4` | | `var_ram` | int (MB) | varia | `var_ram=4096` | | `var_disk` | interno (GB) | varia | `var_disk=20`
| | `var_hostname` | corda | nome do aplicativo | `var_hostname=servidor` | | `var_brg` | corda | vmbr0 | `var_brg=vmbr1` | | `var_net` | dhcp/estático | dhcp | `var_net=dhcp` | | `var_gateway` | PI |
automóvel | `var_gateway=192.168.1.1` | | `var_ipv6_method` | corda | nenhum | `var_ipv6_method=desativar` | | `var_vlan` | interno | - | `var_vlan=100` | | `var_mtu` | interno | 1500 | `var_mtu=9000`
| | `var_mac` | MAC | automóvel | `var_mac=02:00:00:00:00:01` | | `var_ns` | PI | automóvel | `var_ns=8.8.8.8` | | `var_ssh` | sim/não | não | `var_ssh=sim` | | `var_ssh_authorized_key` | corda | - |
`var_ssh_authorized_key=ssh-rsa...` | | `var_pw` | corda | vazio | `var_pw=senha` | | `var_nesting` | 0/1 | 1 | `var_nesting=1` | | `var_keyctl` | 0/1 | 0 | `var_keyctl=1` | | `var_fuse` | 0/1 | 0 |
`var_fuse=1` | | `var_mknod` | 0/1 | 0 | `var_mknod=1` | | `var_mount_fs` | corda | - | `var_mount_fs=nfs,cifs` | | `var_proteção` | sim/não | não | `var_proteção=sim` | | `var_tags` | corda | script
da comunidade | `var_tags=prod,web` | | `var_timezone` | corda | anfitrião TZ | `var_timezone=Europa/Berlim` | | `var_verbose` | sim/não | não | `var_verbose=sim` | | `var_apt_cacher` | sim/não | não
| `var_apt_cacher=sim` | | `var_apt_cacher_ip` | PI | - | `var_apt_cacher_ip=192.168.1.10` | | `var_container_storage` | string | auto | `var_container_storage=local-zfs` | | `var_template_storage` |
string | auto | `var_template_storage=local` |

---

## Consulte também

- [Guia de Configurações Padrão do Sistema](DEFAULTS_GUIDE.md)
- [Implantações Autônomas](UNATTENDED_DEPLOYMENTS.md)
- [Melhores Práticas de Segurança](SECURITY_GUIDE.md)
- [Configuração de Rede](NETWORK_GUIDE.md)
