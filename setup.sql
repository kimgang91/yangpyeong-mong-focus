-- 양평 몽 포커스 미팅 대시보드 — 공유 저장 테이블
-- Supabase → SQL Editor 에 붙여 넣고 Run

create table if not exists public.focus_state (
  key        text primary key,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.focus_state enable row level security;

-- 링크 아는 누구나 읽기 · 추가 · 수정 (삭제는 막음)
drop policy if exists "focus read"   on public.focus_state;
drop policy if exists "focus insert" on public.focus_state;
drop policy if exists "focus update" on public.focus_state;
create policy "focus read"   on public.focus_state for select to anon, authenticated using (true);
create policy "focus insert" on public.focus_state for insert to anon, authenticated with check (true);
create policy "focus update" on public.focus_state for update to anon, authenticated using (true) with check (true);

-- 실시간 반영
alter table public.focus_state replica identity full;
do $$ begin
  alter publication supabase_realtime add table public.focus_state;
exception when duplicate_object then null; end $$;
