# Referência do Assistente de Configurações Avançadas

## Visão Geral

O assistente de Configurações Avançadas oferece uma configuração interativa de 28 etapas para a criação de contêineres LXC. Ele permite que os usuários personalizem todos os aspectos do contêiner,
herdando valores padrão adequados do script CT.

## Principais Recursos

- **Herdar Valores Padrão do Aplicativo**: Todos os valores `var_*` dos scripts CT preenchem automaticamente os campos do assistente.
- **Navegação para Trás**: Pressione Cancelar/Voltar para retornar à etapa anterior.
- **Dicas de Valores Padrão do Aplicativo**: Cada caixa de diálogo exibe `(Valor padrão do aplicativo: X)` para indicar os valores padrão do script.
- **Personalização Completa**: Todas as opções configuráveis ​​estão acessíveis.

## Etapas do Assistente

| Etapa | Título                       | Variável(eis)                         | Descrição                                                            |
| ----- | ---------------------------- | ------------------------------------- | -------------------------------------------------------------------- |
| 1     | Tipo de Contêiner            | `var_unprivileged`                    | Contêiner Privilegiado (0) ou Não Privilegiado (1)                   |
| 2     | Senha de Root                | `var_pw`                              | Defina a senha ou use o login automático                             |
| 3     | ID do contêiner              | `var_ctid`                            | ID exclusivo do contêiner (sugerido automaticamente)                 |
| 4     | Nome do host                 | `var_hostname`                        | Nome do host do contêiner                                            |
| 5     | Tamanho do disco             | `var_disk`                            | Tamanho do disco em GB                                               |
| 6     | Núcleos da CPU               | `var_cpu`                             | Número de núcleos da CPU                                             |
| 7     | Tamanho da RAM               | `var_ram`                             | Tamanho da RAM em MiB                                                |
| 8     | Ponte de rede                | `var_brg`                             | Ponte de rede (vmbr0, etc.)                                          |
| 9     | Configuração IPv4            | `var_net`, `var_gateway`              | IP DHCP ou estático com gateway                                      |
| 10    | Configuração IPv6            | `var_ipv6_method`                     | Automático, DHCP, Estático ou Nenhum                                 |
| 11    | Tamanho do MTU               | `var_mtu`                             | MTU da rede (padrão: 1500)                                           |
| 12    | Domínio de Busca DNS         | `var_searchdomain`                    | Domínio de busca DNS                                                 |
| 13    | Servidor DNS                 | `var_ns`                              | IP do servidor DNS personalizado                                     |
| 14    | Endereço MAC                 | `var_mac`                             | Endereço MAC personalizado (gerado automaticamente se estiver vazio) |
| 15    | Tag VLAN                     | `var_vlan`                            | ID da tag VLAN                                                       |
| 16    | Tags                         | `var_tags`                            | Tags do contêiner (separadas por vírgula e ponto e vírgula)          |
| 17    | Configurações SSH            | `var_ssh`                             | Seleção da chave SSH e acesso root                                   |
| 18    | Suporte a FUSE               | `var_fuse`                            | Habilitar FUSE para rclone, mergerfs e AppImage                      |
| 19    | Suporte a TUN/TAP            | `var_tun`                             | Habilitar para aplicativos VPN (WireGuard, OpenVPN, Tailscale)       |
| 20    | Suporte a Aninhamento        | `var_nesting`                         | Habilitar para Docker, LXC em LXC, Podman                            |
| 21    | Passagem direta de GPU       | `var_gpu`                             | Detecção automática e passagem direta de GPUs Intel/AMD/NVIDIA       |
| 22    | Suporte a Keyctl             | `var_keyctl`                          | Habilitar para Docker, systemd-networkd                              |
| 23    | Proxy de cache APT           | `var_apt_cacher`, `var_apt_cacher_ip` | Usar apt-cacher-ng para downloads mais rápidos                       |
| 24    | Fuso horário do contêiner    | `var_timezone`                        | Definir fuso horário (ex.: Europe/Berlin)                            |
| 25    | Proteção do contêiner        | `var_protection`                      | Impedir exclusão acidental                                           |
| 26    | Criação de nó de dispositivo | `var_mknod`                           | Permitir mknod (experimental, kernel 5.3+)                           |
| 27    | Montar sistemas de arquivos  | `var_mount_fs`                        | Permitir montagens específicas: nfs, cifs, fuse, etc.                |
| 28    | Modo Detalhado e Confirmação | `var_verbose`                         | Ativar saída detalhada + confirmação final                           |

