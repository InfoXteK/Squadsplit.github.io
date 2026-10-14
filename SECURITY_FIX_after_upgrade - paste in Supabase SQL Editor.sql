-- iFiNeX security clean-up (2 small fixes). Paste in Supabase > SQL Editor > Run. Safe to run twice. Changes no row data.

-- 1) A trigger helper must not be callable from the internet. (Triggers keep working: tested.)
revoke all on function public.notify_settlement_edit() from public, anon, authenticated;

-- 2) Background-photo bucket: stop everybody being able to LIST all files (the folder names are people's e-mail addresses).
--    Photos stay visible through their normal public link; each person can still list/replace only their OWN folder.
drop policy if exists user_backgrounds_read on storage.objects;
create policy user_backgrounds_read on storage.objects for select to authenticated
  using (bucket_id = 'user-backgrounds' and lower((storage.foldername(name))[1]) = (select my_email()));

-- CHECK: should return  anon=false, authenticated=false
select has_function_privilege('anon','public.notify_settlement_edit()','execute') as anon,
       has_function_privilege('authenticated','public.notify_settlement_edit()','execute') as authenticated;
