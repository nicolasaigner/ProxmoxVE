# Modo de Desenvolvimento - Guia de Depuração e Desenvolvimento

Os modos de desenvolvimento oferecem recursos avançados de depuração e teste para os processos de criação e instalação de contêineres.

## Início Rápido

```bash
# Single mode
export dev_mode="motd"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/wallabag.sh)"

# Multiple modes (comma-separated)
export dev_mode="motd,keep,trace"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/wallabag.sh)"

# Combine with verbose output
export var_verbose="yes"
export dev_mode="pause,logs"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/wallabag.sh)"
```

## Modos Disponíveis

### 1. **motd** - Configuração Antecipada de SSH/MOTD

Configura o acesso SSH e a mensagem do dia (MOTD) **antes** da instalação principal do aplicativo.

**Caso de Uso**:

- Acesso rápido ao contêiner para depuração manual
- Continuar a instalação manualmente se algo der errado
- Verificar a rede do contêiner antes da instalação principal

**Comportamento**:

```
✔ Container created
✔ Network configured
[DEV] Setting up MOTD and SSH before installation
✔ [DEV] MOTD/SSH ready - container accessible
# Container is now accessible via SSH while installation proceeds
```

**Combinado com**: `keep`, `breakpoint`, `logs`

---

### 2. **keep** - Preservar Contêiner em Caso de Falha

Nunca exclua o contêiner quando a instalação falhar. Ignora a solicitação de limpeza.

**Caso de Uso**:

- Testes repetidos da mesma instalação
- Depuração de instalações com falha
- Tentativas de correção manual

**Comportamento**:

```
✖ Installation failed in container 107 (exit code: 1)
✔ Container creation log: /tmp/create-lxc-107-abc12345.log
✔ Installation log: /tmp/install-lxc-107-abc12345.log

🔧 [DEV] Keep mode active - container 107 preserved
root@proxmox:~#
```

**Permanece o contêiner**: `pct enter 107` para acessar e depurar

**Combinado com**: `motd`, `trace`, `logs`

---

### 3. **trace** - Rastreamento de Comandos Bash

Habilita `set -x` para rastreamento completo da linha de comando. Mostra cada comando antes da execução.

**Caso de Uso**:

- Depuração detalhada da lógica de instalação
- Compreensão do fluxo do script
- Identificação exata de onde os erros ocorrem

**Comportamento**:

```
+(/opt/wallabag/bin/console): /opt/wallabag/bin/console cache:warmup
+(/opt/wallabag/bin/console): env APP_ENV=prod /opt/wallabag/bin/console cache:warmup
+(/opt/wallabag/bin/console): [[ -d /opt/wallabag/app/cache ]]
+(/opt/wallabag/bin/console): rm -rf /opt/wallabag/app/cache/*
```

**⚠️ Aviso**: Expõe senhas e segredos na saída de log! Use somente em ambientes isolados.

**Saída de Log**: Todas as informações de rastreamento são salvas nos logs (consulte o modo `logs`).

**Combinado com**: `keep`, `pause`, `logs`

---

### 4. **pause** - Execução passo a passo

Pausa após cada etapa principal (`msg_info`). Requer pressionar Enter manualmente para continuar.

**Caso de Uso**:

- Inspecionar o estado do contêiner entre as etapas
- Entender o que cada etapa faz
- Identificar qual etapa causa problemas

**Comportamento**:

```
⏳ Setting up Container OS
[PAUSE] Press Enter to continue...
⏳ Updating Container OS
[PAUSE] Press Enter to continue...
⏳ Installing Dependencies
[PAUSE] Press Enter to continue...
```

**Entre pausas**: Você pode abrir outro terminal e inspecionar o contêiner

```bash
# In another terminal while paused
pct enter 107
root@container:~# df -h  # Check disk usage
root@container:~# ps aux # Check running processes
```

**Combinado com**: `motd`, `keep`, `logs`

---

### 5. **breakpoint** - Shell Interativo em Caso de Erro

Abre um shell interativo dentro do contêiner quando ocorre um erro, em vez de exibir o prompt de limpeza.

**Caso de Uso**:

- Depuração em tempo real no contêiner
- Teste manual de comandos
- Inspeção do estado do contêiner no momento da falha

**Comportamento**:

```
✖ Installation failed in container 107 (exit code: 1)
✔ Container creation log: /tmp/create-lxc-107-abc12345.log
✔ Installation log: /tmp/install-lxc-107-abc12345.log

🐛 [DEV] Breakpoint mode - opening shell in container 107
Type 'exit' to return to host
root@wallabag:~#

# Now you can debug:
root@wallabag:~# tail -f /root/.install-abc12345.log
root@wallabag:~# mysql -u root -p$PASSWORD wallabag
root@wallabag:~# apt-get install -y strace
root@wallabag:~# exit

Container 107 still running. Remove now? (y/N): n
🔧 Container 107 kept for debugging
```

