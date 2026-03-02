# Referência de Funções do alpine-install.func

Funções de instalação específicas para Alpine Linux (baseadas em APK, OpenRC).

## Funções Principais

### setting_up_container()

Inicializa a configuração do contêiner Alpine.

### update_os()

Atualiza os pacotes do Alpine via `apk update && apk upgrade`.

### verb_ip6()

Habilita o IPv6 no Alpine com configuração persistente.

### network_check()

Verifica a conectividade de rede no Alpine.

### motd_ssh()

Configura o daemon SSH e a mensagem do dia (MOTD) no Alpine.

### customize()

Aplica personalizações específicas do Alpine.

### cleanup_lxc()

Limpeza final (específica do Alpine).

---

**Última atualização**: Dezembro de 2025
