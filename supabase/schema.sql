-- ROTA · Checkpoint 5
-- Cole este SQL em: Supabase → SQL Editor → Run
-- Depois cole a URL do projeto em lib/core/app_config.dart e rode:
-- flutter run -d chrome

create extension if not exists "pgcrypto";

create table if not exists public.deliveries (
  id text primary key,
  title text not null,
  discipline text not null,
  due_date date not null,
  priority text not null check (priority in ('baixa', 'media', 'alta')),
  status text not null default 'pendente' check (status in ('pendente', 'concluida')),
  notes text,
  created_at timestamptz not null default now()
);

-- Projetos criados a partir de 30/05/2026 não expõem tabelas novas à API
-- automaticamente. Sem estes GRANTs, o app recebe "permission denied".
grant select, insert, update, delete on public.deliveries to anon;
grant select, insert, update, delete on public.deliveries to authenticated;
grant select, insert, update, delete on public.deliveries to service_role;

alter table public.deliveries enable row level security;

drop policy if exists "rota_select" on public.deliveries;
drop policy if exists "rota_insert" on public.deliveries;
drop policy if exists "rota_update" on public.deliveries;
drop policy if exists "rota_delete" on public.deliveries;

create policy "rota_select" on public.deliveries for select using (true);
create policy "rota_insert" on public.deliveries for insert with check (true);
create policy "rota_update" on public.deliveries for update using (true);
create policy "rota_delete" on public.deliveries for delete using (true);

-- Políticas abertas de propósito: o CP5 é um protótipo sem login.
-- Antes de um uso real, troque isso por autenticação + RLS por usuário.
