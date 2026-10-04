# Decisões técnicas — CP5

O CP4 definiu marca, paleta, estrutura Flutter e os três frames do Figma (abertura, dashboard, modal). O CP5 precisava sair do papel sem quebrar isso.

## O que não mudou

- Pasta `lib/` como coração do app.
- `core/` para paleta e tema.
- `screens/` para páginas inteiras.
- `widgets/` para peças reutilizáveis (`week_card`, `task_card`, `priority_tag`, `add_task_modal`, `custom_button`, `custom_input`).
- Flutter como stack. Chrome, emulador Android e Windows como alvos de apresentação.

## O que mudou, e por quê

### 1. Cálculo de carga, não desenho estático

No Figma as barras já vinham pintadas. No protótipo, cada entrega tem um peso (baixa 1, média 2, alta 3). A semana soma só o que ainda está pendente. Duas ou mais altas, ou barra acima de 80%, viram alerta.

Isso deixa o mapa vivo: concluir o Checkpoint 2 baixa a semana 3. Cadastrar outra alta na semana 4 pode acender um alerta novo.

### 2. Calendário coerente

O Figma do CP4 misturava semanas de janeiro com entregas de agosto/setembro. Para o critério de qualidade dos dados mockados, o semestre da demo é 08/09 a 05/10/2026, com “hoje” fixo em 21/09/2026. A apresentação não depende do dia real da aula.

### 3. Banco opcional

O enunciado pede dados mockados **e** integração com Supabase/Firebase. Os dois existem, mas a aula não quebra se a rede falhar.

Fluxo:

1. Se não houver `SUPABASE_URL`, usa `SharedPreferences`.
2. Se houver URL, lê a tabela `deliveries`. Tabela vazia recebe o seed.
3. Qualquer erro de rede volta para o mock local e mostra um aviso.

A integração é REST (PostgREST), sem o SDK completo. Para um protótipo, HTTP resolve. O SQL está em `supabase/schema.sql`.

Não há login. As políticas do banco estão abertas de propósito, só para o checkpoint.

### 4. Navegação completa no visual do CP4

O Figma original não tinha detalhe da semana, da entrega, do alerta nem perfil. Sem essas telas o fluxo da aula parava no dashboard. Elas foram desenhadas com a mesma paleta, cantos, tags e tom de voz, para a fidelidade do CP4 continuar valendo.

A lista com filtros cobre o MVP do CP1 (“visões de lista”) sem inventar um segundo produto.

### 5. Ambiente de teste

`flutter create` gerou web, android e windows. O recorte de celular no Chrome imita os frames “iPhone 17” do Figma, útil quando a apresentação for no notebook.

## O que ficou de fora de propósito

- Login e conta real.
- Integração com Teams (o CP1 já dizia: acelerador opcional, nunca dependência).
- Backend próprio.
- Testes de clique em toda tela. Há testes no cálculo de carga, que é a regra de negócio do produto.
