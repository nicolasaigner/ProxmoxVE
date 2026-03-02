# Exemplos de uso de core.func

## Visão geral

Este documento fornece exemplos práticos de uso para funções `core.func`, abrangendo cenários comuns, padrões de integração e boas práticas.

## Configuração Básica do Script

### Inicialização Padrão do Script

```bash
#!/usr/bin/env bash
# Standard script setup using core.func

# Source core functions
source core.func

# Run system checks
pve_check
arch_check
shell_check
root_check

# Optional: Check SSH connection
ssh_check

# Set up error handling
trap 'stop_spinner' EXIT INT TERM

# Your script logic here
msg_info "Starting script execution"
# ... script code ...
msg_ok "Script completed successfully"
```

### Configuração Mínima do Script

```bash
#!/usr/bin/env bash
# Minimal setup for simple scripts

source core.func

# Basic checks only
pve_check
root_check

# Simple execution
msg_info "Running operation"
# ... your code ...
msg_ok "Operation completed"
```

## Exemplos de Exibição de Mensagens

### Indicação de Progresso

```bash
#!/usr/bin/env bash
source core.func

# Show progress with spinner
msg_info "Downloading package..."
sleep 2
msg_ok "Download completed"

msg_info "Installing package..."
sleep 3
msg_ok "Installation completed"

msg_info "Configuring service..."
sleep 1
msg_ok "Configuration completed"
```

### Tratamento de Erros

```bash
#!/usr/bin/env bash
source core.func

# Function with error handling
install_package() {
    local package="$1"

    msg_info "Installing $package..."

    if silent apt-get install -y "$package"; then
        msg_ok "$package installed successfully"
        return 0
    else
        msg_error "Failed to install $package"
        return 1
    fi
}

# Usage
if install_package "nginx"; then
    msg_ok "Nginx installation completed"
else
    msg_error "Nginx installation failed"
    exit 1
fi
```

### Mensagens de Aviso

```bash
#!/usr/bin/env bash
source core.func

# Show warnings for potentially dangerous operations
msg_warn "This will modify system configuration"
read -p "Continue? [y/N]: " confirm

if [[ "$confirm" =~ ^[yY]$ ]]; then
    msg_info "Proceeding with modification..."
    # ... dangerous operation ...
    msg_ok "Modification completed"
else
    msg_info "Operation cancelled"
fi
```

### Mensagens Personalizadas

```bash
#!/usr/bin/env bash
source core.func

# Custom message with specific icon and color
msg_custom "🚀" "\e[32m" "Launching application"
msg_custom "⚡" "\e[33m" "High performance mode enabled"
msg_custom "🔒" "\e[31m" "Security mode activated"
```

### Mensagens de Depuração

```bash
#!/usr/bin/env bash
source core.func

# Enable debug mode
export var_full_verbose=1

# Debug messages
msg_debug "Variable value: $some_variable"
msg_debug "Function called: $FUNCNAME"
msg_debug "Current directory: $(pwd)"
```

## Exemplos de Execução Silenciosa

### Gerenciamento de Pacotes

```bash
#!/usr/bin/env bash
source core.func

# Update package lists
msg_info "Updating package lists..."
silent apt-get update

# Install packages
msg_info "Installing required packages..."
silent apt-get install -y curl wget git

# Upgrade packages
msg_info "Upgrading packages..."
silent apt-get upgrade -y

msg_ok "Package management completed"
```

### Operações com Arquivos

```bash
#!/usr/bin/env bash
source core.func

# Create directories
msg_info "Creating directory structure..."
silent mkdir -p /opt/myapp/{config,logs,data}

# Set permissions
msg_info "Setting permissions..."
silent chmod 755 /opt/myapp
silent chmod 644 /opt/myapp/config/*

# Copy files
msg_info "Copying configuration files..."
silent cp config/* /opt/myapp/config/

msg_ok "File operations completed"
```

### Serviço Gerenciamento

```bash
#!/usr/bin/env bash
source core.func

# Start service
msg_info "Starting service..."
silent systemctl start myservice

# Enable service
msg_info "Enabling service..."
silent systemctl enable myservice

# Check service status
msg_info "Checking service status..."
if silent systemctl is-active --quiet myservice; then
    msg_ok "Service is running"
else
    msg_error "Service failed to start"
fi
```

### Operações de Rede

```bash
#!/usr/bin/env bash
source core.func

# Test network connectivity
msg_info "Testing network connectivity..."
if silent ping -c 1 8.8.8.8; then
    msg_ok "Network connectivity confirmed"
else
    msg_error "Network connectivity failed"
fi

# Download files
msg_info "Downloading configuration..."
silent curl -fsSL https://example.com/config -o /tmp/config

# Extract archives
msg_info "Extracting archive..."
silent tar -xzf /tmp/archive.tar.gz -C /opt/
```