**Combinado com**: `keep`, `logs`, `trace`

---

### 6. **logs** - Registro Persistente

Salva todos os registros em `/var/log/community-scripts/` com carimbos de data/hora. Os registros são mantidos mesmo após uma instalação bem-sucedida.

**Caso de Uso**:

- Análise pós-mortem
- Análise de desempenho
- Testes automatizados com coleta de logs
- Integração CI/CD

**Comportamento**:

```
Logs location: /var/log/community-scripts/

create-lxc-abc12345-20251117_143022.log    (host-side creation)
install-abc12345-20251117_143022.log       (container-side installation)
```

**Logs de acesso**:

```bash
# View creation log
tail -f /var/log/community-scripts/create-lxc-*.log

# Search for errors
grep ERROR /var/log/community-scripts/*.log

# Analyze performance
grep "msg_info\|msg_ok" /var/log/community-scripts/create-*.log
```

**Com o modo de rastreamento**: Cria um rastreamento detalhado de todos os comandos

```bash
grep "^+" /var/log/community-scripts/install-*.log
```

**Combinado com**: Todos os outros modos (recomendado para CI/CD)

---

### 7. **simulação** - Modo de Simulação

Exibe todos os comandos que seriam executados sem realmente executá-los.

**Caso de Uso**:

- Testar a lógica do script sem fazer alterações
- Verificar a sintaxe do comando
- Entender o que acontecerá
- Verificações prévias à execução

**Comportamento**:

```
[DRYRUN] apt-get update
[DRYRUN] apt-get install -y curl
[DRYRUN] mkdir -p /opt/wallabag
[DRYRUN] cd /opt/wallabag
[DRYRUN] git clone https://github.com/wallabag/wallabag.git .
```

**Nenhuma alteração real feita**: O contêiner/sistema permanece inalterado

**Combinado com**: `trace` (mostra o rastreamento da simulação), `logs` (mostra o que seria executado)

---

## Combinações de Modos

### Fluxo de Trabalho de Desenvolvimento

```bash
# First test: See what would happen
export dev_mode="dryrun,logs"
bash -c "$(curl ...)"

# Then test with tracing and pauses
export dev_mode="pause,trace,logs"
bash -c "$(curl ...)"

# Finally full debug with early SSH access
export dev_mode="motd,keep,breakpoint,logs"
bash -c "$(curl ...)"
```

### Integração CI/CD

```bash
# Automated testing with full logging
export dev_mode="logs"
export var_verbose="yes"
bash -c "$(curl ...)"

# Capture logs for analysis
tar czf installation-logs-$(date +%s).tar.gz /var/log/community-scripts/
```

### Testes em Ambiente de Produção

```bash
# Keep containers for manual verification
export dev_mode="keep,logs"
for i in {1..5}; do
  bash -c "$(curl ...)"
done

# Inspect all created containers
pct list
pct enter 100
```

### Depuração em Tempo Real

```bash
# SSH in early, step through installation, debug on error
export dev_mode="motd,pause,breakpoint,keep"
bash -c "$(curl ...)"
```

---

## Referência de Variáveis ​​de Ambiente

### Variáveis ​​do Modo de Desenvolvimento

- `dev_mode` (string): Lista de modos separados por vírgula

- Formato: `"motd,keep,trace"`

- Padrão: Vazio (sem modos de desenvolvimento)

### Controle de Saída

- `var_verbose="yes"`: Exibir toda a saída de comandos (desativa o modo silencioso)

- Combina bem com: `trace`, `pause`, `logs`

### Exemplos com variáveis

```bash
# Maximum verbosity and debugging
export var_verbose="yes"
export dev_mode="motd,trace,pause,logs"
bash -c "$(curl ...)"

# Silent debug (logs only)
export dev_mode="keep,logs"
bash -c "$(curl ...)"

# Interactive debugging
export var_verbose="yes"
export dev_mode="motd,breakpoint"
bash -c "$(curl ...)"
```

---

## Solução de problemas com o Modo de Desenvolvimento

### "A instalação falhou na etapa X"

```bash
export dev_mode="pause,logs"
# Step through until the failure point
# Check container state between pauses
pct enter 107
```

### "Senha/credenciais não funcionam"

```bash
export dev_mode="motd,keep,trace"
# With trace mode, see exact password handling (be careful with logs!)
# Use motd to SSH in and test manually
ssh root@container-ip
```

### "Erros de permissão negada"

```bash
export dev_mode="breakpoint,keep"
# Get shell at failure point
# Check file permissions, user context, SELinux status
ls -la /path/to/file
whoami
```

