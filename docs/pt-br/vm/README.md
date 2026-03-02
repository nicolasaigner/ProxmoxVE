# Documentação de Scripts de VM (/vm)

Este diretório contém documentação completa para scripts de criação de máquinas virtuais no diretório `/vm`.

## Visão Geral

Os scripts de VM (`vm/*.sh`) criam máquinas virtuais completas (não contêineres) no Proxmox VE com sistemas operacionais completos e provisionamento cloud-init.

## Estrutura da Documentação

A documentação de VMs é semelhante à documentação de contêineres, mas foca em recursos específicos de VMs.

## Recursos Principais

- **[misc/cloud-init.func/](../misc/cloud-init.func/)** - Documentação de provisionamento do Cloud-init
- **[CONTRIBUTION_GUIDE.md](../CONTRIBUTION_GUIDE.md)** - Fluxo de trabalho de contribuição
- **[EXIT_CODES.md](../EXIT_CODES.md)** - Referência de códigos de saída

## Fluxo de Criação de VMs

```
vm/OsName-vm.sh (host-side)
    │
    ├─ Calls: build.func (orchestrator)
    │
    ├─ Variables: var_cpu, var_ram, var_disk, var_os
    │
    ├─ Uses: cloud-init.func (provisioning)
    │
    └─ Creates: KVM/QEMU VM
                │
                └─ Boots with: Cloud-init config
                               │
                               ├─ System phase
                               ├─ Config phase
                               └─ Final phase
```

## Scripts de VM Disponíveis

Consulte o diretório `/vm` para todos os scripts de criação de VMs. Exemplos:

- `ubuntu2504-vm.sh` - VM Ubuntu 25.04 (Mais recente)
- `ubuntu2404-vm.sh` - VM Ubuntu 24.04 (LTS)
- `debian-13-vm.sh` - VM Debian 13 (Trixie)
- `archlinux-vm.sh` - VM Arch Linux
- `haos-vm.sh` - Sistema Operacional Home Assistant
- `mikrotik-routeros.sh` - MikroTik RouterOS
- `openwrt-vm.sh` - VM OpenWrt
- `opnsense-vm.sh` - Firewall OPNsense
- `umbrel-os-vm.sh` - VM Umbrel OS
- E mais de 10 outros...

## VM vs Contêiner

| Recurso | VM | Contêiner |

|---------|:---:|:---:|

| Isolamento | Completo | Leve | | Tempo de inicialização | Mais lento | Instantâneo | | Uso de recursos | Maior | Menor | | Caso de uso | Sistema operacional completo | Aplicativo único | | Sistema
de inicialização | systemd/etc | cloud-init | | Armazenamento | Imagem de disco | Sistema de arquivos |

## Início Rápido

Para entender a criação de VMs:

1. Leia: [misc/cloud-init.func/README.md](../misc/cloud-init.func/README.md)
2. Estude: Um script similar existente em `/vm`
3. Compreenda a configuração do cloud-init
4. Teste localmente
5. Envie um PR

## Contribuindo com uma Nova VM

1. Crie `vm/osname-vm.sh`
2. Use o cloud-init para provisionamento
3. Siga o modelo de script de VM
4. Teste a criação e inicialização da VM
5. Envie um PR

## Provisionamento com Cloud-Init

As VMs são provisionadas usando o cloud-init:

```yaml
#cloud-config
hostname: myvm
timezone: UTC

packages:
  - curl
  - wget

users:
  - name: ubuntu
    ssh_authorized_keys:
      - ssh-rsa AAAAB3...

bootcmd:
  - echo "VM starting..."

runcmd:
  - apt-get update
  - apt-get upgrade -y
```

## Operações Comuns de VM

- **Criar VM com cloud-init** → [misc/cloud-init.func/](../misc/cloud-init.func/)
- **Configurar rede** → Documentação YAML do Cloud-init
- **Configurar chaves SSH** → [misc/cloud-init.func/CLOUD_INIT_FUNC_USAGE_EXAMPLES.md](../misc/cloud-init.func/CLOUD_INIT_FUNC_USAGE_EXAMPLES.md)
- **Depurar a criação de VMs** → [EXIT_CODES.md](../EXIT_CODES.md)

## Modelos de VM

Modelos de VM comuns disponíveis:

- **Ubuntu LTS** - Última versão estável do Ubuntu
- **Debian Stable** - Última versão estável do Debian
- **OPNsense** - Plataforma de segurança de rede
- **Home Assistant** - Automação residencial
- **Kubernetes** - Cluster leve K3s
- **Backup do Proxmox** - Servidor de backup

---

**Última atualização**: dezembro de 2025 **Responsáveis ​​pela manutenção**: Equipe de scripts da comunidade
