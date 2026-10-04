# Como atualizar o Figma (CP5)

Arquivo da equipe:
https://www.figma.com/design/9tvU9QUR9S9MAf3zxkwwlq/Sem-t%C3%ADtulo?node-id=5-24

Daqui não dá para editar esse arquivo. São 8 cliques. As imagens prontas estão na pasta `docs/figma-cp5/`.

## O que manter (já está no arquivo)

- Abertura (logo ROTA)
- Dashboard mapa de carga
- Dashboard alerta
- Modal Nova Entrega

## O que adicionar

| Arquivo | Nome do frame no Figma |
| --- | --- |
| `docs/figma-cp5/01-semana.png` | iPhone 17 - Detalhe da semana |
| `docs/figma-cp5/02-entrega.png` | iPhone 17 - Detalhe da entrega |
| `docs/figma-cp5/03-alerta.png` | iPhone 17 - Alerta da rota |
| `docs/figma-cp5/04-perfil.png` | iPhone 17 - Perfil |
| `docs/figma-cp5/05-lista.png` | iPhone 17 - Lista de entregas |

## Passo a passo (método rápido, o da aula)

1. Abra o link do Figma e faça login na conta da equipe.
2. Na barra esquerda, clique na página onde já estão Abertura e Dashboard.
3. Selecione o frame do Dashboard. Aperte `Ctrl+D` (Windows) ou `Cmd+D` (Mac) para duplicar. Arraste a cópia para a direita.
4. Com o frame duplicado selecionado, no painel direito, em **Frame**, deixe 390 × 844 (iPhone 14/15/16/17).
5. Apague o conteúdo interno da cópia (não apague o frame).
6. Menu **File → Place image** (ou arraste o PNG da pasta `docs/figma-cp5/` para dentro do frame).
7. Ajuste a imagem para preencher o frame (canto do frame, Shift para não distorcer).
8. Renomeie o frame no painel esquerdo com o nome da tabela acima.
9. Repita para os 5 PNGs.

Pronto: o arquivo do CP4 passa a mostrar o fluxo do CP5.

## Ligar o protótipo (Play)

1. Clique em **Prototype** (canto superior direito).
2. Ligue assim, puxando a bolinha do componente para o frame de destino:

```
Abertura → Dashboard
Dashboard (card de entrega) → Detalhe da entrega
Dashboard (barra Sem 3) → Detalhe da semana
Dashboard (Ver detalhes) → Alerta da rota
Dashboard (avatar) → Perfil
Dashboard (+) → Modal Nova Entrega
Alerta → Detalhe da semana
Perfil (Todas as entregas) → Lista
Todo frame novo → voltar ao Dashboard (seta)
```

3. Clique no Play (▶️) para gravar a apresentação.

## Cores (se for redesenhar em vez de colar imagem)

| Uso | Código |
| --- | --- |
| Fundo | `#0E172A` |
| Cartão | `#202A45` |
| Texto | `#F4F6FA` |
| Texto secundário | `#A8B0C3` |
| Botão / azul | `#2864E8` |
| Baixa | `#42D5A4` |
| Média | `#4F8EF7` |
| Alta | `#FF6961` |
| Alerta | `#73373C` |

Fonte: **Poppins**. Títulos ExtraBold. Botões e tags SemiBold. Datas Regular.

## Textos para copiar

**Semana 3**
- 22 a 28 Set
- Carga Crítica
- 4 pendentes
- Semana crítica. Reavalie prazos agora, enquanto ainda dá tempo de agir.
- Entregas desta semana
- Voltar ao mapa

**Entrega (Projeto Figma)**
- Alta
- Pendente
- Disciplina: Cross-Platform
- Data limite: 23 Set 2026
- Priorize o Projeto Figma para manter sua rota em dia.
- Marcar como concluída
- Editar
- Remover da rota

**Alerta**
- Semana 3 Crítica!
- Você tem 2 Checkpoints e a entrega da Global Solution acumulados nos mesmos dias. Reavalie seus prazos.
- Ver a semana completa

**Perfil**
- Hercules Ramos
- Engenharia de Software · FIAP
- RM562354
- Todas as entregas
- Resetar dados de demonstração
