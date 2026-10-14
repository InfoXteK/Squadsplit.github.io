-- iFiNeX v8.9 package: database schema is UNCHANGED since v8.8 (nothing new to run if v8.8 was applied). File re-issued for completeness.
-- UPGRADE v8.3 / v8.4-partial / v8.5 -> v8.8.  Run ONCE in Supabase > SQL Editor on your LIVE project. Idempotent (safe to re-run). Changes no row data.
-- ============================================================================
-- iFiNeX v8.5 — UPGRADE from v8.3 / v8.4-partial.  Idempotent: safe to run more than once. Changes no row data.
--   1) bill_user_prefs.theme  : accept ANY safe theme id (the 12 v8.4 design styles "st-*" were rejected by the old 13-name list -> "Save theme" failed)
--   2) et_kinds               : your own tracker types (Wedding, Umrah, Project …)
--   3) et_trackers.kind       : any slug allowed (was period / occasion / trip only)
--   4) bill_settlements UPDATE: admin / admin-delegate can edit a payment; the person it belongs to is notified
--   5) app_users_directory    : runs with the caller's rights (clears the Supabase "Security Definer View" ERROR; same result because app_users is readable by registered users)
--   6) et_groups (+ et_trackers.group_id): present on the live project since 2026-10-08, unused by the v8.5 front-end; kept so a clone equals live
-- ============================================================================

-- 1) themes -------------------------------------------------------------------------------------------------------------------
alter table public.bill_user_prefs drop constraint if exists bill_user_prefs_theme_check;
alter table public.bill_user_prefs add constraint bill_user_prefs_theme_check check (theme ~ '^[a-z0-9-]{1,40}$');

-- 2) custom tracker types ------------------------------------------------------------------------------------------------------
create table if not exists public.et_kinds (
  id bigint generated always as identity primary key,
  user_email text not null,
  key text not null check (key ~ '^[a-z0-9-]{1,40}$'),
  label text not null check (length(label) between 1 and 40),
  icon text not null default '🏷️' check (length(icon) <= 8),
  created_by_email text,
  created_at timestamptz not null default now(),
  unique (user_email, key)
);
create index if not exists et_kinds_user_idx on public.et_kinds (lower(user_email));
alter table public.et_kinds enable row level security;
drop policy if exists et_kinds_all on public.et_kinds;
create policy et_kinds_all on public.et_kinds for all to authenticated
  using (lower(user_email) = (select my_email()) or (select is_delegate_for(et_kinds.user_email)) or (select is_bill_admin()))
  with check (lower(user_email) = (select my_email()) or (select is_delegate_for(et_kinds.user_email)) or (select is_bill_admin()));
drop policy if exists ifx_registered_gate on public.et_kinds;
create policy ifx_registered_gate on public.et_kinds as restrictive for all to authenticated
  using ((select public.is_registered())) with check ((select public.is_registered()));
revoke all on public.et_kinds from anon;
grant select, insert, update, delete on public.et_kinds to authenticated;

-- 3) trackers may use any type key ----------------------------------------------------------------------------------------------
alter table public.et_trackers drop constraint if exists et_trackers_kind_check;
alter table public.et_trackers add constraint et_trackers_kind_check check (kind ~ '^[a-z0-9-]{1,40}$');

-- 4) edit a payment to admin ---------------------------------------------------------------------------------------------------
drop policy if exists bill_settlements_update on public.bill_settlements;
create policy bill_settlements_update on public.bill_settlements for update to authenticated
  using ((select is_bill_admin()) or (select is_admin_delegate()))
  with check ((select is_bill_admin()) or (select is_admin_delegate()));
create or replace function public.notify_settlement_edit() returns trigger language plpgsql security definer set search_path to 'public' as $f$
begin
  if (old.amount is distinct from new.amount) or (old.month is distinct from new.month) then
    insert into bill_notifications (recipient_email, title, message)
    values (lower(new.user_email), '✏️ A payment record was edited',
      format('A payment to admin was changed by %s: AED %s (%s) → AED %s (%s)', coalesce((select my_email()),'admin'), old.amount, old.month, new.amount, new.month));
  end if;
  return new;
end $f$;
drop trigger if exists trg_notify_settlement_edit on public.bill_settlements;
create trigger trg_notify_settlement_edit after update on public.bill_settlements for each row execute function public.notify_settlement_edit();

-- 5) directory view with the caller's rights ---------------------------------------------------------------------------------
alter view public.app_users_directory set (security_invoker = true);

-- 6) legacy tracker groups (already on the live project; no-op there) ---------------------------------------------------------
create table if not exists public.et_groups (
  id bigint generated always as identity primary key,
  user_email text not null,
  name text not null check (length(name) between 1 and 60),
  icon text not null default '🗂️' check (length(icon) <= 8),
  created_by_email text,
  created_at timestamptz not null default now()
);
create unique index if not exists et_groups_unique_name on public.et_groups (lower(user_email), lower(name));
alter table public.et_trackers add column if not exists group_id bigint;
do $$ begin
  if not exists (select 1 from pg_constraint where conname='et_trackers_group_id_fkey') then
    alter table public.et_trackers add constraint et_trackers_group_id_fkey foreign key (group_id) references public.et_groups(id) on delete set null;
  end if;
