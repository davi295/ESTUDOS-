-- Rode no Supabase: SQL Editor > New query > cole tudo > Run

-- Progresso atual: uma linha por conta
create table if not exists public.progresso (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  dados      jsonb not null default '{}'::jsonb,
  atualizado timestamptz not null default now()
);

-- Cópia diária: uma linha por conta por dia, para recuperar se algo for sobrescrito
create table if not exists public.progresso_historico (
  user_id uuid not null references auth.users(id) on delete cascade,
  dia     date not null,
  dados   jsonb not null,
  primary key (user_id, dia)
);

-- Cada conta só enxerga e altera os próprios dados
alter table public.progresso enable row level security;
alter table public.progresso_historico enable row level security;

create policy "progresso: ler o proprio" on public.progresso
  for select using ((select auth.uid()) = user_id);
create policy "progresso: criar o proprio" on public.progresso
  for insert with check ((select auth.uid()) = user_id);
create policy "progresso: editar o proprio" on public.progresso
  for update using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy "historico: ler o proprio" on public.progresso_historico
  for select using ((select auth.uid()) = user_id);
create policy "historico: criar o proprio" on public.progresso_historico
  for insert with check ((select auth.uid()) = user_id);
create policy "historico: editar o proprio" on public.progresso_historico
  for update using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
