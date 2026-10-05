-- ROTA · Checkpoint 5 + Supabase Auth
-- Execute no Supabase -> SQL Editor -> Run.
-- Este script transforma deliveries em dados por usuário.

create extension if not exists "pgcrypto";

create table if not exists public.deliveries (
  id text primary key,
  user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  discipline text not null,
  due_date date not null,
  priority text not null check (priority in ('baixa', 'media', 'alta')),
  status text not null default 'pendente' check (status in ('pendente', 'concluida')),
  notes text,
  created_at timestamptz not null default now()
);

-- Para projetos em que a tabela já existe, cria a coluna sem apagar os dados.
alter table public.deliveries
  add column if not exists user_id uuid references auth.users(id) on delete cascade;

create index if not exists deliveries_user_id_idx
  on public.deliveries using btree (user_id);

-- O app só deve acessar deliveries depois do login.
revoke all on public.deliveries from anon;
grant select, insert, update, delete on public.deliveries to authenticated;
grant select, insert, update, delete on public.deliveries to service_role;

alter table public.deliveries enable row level security;

drop policy if exists "rota_select" on public.deliveries;
drop policy if exists "rota_insert" on public.deliveries;
drop policy if exists "rota_update" on public.deliveries;
drop policy if exists "rota_delete" on public.deliveries;


create policy "rota_select"
on public.deliveries
for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "rota_insert"
on public.deliveries
for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "rota_update"
on public.deliveries
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "rota_delete"
on public.deliveries
for delete
to authenticated
using ((select auth.uid()) = user_id);

-- Os registros antigos criados antes do login têm user_id = NULL e deixam
-- de aparecer pela RLS. Ao entrar pela primeira vez, o app cria os mocks
-- novamente, mas já vinculados à conta autenticada.
