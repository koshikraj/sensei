-- Sensei — wipe all curriculum + learner progress (keeps news_items and edit_log).
-- news_items.module_id is set null by its FK; everything else cascades from modules.
-- Usage: node supabase/run-sql.mjs reset-curriculum.sql seed.sql
delete from modules;
