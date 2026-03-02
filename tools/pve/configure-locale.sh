#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

# Roda no host Proxmox VE.
# Configura o locale pt_BR.UTF-8 em todos os LXC containers.
# Containers parados são ligados temporariamente e desligados após a configuração.

function header_info() {
  clear
  cat <<"EOF"
   ______            _____                    __                  __
  / ____/___  ____  / __(_)___ ___  ___  ____/ /  __  __   ____  / /_
 / /   / __ \/ __ \/ /_/ / __ `/ / / / / ___/ /  / / / /  / __ \/ __/
/ /___/ /_/ / / / / __/ / /_/ / /_/ / / /  / /  / /_/ /  / /_/ / /_
\____/\____/_/ /_/_/ /_/\__, /\__,_/ /_/  /_/   \__, /   / .___/\__/
                        /____/                  /____/   /_/
 ____  ____        ____  ____
/ __ \/_  /       / __ )/ __ \
/ /_/ / / /____  / __  / /_/ /
/ ____/ / /_____/ /_/ / _, _/
/_/   /___/      /_____/_/ |_|

EOF
}

set -eEuo pipefail

BL="\033[36m"
RD="\033[01;31m"
YW="\033[33m"
GN="\033[1;92m"
CL="\033[m"
CM='\xE2\x9C\x94\033'
CROSS='\xE2\x9C\x97\033'

header_info
echo -e "${BL}Carregando lista de containers...${CL}\n"

# ─── Confirmação inicial ──────────────────────────────────────────────────────
if ! whiptail --backtitle "Proxmox VE Helper Scripts" \
  --title "Configurar Locale pt_BR.UTF-8" \
  --yesno "Este script irá configurar o locale pt_BR.UTF-8 em todos os LXC containers.\n\nContainers parados serão iniciados temporariamente e desligados ao fim.\n\nDeseja continuar?" \
  12 62; then
  echo -e "${YW}Operação cancelada pelo usuário.${CL}"
  exit 0
fi

# ─── Menu de exclusão (containers a pular) ───────────────────────────────────
NODE=$(hostname)
EXCLUDE_MENU=()
MSG_MAX_LENGTH=0

while read -r VMID NAME STATUS; do
  LABEL="[$VMID] $NAME ($STATUS)"
  ((${#LABEL} + 2 > MSG_MAX_LENGTH)) && MSG_MAX_LENGTH=${#LABEL}+2
  EXCLUDE_MENU+=("$VMID" "$LABEL" "OFF")
done < <(pct list | awk 'NR>1 {print $1, $3, $2}')

if [ ${#EXCLUDE_MENU[@]} -eq 0 ]; then
  echo -e "${RD}Nenhum LXC container encontrado no host.${CL}"
  exit 1
fi

SKIP_LIST=$(whiptail --backtitle "Proxmox VE Helper Scripts" \
  --title "Containers em $NODE" \
  --checklist "\nSelecione os containers para PULAR (não configurar):\n" \
  16 $((MSG_MAX_LENGTH + 23)) 6 "${EXCLUDE_MENU[@]}" \
  3>&1 1>&2 2>&3 | tr -d '"') || true

# ─── Script de locale (executado dentro de cada container) ───────────────────
# Escrito em /tmp para envio via pct push
TMPSCRIPT=$(mktemp /tmp/locale-ptbr-XXXX.sh)
cat > "$TMPSCRIPT" << 'INNERSCRIPT'
#!/bin/bash
set -euo pipefail

# Detecta se é Alpine (não suporta locales da mesma forma)
if [ -f /etc/alpine-release ]; then
  apk add --no-cache musl-locales musl-locales-lang 2>/dev/null || true
  echo "LANG=pt_BR.UTF-8" > /etc/locale.conf
  echo "LC_ALL=pt_BR.UTF-8" >> /etc/locale.conf
  echo "[Alpine] locale configurado via musl-locales"
  exit 0
fi

# Debian/Ubuntu
DEBIAN_FRONTEND=noninteractive apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -q locales

# Habilita pt_BR.UTF-8 no locale.gen (descomenta se estiver comentado)
if grep -q "pt_BR.UTF-8" /etc/locale.gen 2>/dev/null; then
  sed -i 's/^# *\(pt_BR.UTF-8 UTF-8\)/\1/' /etc/locale.gen
else
  echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
fi

# Gera os locales
locale-gen

# Define como padrão do sistema
update-locale LANG=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8

# Exporta imediatamente para a sessão atual
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

# Valida
locale
INNERSCRIPT
chmod +x "$TMPSCRIPT"

# ─── Loop principal ───────────────────────────────────────────────────────────
SUCCESS=0
FAILED=0
SKIPPED=0

while read -r VMID NAME STATUS; do
  # Verifica se deve pular
  if echo "$SKIP_LIST" | grep -qw "$VMID"; then
    echo -e "${YW}[LXC $VMID] $NAME: pulando (solicitado pelo usuário)${CL}"
    ((SKIPPED++)) || true
    continue
  fi

  WAS_STOPPED=false

  # Liga o container se estiver parado
  if [[ "$STATUS" == "stopped" ]]; then
    echo -e "${YW}[LXC $VMID] $NAME: iniciando container...${CL}"
    if ! pct start "$VMID"; then
      echo -e "${RD}${CROSS} [LXC $VMID] $NAME: falha ao iniciar. Pulando.${CL}"
      ((FAILED++)) || true
      continue
    fi
    WAS_STOPPED=true
    # Aguarda o container ficar pronto (máx 30s)
    for _ in $(seq 1 30); do
      sleep 1
      pct_status=$(pct status "$VMID" 2>/dev/null | awk '{print $2}')
      [[ "$pct_status" == "running" ]] && break
    done
    sleep 2  # tempo extra para o init completar
  fi

  # Envia e executa o script de locale
  echo -e "${BL}[LXC $VMID] $NAME: configurando locale pt_BR.UTF-8...${CL}"
  if pct push "$VMID" "$TMPSCRIPT" /tmp/locale-setup.sh 2>/dev/null \
    && pct exec "$VMID" -- bash /tmp/locale-setup.sh 2>&1 | sed 's/^/  /' \
    && pct exec "$VMID" -- rm -f /tmp/locale-setup.sh; then
    echo -e "${GN}${CM} [LXC $VMID] $NAME: locale configurado com sucesso.${CL}"
    ((SUCCESS++)) || true
  else
    echo -e "${RD}${CROSS} [LXC $VMID] $NAME: falha ao configurar locale.${CL}"
    ((FAILED++)) || true
  fi

  # Desliga o container se estava parado antes
  if [[ "$WAS_STOPPED" == true ]]; then
    echo -e "${YW}[LXC $VMID] $NAME: desligando (estava parado antes)...${CL}"
    pct stop "$VMID" || true
  fi

  echo ""
done < <(pct list | awk 'NR>1 {print $1, $3, $2}')

# Limpa o script temporário do host
rm -f "$TMPSCRIPT"

# ─── Resumo ───────────────────────────────────────────────────────────────────
echo -e "─────────────────────────────────────────"
echo -e "${GN}Concluído!${CL}"
echo -e "  ${GN}✔ Sucesso: $SUCCESS${CL}"
[[ $FAILED -gt 0 ]] && echo -e "  ${RD}✘ Falhas:  $FAILED${CL}"
[[ $SKIPPED -gt 0 ]] && echo -e "  ${YW}⏭ Pulados: $SKIPPED${CL}"
echo -e "─────────────────────────────────────────"
echo -e "\n${YW}Nota:${CL} Para que o locale seja aplicado nas sessões existentes,"
echo -e "      reconecte ao container ou use ${BL}source /etc/default/locale${CL}"
