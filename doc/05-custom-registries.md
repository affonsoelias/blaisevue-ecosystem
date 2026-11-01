# 🌐 05. Criando Registros Próprios ou Privados

O BlaiseVue foi projetado para ser totalmente descentralizado. Empresas e grupos de desenvolvedores podem criar seus próprios registros e ecossistemas privados de pacotes internos sem depender do repositório oficial da comunidade.

---

## 🏗️ 1. O que é um Registro BlaiseVue?

Um registro de pacotes BlaiseVue é qualquer servidor HTTP/HTTPS ou repositório Git público ou privado que sirva um arquivo `ecosystem.json`.

Exemplo mínimo de `ecosystem.json`:
```json
{
  "name": "acme-corp-packages",
  "description": "Repositório privado de pacotes e componentes internos da ACME Corp",
  "version": "1.0.0",
  "packages": {
    "acme-ui-auth": {
      "name": "acme-ui-auth",
      "description": "Componente corporativo de autenticação SSO e MFA",
      "latest": "2.4.0",
      "versions": ["2.3.0", "2.4.0"],
      "download": "https://github.com/acme-corp/acme-packages/releases/download/{tag}/{package}-{version}.zip"
    }
  }
}
```

---

## 🔗 2. Cadastrando o Repositório no CLI (`bv repo add`)

Cada desenvolvedor da equipe pode adicionar o repositório privado utilizando o comando `bv repo add`:

```bash
bv repo add acme https://github.com/acme-corp/acme-packages
```

### URLs Suportadas:
- Repositórios no GitHub: `https://github.com/usuario/repositorio`
- Servidores web internos: `https://nexus.intranet.corp/blaisevue/ecosystem.json`

---

## 🎯 3. Definindo o Repositório Padrão (`bv repo default`)

Se você deseja que o CLI procure pacotes primeiro no registro da sua empresa:

```bash
bv repo default acme
```

Para verificar quais repositórios estão ativos:
```bash
bv repo list
```

**Exemplo de saída:**
```text
=== BlaiseVue Package Repositories ===
Config: C:\Users\Pichau\.blaisevue\repos.json

  * acme (default)
      URL:  https://github.com/acme-corp/acme-packages
      Type: ecosystem

    official
      URL:  https://github.com/affonsoelias/blaisevue-ecosystem
      Type: ecosystem

Total: 2 repositorio(s) configurado(s).
```

---

## 🔄 4. Sincronizando e Buscando Pacotes

Para atualizar o cache local de metadados com todas as fontes cadastradas:

```bash
bv repo sync
```

O CLI baixará o `ecosystem.json` de cada repositório e salvará em `~/.blaisevue/cache/<nome>-ecosystem.json`.

Agora, qualquer comando de busca ou instalação encontrará tanto os pacotes públicos quanto os privados:
```bash
bv lib search acme
bv lib install acme-ui-auth
```
