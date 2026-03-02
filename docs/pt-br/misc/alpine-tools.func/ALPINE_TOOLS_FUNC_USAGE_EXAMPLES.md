# alpine-tools.func Exemplos de Uso

Exemplos para instalação de ferramentas Alpine.

### Exemplo: Configuração do Alpine com Ferramentas

```bash
#!/usr/bin/env bash
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

apk_update
setup_nodejs "20"
setup_php "8.3"
setup_mariadb "11"
```

---

**Última atualização**: Dezembro de 2025
