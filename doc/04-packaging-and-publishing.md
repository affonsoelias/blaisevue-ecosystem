# 📦 04. Empacotamento, Releases e Publicação

Este guia explica o fluxo completo para empacotar sua biblioteca, publicar os binários no GitHub Releases e submeter seu pacote ao catálogo oficial `blaisevue-ecosystem`.

---

## 📦 1. Empacotando a Biblioteca (`bv lib pack`)

Quando sua biblioteca estiver pronta para ser distribuída, execute o comando de empacotamento na raiz do pacote:

```bash
bv lib pack
# ou alias:
bv lib dist
```

### O que o comando faz:
1. **Verificação Pré-voo (Pre-flight Tests)**: Roda automaticamente `bv test`. Se algum teste falhar, o processo é abortado imediatamente para impedir lançamentos defeituosos.
2. **Filtragem de Produção**: Descarta arquivos desnecessários (`.git`, `node_modules`, arquivos de compilação `.o`, `.ppu`, `.tmp`).
3. **Geração do ZIP**: Cria o artefato compactado em `dist/<nome>-<versao>.zip`.
4. **Assinatura de Integridade (SHA-256)**: Gera o hash criptográfico do arquivo em `dist/<nome>-<versao>.zip.sha256`.

> **Dica**: Se quiser pular a execução de testes durante o empacotamento em scripts locais, passe a flag `--skip-tests`:
> ```bash
> bv lib pack --skip-tests
> ```

---

## 🏷️ 2. Criando o Release no GitHub

O ecossistema BlaiseVue utiliza tags prefixadas para suportar tanto repositórios dedicados quanto monorepositórios com múltiplos pacotes.

### Convenção de Tags:
- Padrão da Tag: `<nome-do-pacote>@<versao>`
- Exemplo: `test@1.0.0`, `meu-widget@2.1.0`

### Publicando o Release via GitHub CLI (`gh`):
```bash
gh release create "meu-widget@1.0.0" dist/meu-widget-1.0.0.zip \
  --title "meu-widget v1.0.0" \
  --notes "Primeiro lançamento oficial do meu-widget com suporte a gráficos reativos."
```

Ou acesse a aba **Releases** do seu repositório no GitHub, clique em **Draft a new release**, crie a tag `meu-widget@1.0.0` e faça o upload do arquivo `dist/meu-widget-1.0.0.zip`.

---

## 🌐 3. Registrando o Pacote no `ecosystem.json`

Para que qualquer usuário no mundo possa instalar seu pacote digitando `bv lib install meu-widget`, adicione a entrada da sua biblioteca no arquivo `ecosystem.json` do repositório `blaisevue-ecosystem`:

```json
{
  "name": "blaisevue-ecosystem",
  "description": "Official community ecosystem and library registry for BlaiseVue",
  "version": "1.0.0",
  "packages": {
    "meu-widget": {
      "name": "meu-widget",
      "description": "Componentes de gráficos e dashboards reativos para BlaiseVue",
      "latest": "1.0.0",
      "versions": ["1.0.0"],
      "download": "https://github.com/seu-usuario/seu-repositorio/releases/download/{tag}/{package}-{version}.zip"
    }
  }
}
```

### Placeholders do Template de Download:
- `{tag}` $\rightarrow$ Substituído pela tag correspondente (ex: `meu-widget@1.0.0`)
- `{package}` $\rightarrow$ Nome do pacote (ex: `meu-widget`)
- `{version}` $\rightarrow$ Versão solicitada (ex: `1.0.0`)

---

## 🚀 4. Submetendo via Pull Request

1. Faça um Fork do repositório [`blaisevue-ecosystem`](https://github.com/affonsoelias/blaisevue-ecosystem).
2. Adicione sua entrada no `ecosystem.json`.
3. Abra um Pull Request para a branch `main`.
4. Assim que o PR for aprovado e mesclado, todos os usuários do BlaiseVue receberão seu pacote instantaneamente no próximo `bv repo sync`!
