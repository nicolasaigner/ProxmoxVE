# Fluxograma do cloud-init.func

Fluxo de provisionamento de VMs do Cloud-init.

## Geração e aplicação do Cloud-Init

```
generate_cloud_init()
    ↓
generate_user_data()
    ↓
setup_ssh_keys()
    ↓
Apply to VM
    ↓
VM Boot
    ↓
cloud-init phases
├─ system
├─ config
└─ final
    ↓
VM Ready ✓
```

---

**Última atualização**: dezembro de 2025
