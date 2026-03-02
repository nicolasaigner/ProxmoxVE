# Referência de Códigos de Saída

Documentação completa de todos os códigos de saída usados ​​nos scripts do ProxmoxVE.

## Sumário

- [Erros Genéricos/Shell (1-255)](#genericshell-errors)
- [Erros do Gerenciador de Pacotes (100-101, 255)](#package-manager-errors)
- [Erros do Node.js/npm (243-254)](#nodejsnpm-errors)
- [Erros do Python/pip (210-212)](#pythonpip-errors)
- [Erros do Banco de Dados (231-254)](#database-errors)
- [Códigos Personalizados do Proxmox (200-231)](#proxmox-custom-codes)

---

## Erros Genéricos/Shell

Códigos de saída padrão do Unix/Linux usados ​​em todos os scripts.

| Código  | Descrição                                   | Causas Comuns                         | Soluções                                                            |
| ------- | ------------------------------------------- | ------------------------------------- | ------------------------------------------------------------------- | --- | ------- | -------------------- | ------------------------------------------------ | ------------------------------------------------------- |
| **1**   | Erro geral / Operação não permitida         | Permissão negada, falha geral         | Verifique as permissões do usuário, execute como root se necessário |
| **2**   | Uso incorreto de comandos internos do shell | Erro de sintaxe no script             | Revise a sintaxe do script, verifique a versão do bash              |
| **126** | O comando não pode ser executado            | Problema de permissão, não executável | `chmod +x script.sh` ou verifique as permissões do arquivo          |
| **127** | Comando não encontrado                      | Binário ausente, PATH incorreto       | Instale o pacote necessário, verifique a variável PATH              |
| **128** | Argumento inválido para sair                | Código de saída inválido              | Use apenas códigos de saída de 0 a 255                              |
| **130** | Terminado por Ctrl+C (SIGINT)               | Script interrompido pelo usuário      | Comportamento esperado, nenhuma ação necessária                     |
| **137** | Morto (SIGKILL)                             | Memória insuficiente, término forçado | Verifique o uso de memória, aumente a alocação de RAM               |     | **139** | Falha de segmentação | Violação de acesso à memória, binário corrompido | Reinstale o pacote, verifique a estabilidade do sistema |
| **143** | Terminado (SIGTERM)                         | Sinal de desligamento normal          | Esperado durante paradas de contêineres                             |

---

## Erros do Gerenciador de Pacotes

Erros de instalação de APT, DPKG e pacotes.

| Código  | Descrição                           | Causas Comuns                                                  | Soluções                                                |
| ------- | ----------------------------------- | -------------------------------------------------------------- | ------------------------------------------------------- |
| **100** | APT: Erro no gerenciador de pacotes | Pacotes quebrados, conflitos de dependência                    | `apt --fix-broken install`, `dpkg --configure -a`       |
| **101** | APT: Erro de configuração           | sources.list malformado, configuração de repositório incorreta | Verifique `/etc/apt/sources.list`, execute `apt update` |
| **255** | DPKG: Erro interno fatal            | Banco de dados de pacotes corrompido                           | `dpkg --configure -a`, restaurar a partir do backup     |

---

## Erros do Node.js/npm

Erros de tempo de execução e do gerenciador de pacotes do Node.js.

| Código  | Descrição                                      | Causas Comuns                            | Soluções                                                  |
| ------- | ---------------------------------------------- | ---------------------------------------- | --------------------------------------------------------- |
| **243** | Node.js: Memória insuficiente                  | Heap do JavaScript esgotado              | Aumente `--max-old-space-size`, otimize o código          |
| **245** | Node.js: Opção de linha de comando inválida    | Flags do Node.js incorretas              | Verifique a versão do Node.js, verifique as opções da CLI |
| **246** | Node.js: Erro interno de análise do JavaScript | Erro de sintaxe no código JS             | Revise a sintaxe do JavaScript, verifique as dependências |
| **247** | Node.js: Erro interno fatal                    | Falha no tempo de execução do Node.js    | Atualize o Node.js, verifique se há bugs conhecidos       |
| **248** | Node.js: Addon C++ inválido / Falha na N-API   | Incompatibilidade de módulo nativo       | Recompile os módulos nativos, atualize os pacotes         |
| **249** | Node.js: Erro do inspetor                      | Falha no protocolo de depuração/inspeção | Desative o inspetor, verifique conflitos de porta         |
| **254** | npm/pnpm/yarn: Erro fatal desconhecido         | Falha no gerenciador de pacotes          | Limpe o cache, reinstale o gerenciador de pacotes         |

---

## Erros do Python/pip

Erros de tempo de execução do Python e de instalação de pacotes.

| Código  | Descrição                                  | Causas Comuns                             | Soluções                                                       |
| ------- | ------------------------------------------ | ----------------------------------------- | -------------------------------------------------------------- |
| **210** | Python: Virtualenv ausente ou corrompido   | venv não criado, ambiente corrompido      | `python3 -m venv venv`, recrie o virtualenv                    |
| **211** | Python: Falha na resolução de dependências | Versões de pacotes conflitantes           | Use `pip install --upgrade`, verifique requirements.txt        |
| **212** | Python: Instalação abortada                | GERENCIADO EXTERNAMENTE, permissão negada | Use `--break-system-packages` ou venv, verifique as permissões |

---

## Erros de Banco de Dados

### PostgreSQL (231-234)

| Código  | Descrição                 | Causas Comuns                                   | Soluções                                                    |
| ------- | ------------------------- | ----------------------------------------------- | ----------------------------------------------------------- |
| **231** | Falha na conexão          | Servidor não está em execução, socket incorreto | `systemctl start postgresql`, verifique a string de conexão |
| **232** | Falha na autenticação     | Credenciais incorretas                          | Verifique o nome de usuário/senha, verifique `pg_hba.conf`  |
| **233** | Banco de dados não existe | Banco de dados não criado                       | `CREATE DATABASE`, restaure a partir do backup              |
| **234** | Erro fatal na consulta    | Erro de sintaxe, violação de restrição          | Revise a sintaxe SQL, verifique as restrições               |

### MySQL/MariaDB (241-244)

| Código  | Descrição                 | Causas Comuns                                   | Soluções                                                    |
| ------- | ------------------------- | ----------------------------------------------- | ----------------------------------------------------------- |
| **241** | Falha na conexão          | Servidor não está em execução, socket incorreto | `systemctl start mysql`, verifique os parâmetros de conexão |
| **242** | Falha na autenticação     | Credenciais incorretas                          | Verifique o nome de usuário/senha, conceda privilégios      |
| **243** | Banco de dados não existe | Banco de dados não criado                       | `CREATE DATABASE`, restaurar do backup                      |
| **244** | Erro fatal na consulta    | Erro de sintaxe, violação de restrição          | Revisar a sintaxe SQL, verificar restrições                 |

### MongoDB (251-254)

| Código  | Descrição                     | Causas Comuns                 | Soluções                                                   |
| ------- | ----------------------------- | ----------------------------- | ---------------------------------------------------------- |
| **251** | Falha na conexão              | Servidor não está em execução | `systemctl start mongod`, verificar a porta 27017          |
| **252** | Falha na autenticação         | Credenciais incorretas        | Verificar nome de usuário/senha, criar usuário             |
| **253** | Banco de dados não encontrado | Banco de dados não criado     | Banco de dados criado automaticamente na primeira gravação |
| **254** | Erro fatal na consulta        | Sintaxe de consulta inválida  | Revisar a sintaxe da consulta do MongoDB                   |

---

## Códigos personalizados do Proxmox

Códigos de saída personalizados específicos para scripts do ProxmoxVE.

### Erros de criação de contêiner (200-209)

| Código  | Descrição                                         | Causas Comuns                                              | Soluções                                                         |
| ------- | ------------------------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------------------- |
| **200** | Falha ao criar o arquivo de bloqueio              | Permissão negada, disco cheio                              | Verifique as permissões de `/tmp` e o espaço livre em disco      |
| **203** | Variável CTID ausente                             | Erro de configuração do script                             | Defina o CTID no script ou via prompt                            |
| **204** | Variável PCT_OSTYPE ausente                       | Falha na seleção do modelo                                 | Verifique a disponibilidade do modelo                            |
| **205** | CTID inválido (<100)                              | CTID abaixo do valor mínimo                                | Use um CTID ≥ 100 (1-99 reservado para Proxmox)                  |
| **206** | CTID já em uso                                    | Existe um contêiner/VM com o mesmo ID                      | Verifique `pct list` e `/etc/pve/lxc/`, use um ID diferente      |
| **207** | A senha contém caracteres especiais não escapados | Caracteres especiais como `-`, `/`, `\`, `*` no início/fim | Evite caracteres especiais iniciais, use senhas alfanuméricas    |
| **208** | Configuração inválida                             | Formato DNS (`.home` vs `home`), formato MAC (`-` vs `:`)  | Remova os pontos iniciais do DNS, use `:` em endereços MAC       |
| **209** | Falha na criação do contêiner                     | Múltiplas causas possíveis                                 | Verifique os logs em `/tmp/pct_create_*.log`, verifique o modelo |

### Erros de Cluster e Armazenamento (210, 214, 217)

| Código  | Descrição                                              | Causas Comuns                               | Soluções                                                                     |
| ------- | ------------------------------------------------------ | ------------------------------------------- | ---------------------------------------------------------------------------- |
| **210** | Cluster sem quórum                                     | Nós do cluster inativos, problemas de rede  | Verifique o status do cluster: `pvecm status`, corrija a conectividade do nó |
| **211** | Tempo limite excedido ao aguardar o bloqueio do modelo | Download simultâneo em andamento            | Aguarde a conclusão de outro download (tempo limite de 60 segundos)          |
| **214** | Espaço de armazenamento insuficiente                   | Disco cheio, cota excedida                  | Libere espaço em disco, aumente a alocação de armazenamento                  |
| **217** | O armazenamento não suporta diretório raiz             | Tipo de armazenamento incorreto selecionado | Use um armazenamento que suporte contêineres (dir, zfspool, lvm-thin)        |

### Erros de verificação de contêiner (215-216)

| Código  | Descrição                              | Causas comuns                       | Soluções                                                             |
| ------- | -------------------------------------- | ----------------------------------- | -------------------------------------------------------------------- |
| **215** | Contêiner criado, mas não listado      | Estado fantasma, criação incompleta | Verifique `/etc/pve/lxc/CTID.conf`, remova manualmente se necessário |
| **216** | Entrada RootFS ausente na configuração | Criação incompleta do contêiner     | Exclua o contêiner e tente criá-lo novamente                         |

### Erros de modelo (218, 220-223, 225)

| Código  | Descrição                                       | Causas Comuns                                             | Soluções                                                                      |
| ------- | ----------------------------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------- |
| **218** | Arquivo de modelo corrompido ou incompleto      | Download interrompido, arquivo <1MB, arquivo inválido     | Exclua o modelo, execute `pveam update && pveam download`                     |
| **220** | Não foi possível resolver o caminho do modelo   | Armazenamento do modelo inacessível                       | Verifique a disponibilidade do armazenamento, verifique as permissões         |
| **221** | Arquivo de modelo existe, mas não pode ser lido | Permissão negada                                          | `chmod 644 template.tar.zst`, verifique as permissões de armazenamento        |
| **222** | Falha no download do modelo após 3 tentativas   | Problemas de rede, problemas de armazenamento             | Verifique a conectividade com a internet, verifique o espaço de armazenamento |
| **223** | Modelo não disponível após o download           | Problema de sincronização de armazenamento, atraso de E/S | Aguarde alguns segundos, verifique se o armazenamento está montado            |
| **225** | Nenhum modelo disponível para SO/Versão         | Versão do SO não suportada, catálogo desatualizado        | Execute `pveam update`, verifique `pveam available -section system`           |

### Erros da Pilha LXC (231)

| Código  | Descrição                                   | Causas Comuns                                                 | Soluções                                                      |
| ------- | ------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- |
| **231** | Falha na atualização/tentativa da pilha LXC | Pacote `pve-container` desatualizado, problema no Debian 13.1 | Consulte o [Guia de Correção do Debian 13.1](#debian-131-fix) |

---

## Caso Especial: Erro "versão não suportada" no Debian 13.1

### Problema

```
TASK ERROR: unable to create CT 129 - unsupported debian version '13.1'
```

### Causa Raiz

O pacote `pve-container` desatualizado não reconhece o Debian 13 (Trixie).

### Soluções

#### Opção 1: Atualização completa do sistema (recomendada)

```bash
apt update
apt full-upgrade -y
reboot
```

Verificar correção:

```bash
dpkg -l pve-container
# PVE 8: Should show 5.3.3+
# PVE 9: Should show 6.0.13+
```

#### Opção 2: Atualizar apenas o contêiner pve

```bash
apt update
apt install --only-upgrade pve-container -y
```

**Aviso:** Se o Proxmox não inicializar após isso, seu sistema estava inconsistente. Execute a Opção 1.

#### Opção 3: Verificar a configuração do repositório

Muitos usuários desativam os repositórios Enterprise, mas se esquecem de adicionar os repositórios sem assinatura.

**Para PvE 9 (Trixie):**

```bash
cat /etc/apt/sources.list.d/pve-no-subscription.list
```

Deve conter:

```
deb http://download.proxmox.com/debian/pve trixie pve-no-subscription
deb http://download.proxmox.com/debian/ceph-squid trixie no-subscription
```

**Para PvE 8 (Bookworm):**

```
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
deb http://download.proxmox.com/debian/ceph-quincy bookworm no-subscription
```

Então:

```bash
apt update
apt full-upgrade -y
```

### Referência

Discussão oficial: [GitHub #8126](https://github.com/community-scripts/ProxmoxVE/discussions/8126)

---

## Dicas para Solução de Problemas

### Encontrando Detalhes do Erro

1. **Verifique os logs:**

```bash
   tail -n 50 /tmp/pct_create_*.log
```

2. **Ative o modo detalhado:**

```bash
   bash -x script.sh  # Shows every command executed
```

3. **Verifique o status do contêiner:**

```bash
   pct list
   pct status CTID
```

4. **Verificar armazenamento:**

```bash
   pvesm status
   df -h
```

### Padrões Comuns

- **Código de saída 0 com mensagem de erro:** Falha na validação da configuração (verificar DNS, MAC, formato da senha)
- **Código de saída 206, mas o contêiner não está visível:** Estado fantasma do contêiner - verificar `/etc/pve/lxc/` manualmente
- **Código de saída 209 com erro genérico:** Verificar `/tmp/pct_create_*.log` para obter o motivo específico da falha na criação do `pct create`
- **Código de saída 218 ou 222:** Problemas com o modelo - excluir e baixar o modelo novamente

---

## Tabela de Referência Rápida

| Intervalo de Códigos de Saída | Categoria                         | Problema Típico                                |
| ----------------------------- | --------------------------------- | ---------------------------------------------- |
| 1-2, 126-143                  | Shell/Sistema                     | Permissões, sinais, comandos ausentes          |
| 100-101, 255                  | Gerenciador de Pacotes            | Erros APT/DPKG, pacotes corrompidos            |
| 200-209                       | Criação de Contêineres            | CTID, senha, configuração                      |
| 210-217                       | Armazenamento/Cluster             | Espaço em disco, quorum, tipo de armazenamento |
| 218-225                       | Modelos                           | Download, corrupção, disponibilidade           |
| 231-254                       | Bancos de Dados/Tempo de Execução | PostgreSQL, MySQL, MongoDB, Node.js, Python    |

---

## Contribuindo

Encontrou um código de saída não documentado ou tem uma solução para compartilhar? Por favor:

1. Abra uma issue no [GitHub](https://github.com/community-scripts/ProxmoxVE/issues)
2. Inclua:

- Número do código de saída
- Mensagem de erro

- Passos para reproduzir o problema
- Solução que funcionou para você

---

_Última atualização: novembro de 2025_ _Versão do ProxmoxVE: 2.x_
