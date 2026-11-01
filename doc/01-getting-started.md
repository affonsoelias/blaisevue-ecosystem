# 🚀 01. Primeiros Passos e Uso do Ecossistema

Este guia ensina como consumir e utilizar os pacotes do `blaisevue-ecosystem` nos seus projetos BlaiseVue através do CLI nativo (`bv`).

---

## 🔍 1. Pesquisando Pacotes

Você pode pesquisar por palavras-chave ou listar todos os pacotes disponíveis no catálogo:

```bash
# Buscar por um termo específico:
bv lib search chart

# Listar todos os pacotes disponíveis no ecossistema:
bv lib search
```

**Exemplo de saída:**
```text
=== Busca de Pacotes no Ecossistema BlaiseVue ===
Filtro: "chart"
-----------------------------------------------------------------
  * blaise-charts (v1.0.0)
    Descricao: Reusable Chart.js reactive components for BlaiseVue
    Autor: BlaiseVue Core Team

1 pacote(s) encontrado(s). Para instalar, use: bv lib install <nome>
-----------------------------------------------------------------
```

---

## 📥 2. Instalando Pacotes (`bv lib install`)

O comando de instalação do BlaiseVue utiliza um algoritmo de resolução em 4 camadas:

### Instalação no Projeto Local (Padrão)
Instala a biblioteca dentro da pasta `lib/<pacote>/` do seu projeto atual:

```bash
# Instala a versão mais recente (latest):
bv lib install test

# Instala uma versão histórica específica com @version:
bv lib install test@1.0.0
```

### Instalação no Cache Global do Usuário (`--global` / `-g`)
Se você deseja baixar um pacote para tê-lo disponível para qualquer projeto futuro sem internet:

```bash
bv lib install test --global
# ou simplesmente:
bv lib install test -g
```
O pacote será armazenado em `~/.blaisevue/packages/test/`. Quando você rodar `bv lib install test` em qualquer projeto posterior, o CLI copiará os arquivos do cache global em milissegundos sem fazer download da internet.

---

## 📋 3. Listando Pacotes Instalados (`bv lib list`)

```bash
# Listar pacotes instalados no projeto atual (/lib):
bv lib list

# Listar pacotes armazenados no cache global do usuário:
bv lib list --global
```

---

## 🔍 4. Verificando Atualizações (`bv lib outdated`)

Para checar se alguma biblioteca instalada no seu projeto possui uma versão mais nova lançada no ecossistema:

```bash
bv lib outdated
```

**Exemplo de saída:**
```text
=== Verificacao de Versoes de Pacotes (bv lib outdated) ===
Escopo: Local do Projeto (/lib)
------------------------------------------------------------------------------
Pacote                Instalada     Mais Recente    Status                    
------------------------------------------------------------------------------
test                  v1.0.0        v1.1.0          Desatualizado -> v1.1.0
------------------------------------------------------------------------------
1 de 1 pacote(s) desatualizado(s).
Para atualizar, execute: bv lib update
```

---

## 🔄 5. Atualizando Pacotes (`bv lib update`)

```bash
# Atualizar todas as bibliotecas do projeto para suas versões mais recentes:
bv lib update

# Atualizar apenas um pacote específico:
bv lib update test

# Atualizar o cache global do usuário:
bv lib update --global
```

---

## 🗑️ 6. Removendo Pacotes (`bv lib remove`)

```bash
# Remove o pacote do projeto atual (/lib):
bv lib remove test

# Remove o pacote do cache global:
bv lib remove test --global
```

> **Nota de Segurança**: Pacotes oficiais integrados do core do framework (`packages/core/`) são protegidos contra remoção acidental.
