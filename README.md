# ROTA — Checkpoint 5

Protótipo funcional do **ROTA**: o mapa visual de carga acadêmica. O estudante vê o peso das próximas semanas e é avisado **antes** de uma semana virar caos.

Este repositório sai do papel do CP4. As telas navegam, os dados são realistas e o app roda no Chrome, no emulador Android e no Windows.

## Equipe

| Nome | RM | Papel no projeto |
| --- | --- | --- |
| Bruno Otávio da Cruz Carvalho | 562354 | Código: arquitetura de dados (`RotaStore`, cálculo de carga) e integração com Supabase |
| Letícia Gabrielle Andrade Temóteo | 563985 | Código: telas e widgets, fidelidade ao Figma do CP4 |
| João Vitor Santana Silva Ribeiro | 564693 | Código: navegação entre telas, ambiente de teste (Chrome, Android, Windows) e testes |
| Rafael Quattrer Dalla Costa | 562052 | Design: Figma, identidade visual e frames das telas novas do CP5 |
| Rafael Louzã Lopes | 564963 | Produto e documentação: dados mockados, README, pitch e decisões técnicas |

**Proposta de valor:** traduzir prazos acadêmicos em um mapa visual de carga e avisar, com antecedência, quando uma semana está ficando pesada.

## O que dá para demonstrar em aula

1. Tela de abertura com a marca ROTA.
2. Dashboard com as 4 barras de carga (leve, média, crítica, média).
3. Alerta da **Semana 3 crítica** (2 Checkpoints + Global Solution).
4. Cadastro de uma nova entrega pelo botão **+**.
5. Toque em uma barra, em um card ou em **Ver detalhes**.
6. Marcar como concluída e ver o mapa de carga mudar.
7. Perfil, lista com filtros (pendentes, concluídas, atrasadas) e reset da demonstração.

No Chrome, o app aparece em um recorte de celular, no mesmo formato dos frames do Figma.

## Figma (CP4)

