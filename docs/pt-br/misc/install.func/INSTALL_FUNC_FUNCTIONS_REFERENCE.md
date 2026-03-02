# Referência de Funções do install.func

Referência completa de todas as funções em install.func com informações detalhadas de uso.

## Índice de Funções

- `setting_up_container()` - Inicializa a configuração do contêiner
- `network_check()` - Verifica a conectividade de rede
- `update_os()` - Atualiza os pacotes do sistema operacional
- `verb_ip6()` - Habilita o IPv6
- `motd_ssh()` - Configura o SSH e a mensagem do dia (MOTD)
- `customize()` - Aplica personalizações ao contêiner
- `cleanup_lxc()` - Limpeza final do contêiner

---

## Funções Principais

### setting_up_container()

Exibe a mensagem de configuração e inicializa o ambiente do contêiner.

**Assinatura**:

```bash
setting_up_container
```

**Finalidade**: Anunciar a inicialização do contêiner e definir o ambiente inicial

**Uso**:

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

setting_up_container
# Output: ⏳ Setting up container...
```

---

### network_check()

Verificar a conectividade de rede com lógica de repetição automática.

**Assinatura**:

```bash
network_check
```

**Finalidade**: Garantir a conectividade com a internet antes de operações críticas

**Comportamento**:

- Pings para 8.8.8.8 (DNS do Google)
- 3 tentativas com intervalos de 5 segundos
- Encerra com erro se todas as tentativas falharem

**Uso**:

```bash
network_check
# If no internet: Exits with error message
# If internet OK: Continues to next step
```

**Tratamento de erros**:

```bash
if ! network_check; then
  msg_error "No internet connection"
  exit 1
fi
```

---

### update_os()

Atualizar pacotes do sistema operacional com tratamento de erros.

**Assinatura**:

```bash
update_os
```

**Finalidade**: Preparar o contêiner com os pacotes mais recentes

**No Debian/Ubuntu**:

- Executar: `apt-get update && apt-get upgrade -y`

**No Alpine**:

- Executar: `apk update && apk upgrade`

**Uso**:

```bash
update_os
```

---

### verb_ip6()

Habilitar suporte a IPv6 no contêiner (opcional).

**Assinatura**:

```bash
verb_ip6
```

**Finalidade**: Habilitar IPv6, se necessário, para a aplicação

**Uso**:

```bash
verb_ip6              # Enable IPv6
network_check         # Verify connectivity with IPv6
```

---

### motd_ssh()

Configurar o daemon SSH e a mensagem do dia (MOTD) para acesso ao contêiner.

**Assinatura**:

```bash
motd_ssh
```

**Finalidade**: Configurar SSH e criar mensagem de login

**Configura**:

- Inicialização e chaves do daemon SSH
- Mensagem do dia personalizada exibindo informações de acesso ao aplicativo
- Porta SSH e configurações de segurança

**Uso**:

```bash
motd_ssh
# SSH is now configured and application info is in MOTD
```

---

### customize()

Aplicar personalizações do contêiner e configuração final.

**Assinatura**:

```bash
customize
```

**Finalidade**: Aplicar quaisquer personalizações restantes

**Uso**:

```bash
customize
```

---

### cleanup_lxc()

Limpeza final e conclusão da instalação.

**Assinatura**:

```bash
cleanup_lxc
```

**Finalidade**: Remover arquivos temporários e finalizar a instalação

**Limpa**:

- Arquivos temporários de instalação
- Cache do gerenciador de pacotes
- Arquivos de log do processo de instalação

**Uso**:

```bash
cleanup_lxc
# Installation is now complete and ready
```

---

## Padrões Comuns

### Padrão Básico de Instalação

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

### Com Suporte a IPv6

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

setting_up_container
verb_ip6              # Enable IPv6
network_check
update_os

# ... application installation ...
```

### Com Tratamento de Erros

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

catch_errors          # Setup error trapping
setting_up_container

if ! network_check; then
  msg_error "Network connectivity failed"
  exit 1
fi

update_os
```

---

**Última Atualização**: Dezembro de 2025
**Total de Funções**: 7
**Mantido por**: Equipe community-scripts
