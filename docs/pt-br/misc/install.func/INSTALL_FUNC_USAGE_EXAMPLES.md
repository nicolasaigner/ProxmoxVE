# Exemplos de Uso de install.func

Exemplos práticos de uso das funções install.func em scripts de instalação de aplicativos.

## Exemplos Básicos

### Exemplo 1: Configuração Mínima

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

setting_up_container
network_check
update_os

# ... application installation ...

motd_ssh
customize
cleanup_lxc
```

### Exemplo 2: Com Tratamento de Erros

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

catch_errors
setting_up_container

if ! network_check; then
  msg_error "Network failed"
  exit 1
fi

if ! update_os; then
  msg_error "OS update failed"
  exit 1
fi

# ... continue ...
```

---

## Exemplos de Produção

### Exemplo 3: Instalação Completa do Aplicativo

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

catch_errors
setting_up_container
network_check
update_os

msg_info "Installing application"
# ... install steps ...
msg_ok "Application installed"

motd_ssh
customize
cleanup_lxc
```

### Exemplo 4: Com Suporte a IPv6

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

catch_errors
setting_up_container
verb_ip6
network_check
update_os

# ... application installation ...

motd_ssh
customize
cleanup_lxc
```

---

**Última Atualização**: Dezembro de 2025
**Exemplos**: Padrões básicos e de produção
**Todos os exemplos estão prontos para produção**
