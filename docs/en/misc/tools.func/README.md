# tools.func Documentation

## Overview

The `tools.func` file provides a comprehensive collection of helper functions for robust package management, repository management, and tool installation in Debian/Ubuntu-based systems. It is the central hub for installing services, databases, programming languages, and development tools in containers.

## Purpose and Use Cases

- **Package Management**: Robust APT/DPKG operations with retry logic
- **Repository Setup**: Prepare and configure package repositories safely
- **Tool Installation**: Install 30+ tools (Node.js, PHP, databases, etc.)
- **Dependency Handling**: Manage complex installation workflows
- **Error Recovery**: Automatic recovery from network failures

## Quick Reference

### Key Function Groups

- **Package Helpers**: `pkg_install()`, `pkg_update()`, `pkg_remove()` - APT operations with retry
- **Repository Setup**: `setup_deb822_repo()` - Modern repository configuration
- **Tool Installation**: `setup_nodejs()`, `setup_php()`, `setup_mariadb()`, etc. - 30+ tool functions
- **System Utilities**: `disable_wait_online()`, `customize()` - System optimization
- **Container Setup**: `setting_up_container()`, `motd_ssh()` - Container initialization

### Dependencies

- **External**: `curl`, `wget`, `apt-get`, `gpg`
- **Internal**: Uses functions from `core.func`, `install.func`, `error_handler.func`

### Integration Points

- Used by: All install scripts for dependency installation
- Uses: Environment variables from build.func and core.func
- Provides: Tool installation, package management, and repository services

## Documentation Files

### 📊 [TOOLS_FUNC_FLOWCHART.md](./TOOLS_FUNC_FLOWCHART.md)

Visual execution flows showing package management, tool installation, and repository setup workflows.

### 📚 [TOOLS_FUNC_FUNCTIONS_REFERENCE.md](./TOOLS_FUNC_FUNCTIONS_REFERENCE.md)

Complete alphabetical reference of all 30+ functions with parameters, dependencies, and usage details.

### 💡 [TOOLS_FUNC_USAGE_EXAMPLES.md](./TOOLS_FUNC_USAGE_EXAMPLES.md)

Practical examples showing how to use tool installation functions and common patterns.

### 🔗 [TOOLS_FUNC_INTEGRATION.md](./TOOLS_FUNC_INTEGRATION.md)

How tools.func integrates with other components and provides package/tool services.

### 🔧 [TOOLS_FUNC_ENVIRONMENT_VARIABLES.md](./TOOLS_FUNC_ENVIRONMENT_VARIABLES.md)

Complete reference of environment variables and configuration options.

## Key Features

### Robust Package Management

- **Automatic Retry Logic**: 3 attempts with backoff for transient failures
- **Silent Mode**: Suppress output with `$STD` variable
- **Error Recovery**: Automatic cleanup of broken packages
- **Atomic Operations**: Ensure consistent state even on failure

### Tool Installation Coverage

- **Node.js Ecosystem**: Node.js, npm, yarn, pnpm
- **PHP Stack**: PHP-FPM, PHP-CLI, Composer
- **Databases**: MariaDB, PostgreSQL, MongoDB
- **Development Tools**: Git, build-essential, Docker
- **Monitoring**: Grafana, Prometheus, Telegraf
- **And 20+ more...**

### Repository Management

- **Deb822 Format**: Modern standardized repository format
- **Keyring Handling**: Automatic GPG key management
- **Cleanup**: Removes legacy repositories and keyrings
- **Validation**: Verifies repository accessibility before use

## Common Usage Patterns

### Installing a Tool

```bash
setup_nodejs "20"     # Install Node.js v20
setup_php "8.2"       # Install PHP 8.2
setup_mariadb         # Install MariaDB (distribution packages)
# MARIADB_VERSION="11.4" setup_mariadb  # Specific version from official repo
```

### Safe Package Operations

```bash
pkg_update           # Update package lists with retry
pkg_install curl wget  # Install packages safely
pkg_remove old-tool   # Remove package cleanly
```

### Setting Up Repositories

```bash
setup_deb822_repo "ppa:example/ppa" "example-app" "jammy" "http://example.com" "release"
```

## Function Categories

### 🔹 Core Package Functions

