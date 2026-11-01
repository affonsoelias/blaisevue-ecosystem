# 🧩 02. Anatomia de um Pacote BlaiseVue

Um pacote BlaiseVue é um módulo reutilizável contendo componentes Single-File (`.bv`), units Object Pascal (`.pas`), arquivos de estilo CSS, scripts e metadados.

---

## 📁 Estrutura de Diretórios Recomendada

Um pacote distribuível segue a seguinte convenção:

```text
meu-pacote/
├── package.json         # Manifesto obrigatório de metadados e versão
├── README.md            # Documentação e instruções de uso do componente
├── LICENSE              # Licença do código (MIT, Apache-2.0, LGPL, etc.)
├── setup.pas            # (Opcional) Script Pascal de setup executado na instalação
├── MeuPacote.pas        # Unit principal Pascal (classes, tipos, helpers)
├── BVMeuBotao.bv        # Componente SFC BlaiseVue (.bv)
├── styles/              # (Opcional) Estilos CSS da biblioteca
│   └── meu-pacote.css
└── tests/               # (Opcional) Testes unitários do pacote
    └── MeuPacote.test.pas
```

---

## 📄 O Arquivo `package.json`

O arquivo `package.json` na raiz da biblioteca identifica o pacote para o CLI do BlaiseVue e para o ecossistema:

```json
{
  "name": "meu-pacote",
  "version": "1.0.0",
  "description": "Componentes de gráficos e dashboards reativos para BlaiseVue",
  "main": "MeuPacote.pas",
  "author": "Seu Nome <seu-email@dominio.com>",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/usuario/meu-pacote"
  },
  "keywords": [
    "blaisevue",
    "charts",
    "ui",
    "components"
  ]
}
```

### Campos Importantes:
- **`name`**: Nome único do pacote (letras minúsculas e hífens).
- **`version`**: Versão no formato SemVer (`MAJOR.MINOR.PATCH`).
- **`description`**: Breve resumo que aparecerá nas buscas (`bv lib search`).
- **`main`**: Unit Pascal principal que exporta os tipos ou componentes.
- **`license`**: Identificador SPDX da licença (MIT, Apache-2.0, LGPL-3.0, etc.).

---

## ⚙️ O Script de Ciclo de Vida `setup.pas` (Opcional)

Se o seu pacote precisar configurar recursos adicionais no projeto do usuário durante a instalação ou limpeza durante a remoção, você pode incluir um script `setup.pas`:

```pascal
program setup;
uses SysUtils;

var
  Action: string;
begin
  if ParamCount > 0 then
    Action := LowerCase(ParamStr(1))
  else
    Action := 'install';

  if Action = 'install' then
  begin
    WriteLn('  [Setup] Configurando recursos adicionais de meu-pacote...');
    // Realiza ações customizadas de inicialização
  end
  else if Action = 'remove' then
  begin
    WriteLn('  [Setup] Limpando arquivos temporários de meu-pacote...');
    // Realiza ações de desinstalação
  end;
end.
```

O CLI do BlaiseVue detecta automaticamente a presença do `setup.pas` e executa:
- `setup.pas install` ao instalar o pacote via `bv lib install`.
- `setup.pas remove` ao desinstalar o pacote via `bv lib remove`.

---

## 🎨 Injeção Automática de Recursos

Quando uma biblioteca é instalada na pasta `lib/<pacote>/`:
1. **Componentes `.bv`**: O compilador do BlaiseVue escaneia recursivamente a pasta `lib/` e registra todos os componentes `.bv` globalmente de forma automática.
2. **Estilos `.css`**: Arquivos CSS presentes em `lib/` são detectados e injetados automaticamente no `index.html` gerado para produção.
3. **Scripts `.js`**: Arquivos JavaScript de bibliotecas terceiras (como Chart.js ou Three.js minificados) colocados em `lib/` são copiados para `dist/js/lib/` e vinculados no HTML de produção.
