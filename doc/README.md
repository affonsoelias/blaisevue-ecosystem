# 📚 BlaiseVue Ecosystem Documentation

Bem-vindo à documentação oficial do repositório **`blaisevue-ecosystem`**!

Este repositório é o centro oficial da comunidade para pacotes, extensões, bibliotecas gráficas pesadas (como Three.js, Plotly.js, Leaflet) e plugins adicionais para o framework [BlaiseVue](https://github.com/affonsoelias/BlaiseVue).

---

## 🧭 Guias e Manuais Disponíveis

| Documento | Descrição |
|---|---|
| 🚀 [**01. Primeiros Passos e Uso do Ecossistema**](01-getting-started.md) | Como consumir, instalar, atualizar e remover pacotes utilizando o BlaiseVue CLI. |
| 🧩 [**02. Anatomia de um Pacote BlaiseVue**](02-package-anatomy.md) | Estrutura de arquivos, `package.json`, units Pascal, componentes `.bv` e scripts `setup.pas`. |
| 🛠️ [**03. Criando um Novo Pacote**](03-creating-packages.md) | Passo a passo para criar sua biblioteca com `bv create --lib`, desenvolver em sandbox isolado e testar. |
| 📦 [**04. Empacotamento, Releases e Publicação**](04-packaging-and-publishing.md) | Como gerar arquivos `.zip` com `bv lib pack`, criar GitHub Releases com tags prefixadas e atualizar o `ecosystem.json`. |
| 🌐 [**05. Criando Registros Próprios ou Privados**](05-custom-registries.md) | Como empresas e desenvolvedores podem hospedar seus próprios repositórios de pacotes compatíveis com o BlaiseVue. |

---

## 🌟 Princípios de Design do Ecossistema

1. **Zero Bloat no Core**: O repositório principal do BlaiseVue permanece leve, rápido para clonar e compilar.
2. **Versionamento SemVer Rígido**: Suporte completo a tags de versões históricas (`<pacote>@<versão>`) via GitHub Releases.
3. **Cache Global Offline**: Pacotes baixados são cacheados em `~/.blaisevue/packages/`, permitindo novas instalações instantâneas em qualquer projeto sem precisar de internet.
4. **Isolamento e Segurança de Update**: Pacotes baixados nunca poluem a árvore de trabalho git do SDK do BlaiseVue, garantindo que o comando `bv self-update` nunca sofra conflitos de merge.