### "Rede problemas"

```bash
export dev_mode="motd"
# SSH in with motd mode before main install
ssh root@container-ip
ping 8.8.8.8
nslookup example.com
```

### "É necessário concluir a instalação manualmente"

```bash
export dev_mode="motd,keep"
# Container accessible via SSH while installation runs
# After failure, SSH in and manually continue
ssh root@container-ip
# ... manual commands ...
exit
# Then use 'keep' mode to preserve container for inspection
```

---

## Localização dos Arquivos de Log

### Padrão (sem o modo `logs`)

- Criação do host: `/tmp/create-lxc-<SESSION_ID>.log`

- Instalação do contêiner: Copiado para `/tmp/install-lxc-<CTID>-<SESSION_ID>.log` em caso de falha

### Com o modo `logs`

- Criação do host: `/var/log/community-scripts/create-lxc-<SESSION_ID>-<TIMESTAMP>.log`

- Instalação do contêiner: `/var/log/community-scripts/install-<SESSION_ID>-<TIMESTAMP>.log`

### Visualizar logs

```bash
# Tail in real-time
tail -f /var/log/community-scripts/*.log

# Search for errors
grep -r "exit code [1-9]" /var/log/community-scripts/

# Filter by session
grep "ed563b19" /var/log/community-scripts/*.log
```

---

## Boas Práticas

### ✅ FAÇA

- Use o modo `logs` para CI/CD e testes automatizados
- Use `motd` para acesso SSH antecipado durante instalações longas
- Use `pause` ao aprender o fluxo de instalação
- Use `trace` ao depurar problemas de lógica (cuidado com segredos!)
- Combine modos para uma depuração completa
- Arquive os logs após testes bem-sucedidos

### ❌ NÃO FAÇA

- Use `trace` em produção ou com redes não confiáveis ​​(expõe segredos)
- Deixe o modo `keep` ativado para scripts não supervisionados (os contêineres acumulam logs)
- Use `dryrun` esperando alterações reais
- Inclua exportações do modo `dev_mode` em scripts de implantação de produção
- Use `breakpoint` em ambientes não interativos (o processo travará)

---

## Exemplos

### Exemplo 1: Depurar uma Instalação com Falha

```bash
# Initial test to see the failure
export dev_mode="keep,logs"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/wallabag.sh)"

# Container 107 kept, check logs
tail /var/log/community-scripts/install-*.log

# SSH in to debug
pct enter 107
root@wallabag:~# cat /root/.install-*.log | tail -100
root@wallabag:~# apt-get update  # Retry the failing command
root@wallabag:~# exit

# Re-run with manual step-through
export dev_mode="motd,pause,keep"
bash -c "$(curl ...)"
```

### Exemplo 2: Verificar Etapas de Instalação

```bash
export dev_mode="pause,logs"
export var_verbose="yes"
bash -c "$(curl ...)"

# Press Enter through each step
# Monitor container in another terminal
# pct enter 107
# Review logs in real-time
```

### Exemplo 3: Integração com Pipeline CI/CD

```bash
#!/bin/bash
export dev_mode="logs"
export var_verbose="no"

for app in wallabag nextcloud wordpress; do
  echo "Testing $app installation..."
  APP="$app" bash -c "$(curl ...)" || {
    echo "FAILED: $app"
    tar czf logs-$app.tar.gz /var/log/community-scripts/
    exit 1
  }
  echo "SUCCESS: $app"
done

echo "All installations successful"
tar czf all-logs.tar.gz /var/log/community-scripts/
```

---

## Uso Avançado

### Análise de Logs Personalizada

```bash
# Extract all errors
grep "ERROR\|exit code [1-9]" /var/log/community-scripts/*.log

# Performance timeline
grep "^$(date +%Y-%m-%d)" /var/log/community-scripts/*.log | grep "msg_"

# Memory usage during install
grep "free\|available" /var/log/community-scripts/*.log
```

### Integração com Ferramentas Externas

```bash
# Send logs to Elasticsearch
curl -X POST "localhost:9200/installation-logs/_doc" \
  -H 'Content-Type: application/json' \
  -d @/var/log/community-scripts/install-*.log

# Archive for compliance
tar czf installation-records-$(date +%Y%m).tar.gz \
  /var/log/community-scripts/
gpg --encrypt installation-records-*.tar.gz
```

---

## Suporte e Problemas

Ao relatar problemas de instalação, sempre inclua:

```bash
# Collect all relevant information
export dev_mode="logs"
# Run the failing installation
# Then provide:
tar czf debug-logs.tar.gz /var/log/community-scripts/
```

Inclua o arquivo `debug-logs.tar.gz` ao relatar problemas para um diagnóstico mais preciso.
