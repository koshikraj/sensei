-- Sensei — migration to v2 (modules → topics → lessons + resources).
-- Destructive: drops v1 tables/views/functions so schema.sql can recreate them.
-- Safe now because only seed data exists (no real learner history).
-- Run order:  migrate-v2.sql  →  schema.sql  →  seed.sql  →  views.sql

drop view if exists
  sensei_today, sensei_curriculum, sensei_progress, sensei_weak_topics,
  sensei_current_topic, sensei_current_lessons, sensei_current_resources cascade;

drop function if exists sensei_current_topic_id() cascade;
drop function if exists sensei_regenerate_today(text) cascade;
drop function if exists sensei_mark_mastered(text) cascade;
drop function if exists sensei_add_topic(text, int) cascade;

drop table if exists
  quiz_attempts, quizzes, resources, lessons, mastery, projects, news_items, topics, modules, edit_log
  cascade;
