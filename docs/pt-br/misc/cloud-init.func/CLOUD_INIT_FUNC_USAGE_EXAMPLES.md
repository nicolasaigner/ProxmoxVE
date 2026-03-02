# Exemplos de uso de cloud-init.func

Exemplos de configuração de cloud-init em máquinas virtuais.

### Exemplo: Cloud-Init básico

```bash
#!/usr/bin/env bash

generate_cloud_init > cloud-init.yaml
setup_ssh_keys "$VMID" "$SSH_KEY"
apply_cloud_init "$VMID" cloud-init.yaml
```

---

**Última atualização**: dezembro de 2025
