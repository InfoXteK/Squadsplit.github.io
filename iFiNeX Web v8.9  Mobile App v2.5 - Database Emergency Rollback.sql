-- iFiNeX v8.9 package: database schema is UNCHANGED since v8.8 (nothing new to run if v8.8 was applied). File re-issued for completeness.
-- Emergency Rollback v8.8 -> v8.3 (see below).
-- Emergency Rollback v8.5 -> v8.3. Custom tracker types are deleted; trackers that use a custom type are deleted WITH their entries.
-- Themes: anyone who picked a v8.4 design style (st-*) goes back to "default" (the old 13-name list cannot hold them).
update public.bill_user_prefs set theme='default' where theme not in ('default','ocean','sunset','forest','mono','glass-aqua','glass-dark','neo-light','neo-dark','aurora','noise-dark','sandstone','custom-photo');
alter table public.bill_user_prefs drop constraint if exists bill_user_prefs_theme_check;
alter table public.bill_user_prefs add constraint bill_user_prefs_theme_check CHECK ((theme = ANY (ARRAY['default','ocean','sunset','forest','mono','glass-aqua','glass-dark','neo-light','neo-dark','aurora','noise-dark','sandstone','custom-photo'])));
drop trigger if exists trg_notify_settlement_edit on public.bill_settlements;
drop function if exists public.notify_settlement_edit();
drop policy if exists bill_settlements_update on public.bill_settlements;
delete from public.et_entries where tracker_id in (select id from public.et_trackers where kind not in ('period','occasion','trip'));
delete from public.et_trackers where kind not in ('period','occasion','trip');
alter table public.et_trackers drop constraint if exists et_trackers_kind_check;
alter table public.et_trackers add constraint et_trackers_kind_check check (kind in ('period','occasion','trip'));
drop table if exists public.et_kinds;
-- v8.8 restore RPCs (harmless to keep; remove only if you want the old state exactly)
drop function if exists public.ifx_restore_rows(text, jsonb);
drop function if exists public.ifx_seq_bump(text);