## Herança de Valores Padrão

O assistente herda configurações padrão de múltiplas fontes:

```text
CT Script (var_*) → default.vars → app.vars → User Input
```

### Exemplo: Contêiner VPN (alpine-wireguard.sh)

```bash
# CT script sets:
var_tun="${var_tun:-1}"  # TUN enabled by default

# In Advanced Settings Step 19:
# Dialog shows: "(App default: 1)" and pre-selects "Yes"
```

### Exemplo: Servidor de Mídia (jellyfin.sh)

```bash
# CT script sets:
var_gpu="${var_gpu:-yes}"  # GPU enabled by default

# In Advanced Settings Step 21:
# Dialog shows: "(App default: yes)" and pre-selects "Yes"
```

## Matriz de Recursos

| Recurso         | Variável         | Quando Habilitar                                                           |
| --------------- | ---------------- | -------------------------------------------------------------------------- |
| FUSE            | `var_fuse`       | rclone, mergerfs, AppImage, SSHFS                                          |
| TUN/TAP         | `var_tun`        | WireGuard, OpenVPN, Tailscale, contêineres VPN                             |
| Aninhamento     | `var_nesting`    | Docker, Podman, LXC-in-LXC, systemd-nspawn                                 |
| Passagem de GPU | `var_gpu`        | Plex, Jellyfin, Emby, Frigate, Ollama, ComfyUI                             |
| Keyctl          | `var_keyctl`     | Docker (sem privilégios), systemd-networkd                                 |
| Proteção        | `var_protection` | Contêineres de produção, evita exclusão acidental                          |
| Mknod           | `var_mknod`      | Criação de nó de dispositivo (experimental)                                |
| Mount FS        | `var_mount_fs`   | Montagens NFS, compartilhamentos CIFS, sistemas de arquivos personalizados |
| APT Cacher      | `var_apt_cacher` | Acelere os downloads com o apt-cacher-ng local                             |

## Resumo da Confirmação

A etapa 28 exibe um resumo completo antes da criação:

```text
Container Type: Unprivileged
Container ID: 100
Hostname: jellyfin

Resources:
  Disk: 8 GB
  CPU: 2 cores
  RAM: 2048 MiB

Network:
  Bridge: vmbr0
  IPv4: dhcp
  IPv6: auto

Features:
  FUSE: no | TUN: no
  Nesting: Enabled | Keyctl: Disabled
  GPU: yes | Protection: No

Advanced:
  Timezone: Europe/Berlin
  APT Cacher: no
  Verbose: no
```

## Exemplos de Uso

### Ir para Configurações Avançadas

```bash
# Run script, select "Advanced" from menu
bash -c "$(curl -fsSL https://...jellyfin.sh)"
# Then select option 3 "Advanced"
```

### Padrões Predefinidos via Ambiente

```bash
# Set defaults before running
export var_cpu=4
export var_ram=4096
export var_gpu=yes
bash -c "$(curl -fsSL https://...jellyfin.sh)"
# Advanced settings will inherit these values
```

### Não Interativo com Todas as Opções

```bash
# Set all variables for fully automated deployment
export var_unprivileged=1
export var_cpu=2
export var_ram=2048
export var_disk=8
export var_net=dhcp
export var_fuse=no
export var_tun=no
export var_gpu=yes
export var_nesting=1
export var_protection=no
export var_verbose=no
bash -c "$(curl -fsSL https://...jellyfin.sh)"
```

## Observações

- **Cancelar na Etapa 1**: Encerra o script completamente
- **Cancelar nas Etapas 2 a 28**: Retorna à etapa anterior
- **Campos vazios**: Usa o valor padrão
- **Keyctl**: Ativado automaticamente para contêineres sem privilégios
- **Aninhamento**: Ativado por padrão (necessário para muitos aplicativos)
