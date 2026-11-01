# 🛠️ 03. Criando um Novo Pacote

O BlaiseVue possui um gerador dedicado para criar bibliotecas e componentes isolados com suporte a ambiente de sandbox, testes unitários e empacotamento integrado.

---

## 🏗️ 1. Gerando a Estrutura da Biblioteca

Para iniciar um novo pacote, utilize a flag `--lib` no comando `bv create`:

```bash
bv create meu-widget --lib
```

### Escolha Interativa de Licença
O CLI solicitará a licença de software que você deseja utilizar:
- **MIT** (Padrão permissivo)
- **Apache-2.0**
- **LGPL-3.0** (Ideal para bibliotecas compartilhadas)
- **GPL-3.0**
- **BSD-3-Clause**
- **Commercial**

> **Dica para CI/CD**: Você pode especificar a licença de forma não-interativa adicionando `--license <tipo>`:
> ```bash
> bv create meu-widget --lib --license mit
> ```

---

## 📂 2. O que é gerado na biblioteca:

```text
meu-widget/
├── src/
│   ├── BVMeuWidget.bv      # Componente BlaiseVue inicial
│   └── MeuWidget.pas       # Unit Pascal com lógica e tipos
├── styles/
│   └── meu-widget.css      # Estilos CSS isolados
├── demo/
│   ├── index.html          # Sandbox para testar o componente no navegador
│   └── App.bv              # Aplicação de demonstração interativa
├── tests/
│   └── MeuWidget.test.pas  # Suíte de testes unitários
├── package.json            # Metadados e versão SemVer
├── LICENSE                 # Arquivo formal da licença escolhida
└── README.md               # Documentação inicial
```

---

## 🧪 3. Desenvolvendo em Sandbox com HMR

Entre no diretório da biblioteca e execute o servidor de desenvolvimento:

```bash
cd meu-widget
bv dev
```

O servidor iniciará em `http://localhost:8080` com Hot Reloading (HMR) automático:
- Qualquer alteração no seu componente em `src/BVMeuWidget.bv` ou nos estilos em `styles/` será refletida instantaneamente no navegador dentro da página de sandbox `demo/`.

---

## ✅ 4. Escrevendo e Rodando Testes

Crie testes unitários para a sua biblioteca em `tests/`:

```pascal
unit MeuWidget.test;
{$mode objfpc}{$H+}

interface
uses SysUtils, Classes;

type
  TTestMeuWidget = class
  published
    procedure TestInicializacao;
  end;

implementation

procedure TTestMeuWidget.TestInicializacao;
begin
  WriteLn('  [TEST] Validando estado inicial...');
  // Assegura comportamento esperado
end;

end.
```

Para rodar todos os testes automatizados da biblioteca:
```bash
bv test
```

Antes de qualquer empacotamento para release, o CLI roda automaticamente esses testes para garantir que nenhum bug seja distribuído para os usuários.