end $$;
create index if not exists et_trackers_group_idx on public.et_trackers (group_id);
alter table public.et_groups enable row level security;
drop policy if exists et_groups_all on public.et_groups;
create policy et_groups_all on public.et_groups for all to authenticated
  using (lower(user_email) = (select my_email()) or (select is_delegate_for(et_groups.user_email)) or (select is_bill_admin()))
  with check (lower(user_email) = (select my_email()) or (select is_delegate_for(et_groups.user_email)) or (select is_bill_admin()));
drop policy if exists ifx_registered_gate on public.et_groups;
create policy ifx_registered_gate on public.et_groups as restrictive for all to authenticated
  using ((select public.is_registered())) with check ((select public.is_registered()));
revoke all on public.et_groups from anon;
grant select, insert, update, delete on public.et_groups to authenticated;

-- ===== v8.8: server-mode Restore-from-backup-file RPCs =====
-- v8.8 — "Restore from backup file" for the server mode (admins AND members, each within their own rights).
-- ifx_restore_rows: re-inserts rows that are MISSING (never overwrites existing rows). SECURITY INVOKER = row-level security still decides
-- what the caller may write, so a member can only restore their own rows and an admin everything an admin may write.
create or replace function public.ifx_seq_bump(p_table text) returns void
language plpgsql security definer set search_path = public as $$
declare v_seq text; v_max bigint;
begin
  if p_table <> all (array['bill_cards','bill_card_shares','bill_card_payments','bill_payees','bill_expenses','bill_owed','bill_settlements','bill_payee_entries','bill_plans','bill_plan_payments','et_groups','et_trackers','et_entries','et_categories','et_kinds','bp_income','bp_items','bp_goals','expenses','settlements','prev_balances']) then
    raise exception 'table_not_allowed';
  end if;
  if (select my_email()) is null then raise exception 'not_signed_in'; end if;
  v_seq := pg_get_serial_sequence('public.'||quote_ident(p_table), 'id');
  if v_seq is null then return; end if;
  execute format('select max(id) from public.%I', p_table) into v_max;
  if v_max is not null then perform setval(v_seq, greatest(v_max, (select last_value from pg_sequences where schemaname||'.'||sequencename = replace(v_seq,'"',''))), true); end if;
end $$;
revoke all on function public.ifx_seq_bump(text) from public, anon;
grant execute on function public.ifx_seq_bump(text) to authenticated;

create or replace function public.ifx_restore_rows(p_table text, p_rows jsonb) returns jsonb
language plpgsql set search_path = public as $$
declare
  allowed constant text[] := array['bill_cards','bill_card_shares','bill_card_payments','bill_payees','bill_expenses','bill_owed','bill_settlements','bill_payee_entries','bill_plans','bill_plan_payments','bill_user_prefs','et_groups','et_trackers','et_entries','et_categories','et_kinds','bp_income','bp_items','bp_goals','members_config','expenses','settlements','prev_balances'];
  r jsonb; v_cols text; n_ins int := 0; n_skip int := 0; n_fail int := 0; n int; v_err text;
begin
  if (select my_email()) is null or not (select public.is_registered()) then raise exception 'not_signed_in'; end if;
  if p_table <> all (allowed) then raise exception 'table_not_allowed'; end if;
  if jsonb_typeof(p_rows) <> 'array' or jsonb_array_length(p_rows) > 500 then raise exception 'bad_rows'; end if;
  if to_regclass('public.'||quote_ident(p_table)) is null then return jsonb_build_object('ok', true, 'inserted', 0, 'skipped', 0, 'failed', jsonb_array_length(p_rows), 'error', 'table_missing_on_server'); end if;
  perform set_config('ifinex.bulk', '1', true);                                        -- no "new entry" notifications for restored rows
  for r in select * from jsonb_array_elements(p_rows) loop
    begin
      if jsonb_typeof(r) <> 'object' then raise exception 'bad_row'; end if;
      select string_agg(quote_ident(a.attname), ',') into v_cols
        from jsonb_object_keys(r) k join pg_attribute a on a.attrelid = ('public.'||quote_ident(p_table))::regclass and a.attname = k and a.attnum > 0 and not a.attisdropped and a.attgenerated = '';
      if v_cols is null then raise exception 'no_known_columns'; end if;
      execute format('insert into public.%I (%s) overriding system value select %s from jsonb_populate_record(null::public.%I, $1) on conflict do nothing', p_table, v_cols, v_cols, p_table) using r;
      get diagnostics n = row_count;
      if n > 0 then n_ins := n_ins + 1; else n_skip := n_skip + 1; end if;
    exception when others then
      n_fail := n_fail + 1; if v_err is null then v_err := sqlerrm; end if;
    end;
  end loop;
  perform set_config('ifinex.bulk', '0', true);
  if n_ins > 0 then begin perform public.ifx_seq_bump(p_table); exception when others then null; end; end if;
  return jsonb_build_object('ok', true, 'inserted', n_ins, 'skipped', n_skip, 'failed', n_fail, 'error', v_err);
end $$;
revoke all on function public.ifx_restore_rows(text, jsonb) from public, anon;
grant execute on function public.ifx_restore_rows(text, jsonb) to authenticated;

-- v8.8: trigger helper is not an API function
revoke all on function public.notify_settlement_edit() from public, anon, authenticated;