- `pkg_install()` - Install packages with retry logic
- `pkg_update()` - Update package lists safely
- `pkg_remove()` - Remove packages completely

### 🔹 Repository Functions

- `setup_deb822_repo()` - Add repository in deb822 format
- `cleanup_repo_metadata()` - Clean GPG keys and old repos
- `check_repository()` - Verify repository is accessible

### 🔹 Tool Installation Functions (30+)

**Programming Languages**:

- `setup_nodejs()` - Node.js with npm
- `setup_php()` - PHP-FPM and CLI
- `setup_python()` - Python 3 with pip
- `setup_ruby()` - Ruby with gem
- `setup_golang()` - Go programming language

**Databases**:

- `setup_mariadb()` - MariaDB server
- `setup_postgresql()` - PostgreSQL database
- `setup_mongodb()` - MongoDB NoSQL
- `setup_redis()` - Redis cache

**Web Servers & Proxies**:

- `setup_nginx()` - Nginx web server
- `setup_apache()` - Apache HTTP server
- `setup_caddy()` - Caddy web server
- `setup_traefik()` - Traefik reverse proxy

**Containers & Virtualization**:

- `setup_docker()` - Docker container runtime
- `setup_podman()` - Podman container runtime

**Development & System Tools**:

- `setup_git()` - Git version control
- `setup_docker_compose()` - Docker Compose
- `setup_composer()` - PHP dependency manager
- `setup_build_tools()` - C/C++ compilation tools

**Monitoring & Logging**:

- `setup_grafana()` - Grafana dashboards
- `setup_prometheus()` - Prometheus monitoring
- `setup_telegraf()` - Telegraf metrics collector

### 🔹 System Configuration Functions

- `setting_up_container()` - Container initialization message
- `network_check()` - Verify network connectivity
- `update_os()` - Update OS packages safely
- `customize()` - Apply container customizations
- `motd_ssh()` - Configure SSH and MOTD
- `cleanup_lxc()` - Final container cleanup

## Best Practices

### ✅ DO

- Use `$STD` to suppress output in production scripts
- Chain multiple tool installations together
- Check for tool availability before using
- Use version parameters when available
- Test new repositories before production use

### ❌ DON'T

- Mix package managers (apt and apk in same script)
- Hardcode tool versions directly
- Skip error checking on package operations
- Use `apt-get install -y` without `$STD`
- Leave temporary files after installation

## Recent Updates

### Version 2.0 (Dec 2025)

- ✅ Added `setup_deb822_repo()` for modern repository format
- ✅ Improved error handling with automatic cleanup
- ✅ Added 5 new tool installation functions
- ✅ Enhanced package retry logic with backoff
- ✅ Standardized tool version handling

## Integration with Other Functions

```
tools.func
    ├── Uses: core.func (messaging, colors)
    ├── Uses: error_handler.func (exit codes, trapping)
    ├── Uses: install.func (network_check, update_os)
    │
    └── Used by: All install/*.sh scripts
        ├── For: Package installation
        ├── For: Tool setup
        └── For: Repository management
```

## Troubleshooting

### "Package manager is locked"

```bash
# Wait for apt lock to release
sleep 10
pkg_update
```

### "GPG key not found"

```bash
# Repository setup will handle this automatically
# If manual fix needed:
cleanup_repo_metadata
setup_deb822_repo ...
```

### "Tool installation failed"

```bash
# Enable verbose output
export var_verbose="yes"
setup_nodejs "20"
```

## Contributing

When adding new tool installation functions:

1. Follow the `setup_TOOLNAME()` naming convention
2. Accept version as first parameter
3. Check if tool already installed
4. Use `$STD` for output suppression
5. Set version file: `/opt/TOOLNAME_version.txt`
6. Document in TOOLS_FUNC_FUNCTIONS_REFERENCE.md

## Related Documentation

- **[build.func/](../build.func/)** - Container creation orchestrator
- **[core.func/](../core.func/)** - Utility functions and messaging
- **[install.func/](../install.func/)** - Installation workflow management
- **[error_handler.func/](../error_handler.func/)** - Error handling and recovery
- **[UPDATED_APP-install.md](../../UPDATED_APP-install.md)** - Application script guide

---

**Last Updated**: December 2025
**Maintainers**: community-scripts team
**License**: MIT
