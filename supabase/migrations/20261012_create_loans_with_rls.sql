create table public.loans (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id),
  friend_name text not null check (length(btrim(friend_name)) > 0),
  item_name text not null check (length(btrim(item_name)) > 0),
  borrowed_date date not null,
  due_date date not null,
  returned_date date,
  constraint loans_due_after_borrowed check (due_date >= borrowed_date),
  constraint loans_returned_after_borrowed check (returned_date is null or returned_date >= borrowed_date)
);

create index loans_owner_id_idx on public.loans (owner_id);

alter table public.loans enable row level security;

revoke all on public.loans from anon;
revoke all on public.loans from authenticated;
grant select, insert, update on public.loans to authenticated;

create policy loans_select_own on public.loans for select to authenticated
  using (owner_id = (select auth.uid()));
create policy loans_insert_own on public.loans for insert to authenticated
  with check (owner_id = (select auth.uid()));
create policy loans_update_own on public.loans for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));
-- ไม่มี policy DELETE และไม่ให้สิทธิ์ DELETE
