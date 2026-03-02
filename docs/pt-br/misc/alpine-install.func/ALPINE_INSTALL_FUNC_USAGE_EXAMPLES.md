# alpine-install.func Exemplos de Uso

Exemplos básicos para instalação de contêineres Alpine.

### Exemplo: Configuração Básica do Alpine

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

setting_up_container
update_os

# Install Alpine packages
apk add --no-cache curl wget git

motd_ssh
customize
cleanup_lxc
```

---

**Última atualização**: Dezembro de 2025