Arquivo da equipe: [ROTA no Figma](https://www.figma.com/design/9tvU9QUR9S9MAf3zxkwwlq/Sem-t%C3%ADtulo?node-id=5-24).

O protótipo segue esses frames (abertura e dashboard). As telas novas do CP5 usam a mesma paleta.

**Para atualizar o Figma na mão:** abra `docs/figma-cp5.md` e arraste as 5 imagens de `docs/figma-cp5/` para o arquivo. São cerca de 8 cliques por tela.

## Como rodar

### 1. Instalar o Flutter

[flutter.dev/install](https://docs.flutter.dev/get-started/install). No terminal:

```bash
flutter doctor
```

Web, Android e Windows precisam estar ok para a apresentação. Chrome já serve.

### 2. Abrir este repositório

```bash
git clone <url-deste-repo>
cd <pasta-do-repo>
flutter pub get
```

O projeto aceita Dart 3.11 ou mais novo. Não precisa atualizar o Flutter só para o `pub get` passar.

### 3. Chrome (caminho mais rápido para a aula)

```bash
flutter run -d chrome
```

Se o professor pedir Windows:

```bash
flutter run -d windows
```

### 4. Android Studio (emulador)

1. Abra a pasta do projeto no Android Studio (ou rode pelo terminal).
2. Suba um emulador Pixel / API 34, retrato.
3. Execute:

```bash
flutter run -d android
```

O nome do app no launcher é **ROTA**.

## Dados mockados

O semestre da demonstração está **travado em 21/09/2026** (segunda-feira). Assim o mapa não muda no meio da apresentação.

| Semana | Período | Carga | Por quê |
| --- | --- | --- | --- |
| Sem 1 | 08 a 14 Set | Leve | Leitura e histórico já concluído |
| Sem 2 | 15 a 21 Set | Média | Quiz + infográfico atrasado |
| Sem 3 | 22 a 28 Set | Crítica | Projeto Figma, 2 Checkpoints e Global Solution |
| Sem 4 | 29 Set a 05 Out | Média | Projeto de Dados + seminário |

Casos cobertos de propósito: prioridade baixa/média/alta, atrasada, concluída, futura, semana vazia de pendências e semana crítica.

Os dados ficam salvos neste aparelho. No perfil, **Resetar dados de demonstração** volta o semestre mockado.

## Integração com Supabase

O protótipo **não depende** do banco para a aula. Sem URL, ele usa os dados locais.

Para ligar o banco (cerca de 5 minutos):

1. Crie um projeto em [supabase.com](https://supabase.com) (plano gratuito).
2. No **SQL Editor**, cole e rode `supabase/schema.sql`. Ele cria a tabela `deliveries`, os GRANTs e as políticas.
3. Em **Project Settings → API**, copie a **Project URL** e a **Publishable key**.
4. Cole as duas em `lib/core/app_config.dart` (`defaultValue` de `SUPABASE_URL` e `SUPABASE_ANON_KEY`).
5. Rode normalmente:

```bash
flutter run -d chrome
```

Na primeira execução, com a tabela vazia, o app grava o semestre mockado no banco. Dá para conferir em **Table Editor → deliveries**. O perfil mostra de onde vêm os dados: "Dados sincronizados com o Supabase" ou "Dados salvos neste aparelho".

Se o Supabase falhar, o app cai para os dados locais e avisa no dashboard.

Também dá para passar a URL e a chave sem editar o código:

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://SEU_PROJETO.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_...
```

Dois cuidados que já estão no código:

- A chave publicável (`sb_publishable_...`) vai só no header `apikey`. Ela não é um JWT e não pode ir em `Authorization: Bearer`.
- Projetos novos do Supabase não expõem tabelas à API sem `GRANT` explícito. O `schema.sql` já faz isso.

As políticas de RLS estão abertas de propósito: o CP5 não tem login. Isso é só para o protótipo.

## Fluxo de telas

```
Abertura
  → Dashboard (mapa de carga + próximas entregas)
      → Modal Nova Entrega (+)
      → Detalhe da semana (toque na barra)
      → Detalhe da entrega (toque no card)
      → Alerta da semana crítica (Ver detalhes)
      → Perfil (avatar)
          → Lista de todas as entregas (filtros)
```

## Decisões desde o CP4

A estrutura combinada no CP4 foi mantida: `lib/core`, `lib/screens`, `lib/widgets`. O que entrou no CP5:

- **Dados com dono.** `RotaStore` concentra o semestre. As telas só escutam. O mapa de carga é calculado, não desenhado na mão.
- **Mock primeiro, banco depois.** A aula precisa funcionar offline. Supabase é um repositório opcional por HTTP, sem SDK pesado.
- **Fidelidade visual, calendário coerente.** Paleta, Poppins, cápsulas, tags e modal seguem o Figma do CP4. As datas de janeiro do protótipo visual foram trocadas por setembro/outubro de 2026, alinhadas às entregas (Figma, Checkpoints, GS).
- **Telas a mais, no mesmo visual.** O CP4 tinha abertura, dashboard e modal. Para o fluxo ficar completo, entrou detalhe da semana, da entrega, do alerta, perfil e lista.
- **Chrome como ambiente de teste principal.** Atende o critério de execução via Windows/Chrome. Android e Windows continuam no projeto gerado pelo Flutter.

Detalhes em [docs/cp5-decisoes-tecnicas.md](docs/cp5-decisoes-tecnicas.md). Especificação das telas novas para o Figma em [docs/figma-cp5.md](docs/figma-cp5.md).

## Identidade visual

Paleta do CP4, sem invenção:

| Função | Cor |
| --- | --- |
| Azul principal | `#2864E8` |
| Fundo | `#0E172A` |
| Superfícies | `#202A45` |
| Texto | `#F4F6FA` |
| Baixa / sucesso | `#42D5A4` |
| Média | `#4F8EF7` |
| Alta | `#FF6961` |
| Crítica | `#73373C` |

Tipografia: **Poppins**, já no repositório em `assets/fonts`.

## Documentos do CP4

Os textos originais da equipe estão em `docs/cp4/`.