## Exemplos de Verificação do Sistema

### Validação Abrangente do Sistema

```bash
#!/usr/bin/env bash
source core.func

# Complete system validation
validate_system() {
    msg_info "Validating system requirements..."

    # Check Proxmox version
    if pve_check; then
        msg_ok "Proxmox VE version is supported"
    fi

    # Check architecture
    if arch_check; then
        msg_ok "System architecture is supported"
    fi

    # Check shell
    if shell_check; then
        msg_ok "Shell environment is correct"
    fi

    # Check privileges
    if root_check; then
        msg_ok "Running with sufficient privileges"
    fi

    # Check SSH connection
    ssh_check

    msg_ok "System validation completed"
}

# Run validation
validate_system
```

### Verificações Condicionais do Sistema

```bash
#!/usr/bin/env bash
source core.func

# Check if running in container
if [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]]; then
    msg_warn "Running inside container"
    # Skip some checks
else
    # Full system checks
    pve_check
    arch_check
fi

# Always check shell and privileges
shell_check
root_check
```

## Exemplos de Gerenciamento de Cabeçalhos

### Exibição de Cabeçalhos de Aplicativos

```bash
#!/usr/bin/env bash
source core.func

# Set application information
export APP="plex"
export APP_TYPE="ct"

# Display header
header_info

# Continue with application setup
msg_info "Setting up Plex Media Server..."
```

### Manipulação Personalizada de Cabeçalhos

```bash
#!/usr/bin/env bash
source core.func

# Get header content
export APP="nextcloud"
export APP_TYPE="ct"

header_content=$(get_header)
if [[ -n "$header_content" ]]; then
    echo "Header found:"
    echo "$header_content"
else
    msg_warn "No header found for $APP"
fi
```

## Exemplos de Gerenciamento de Swap

### Criação Interativa de Swap

```bash
#!/usr/bin/env bash
source core.func

# Check and create swap
if check_or_create_swap; then
    msg_ok "Swap is available"
else
    msg_warn "No swap available - continuing without swap"
fi
```

### Verificação Automatizada de Swap

```bash
#!/usr/bin/env bash
source core.func

# Check swap without prompting
check_swap_quiet() {
    if swapon --noheadings --show | grep -q 'swap'; then
        msg_ok "Swap is active"
        return 0
    else
        msg_warn "No active swap detected"
        return 1
    fi
}

if check_swap_quiet; then
    msg_info "System has sufficient swap"
else
    msg_warn "Consider adding swap for better performance"
fi
```

## Exemplos de Uso do Spinner

### Execução de Longa Duração Operações

```bash
#!/usr/bin/env bash
source core.func

# Long-running operation with spinner
long_operation() {
    msg_info "Processing large dataset..."

    # Simulate long operation
    for i in {1..100}; do
        sleep 0.1
        # Update spinner message periodically
        if (( i % 20 == 0 )); then
            SPINNER_MSG="Processing... $i%"
        fi
    done

    msg_ok "Dataset processing completed"
}

long_operation
```

### Operações em Segundo Plano

```bash
#!/usr/bin/env bash
source core.func

# Background operation with spinner
background_operation() {
    msg_info "Starting background process..."

    # Start spinner
    SPINNER_MSG="Processing in background..."
    spinner &
    SPINNER_PID=$!

    # Do background work
    sleep 5

    # Stop spinner
    stop_spinner
    msg_ok "Background process completed"
}

background_operation
```

## Exemplos de Integração

### Com build.func

```bash
#!/usr/bin/env bash
# Integration with build.func

source core.func
source build.func

# Use core functions for system validation
pve_check
arch_check
root_check

# Use build.func for container creation
export APP="plex"
export CTID="100"
# ... container creation ...
```

### Com tools.func

```bash
#!/usr/bin/env bash
# Integration with tools.func

source core.func
source tools.func

# Use core functions for UI
msg_info "Starting maintenance tasks..."

# Use tools.func for maintenance
update_system
cleanup_logs
optimize_storage

msg_ok "Maintenance completed"
```

### Com error_handler.func

```bash
#!/usr/bin/env bash
# Integration with error_handler.func

source core.func
source error_handler.func

# Use core functions for execution
msg_info "Running operation..."

# Silent execution will use error_handler for explanations
silent apt-get install -y package

msg_ok "Operation completed"
```

## Exemplos de Boas Práticas

### Padrão de Tratamento de Erros

```bash
#!/usr/bin/env bash
source core.func

# Robust error handling
run_with_error_handling() {
    local operation="$1"
    local description="$2"

    msg_info "$description"

    if silent "$operation"; then
        msg_ok "$description completed successfully"
        return 0
    else
        msg_error "$description failed"
        return 1
    fi
}

# Usage
run_with_error_handling "apt-get update" "Package list update"
run_with_error_handling "apt-get install -y nginx" "Nginx installation"
```

### Tratamento em Modo Detalhado

```bash
#!/usr/bin/env bash
source core.func

# Handle verbose mode
if is_verbose_mode; then
    msg_info "Verbose mode enabled - showing detailed output"
    # Show more information
else
    msg_info "Normal mode - showing minimal output"
    # Show less information
fi
```

### Detecção do Alpine Linux

```bash
#!/usr/bin/env bash
source core.func

# Handle different OS types
if is_alpine; then
    msg_info "Detected Alpine Linux"
    # Use Alpine-specific commands
    silent apk add --no-cache package
else
    msg_info "Detected Debian-based system"
    # Use Debian-specific commands
    silent apt-get install -y package
fi
```

### Execução Condicional

```bash
#!/usr/bin/env bash
source core.func

# Conditional execution based on system state
if [[ -f /etc/nginx/nginx.conf ]]; then
    msg_warn "Nginx configuration already exists"
    read -p "Overwrite? [y/N]: " overwrite
    if [[ "$overwrite" =~ ^[yY]$ ]]; then
        msg_info "Overwriting configuration..."
        # ... overwrite logic ...
    else
        msg_info "Skipping configuration"
    fi
else
    msg_info "Creating new Nginx configuration..."
    # ... create logic ...
fi
```

## Avançado Exemplos de Uso

### Mensagens Personalizadas do Spinner

```bash
#!/usr/bin/env bash
source core.func

# Custom spinner with progress
download_with_progress() {
    local url="$1"
    local file="$2"

    msg_info "Starting download..."

    # Start spinner
    SPINNER_MSG="Downloading..."
    spinner &
    SPINNER_PID=$!

    # Download with progress
    curl -L "$url" -o "$file" --progress-bar

    # Stop spinner
    stop_spinner
    msg_ok "Download completed"
}

download_with_progress "https://example.com/file.tar.gz" "/tmp/file.tar.gz"
```

### Desduplicação de Mensagens

```bash
#!/usr/bin/env bash
source core.func

# Messages are automatically deduplicated
for i in {1..5}; do
    msg_info "Processing item $i"
    # This message will only show once
done

# Different messages will show separately
msg_info "Starting phase 1"
msg_info "Starting phase 2"
msg_info "Starting phase 3"
```

### Controle do Terminal

```bash
#!/usr/bin/env bash
source core.func

# Ensure terminal control is available
ensure_tput

# Use terminal control
clear_line
echo "This line will be cleared"
clear_line
echo "New content"
```

## Exemplos de Solução de Problemas

### Modo de Depuração

```bash
#!/usr/bin/env bash
source core.func

# Enable debug mode
export var_full_verbose=1
export VERBOSE="yes"

# Debug information
msg_debug "Script started"
msg_debug "Current user: $(whoami)"
msg_debug "Current directory: $(pwd)"
msg_debug "Environment variables: $(env | grep -E '^(APP|CTID|VERBOSE)')"
```

### Depuração de Execução Silenciosa

```bash
#!/usr/bin/env bash
source core.func

# Debug silent execution
debug_silent() {
    local cmd="$1"
    local log_file="/tmp/debug.$.log"

    echo "Command: $cmd" > "$log_file"
    echo "Timestamp: $(date)" >> "$log_file"
    echo "Working directory: $(pwd)" >> "$log_file"
    echo "Environment:" >> "$log_file"
    env >> "$log_file"
    echo "--- Command Output ---" >> "$log_file"

    if silent "$cmd"; then
        msg_ok "Command succeeded"
    else
        msg_error "Command failed - check $log_file for details"
    fi
}

debug_silent "apt-get update"
```

### Recuperação de Erros

```bash
#!/usr/bin/env bash
source core.func

# Error recovery pattern
retry_operation() {
    local max_attempts=3
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        msg_info "Attempt $attempt of $max_attempts"

        if silent "$@"; then
            msg_ok "Operation succeeded on attempt $attempt"
            return 0
        else
            msg_warn "Attempt $attempt failed"
            ((attempt++))

            if [[ $attempt -le $max_attempts ]]; then
                msg_info "Retrying in 5 seconds..."
                sleep 5
            fi
        fi
    done

    msg_error "Operation failed after $max_attempts attempts"
    return 1
}

# Usage
retry_operation "apt-get install -y package"
```
