-- Sensei — human-friendly layer for the Slack bot.
-- The bot should ONLY read these views and call these functions, never raw tables.
-- Views hide IDs/JSONB and return readable columns; functions perform named
-- actions and return a friendly sentence the bot can relay almost verbatim.

-- ─────────────────────────────────────────────────────────────────────────────
-- READ VIEWS (clean, no IDs, no JSONB)
-- ─────────────────────────────────────────────────────────────────────────────

-- One-row snapshot for "how am I doing / what's today"
create or replace view sensei_today as
select
  (select title      from lessons  order by lesson_date desc limit 1)                         as todays_lesson,
  (select lesson_date from lessons  order by lesson_date desc limit 1)                         as lesson_date,
  (select count(*)   from quizzes  where quiz_date = current_date)                             as todays_quiz_questions,
  (select title      from projects where status in ('briefed','reviewed') order by week desc limit 1) as current_project,
  (select round(avg(score)) from mastery)                                                      as avg_mastery,
  (select count(*)   from lessons)                                                             as lessons_done,
  (select count(*)   from topics)                                                              as lessons_total;

-- The plan, readable: "Lesson 14 · Week 3 · Caching strategies · done"
create or replace view sensei_curriculum as
select t.seq as lesson_no, t.week, t.module, t.title, t.format,
       case when l.id is not null then 'done' else 'upcoming' end as status
from topics t
left join lessons l on l.topic_id = t.id
order by t.seq;

-- Progress by topic, by name
create or replace view sensei_progress as
select t.title, t.module, t.week, m.score as mastery, m.last_reviewed, m.next_review
from mastery m join topics t on t.id = m.topic_id
order by t.seq;

-- Weakest topics first — what to focus on
create or replace view sensei_weak_topics as
select title, module, week, mastery
from sensei_progress
where mastery < 50
order by mastery asc;

-- ─────────────────────────────────────────────────────────────────────────────
-- ACTION FUNCTIONS (named operations; each returns a friendly message)
-- Match a topic loosely by name so the user never needs an ID.
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function sensei_regenerate_today(note text default null)
returns text language plpgsql security definer as $$
declare v_title text;
begin
  update lessons set status = 'regenerate', note = coalesce(sensei_regenerate_today.note, lessons.note)
  where lesson_date = current_date
  returning title into v_title;
  if v_title is null then
    return 'There isn''t a lesson for today yet, so there''s nothing to regenerate.';
  end if;
  insert into edit_log(source, target, after)
  values ('slack', 'lessons/today', jsonb_build_object('status','regenerate','note',note));
  return 'Got it — I''ll redo today''s lesson ("' || v_title || '")'
      || coalesce(' with your note: ' || note, '')
      || '. It''ll be reposted here shortly.';
end $$;

create or replace function sensei_mark_mastered(topic_title text)
returns text language plpgsql security definer as $$
declare v_id bigint; v_name text;
begin
  select id, title into v_id, v_name from topics where title ilike '%'||topic_title||'%' order by seq limit 1;
  if v_id is null then
    return 'I couldn''t find a topic matching "' || topic_title || '". Try the exact lesson name?';
  end if;
  update mastery set score = 100, next_review = null where topic_id = v_id;
  insert into edit_log(source, target, after) values ('slack', 'mastery', jsonb_build_object('topic',v_name,'score',100));
  return 'Marked "' || v_name || '" as mastered — I''ll stop resurfacing it in quizzes.';
end $$;

create or replace function sensei_add_topic(new_title text, after_week int)
returns text language plpgsql security definer as $$
declare v_seq int; v_module text;
begin
  select max(seq) into v_seq from topics where week <= after_week;
  if v_seq is null then return 'Week ' || after_week || ' isn''t in the plan yet.'; end if;
  select module into v_module from topics where week = after_week order by seq limit 1;
  update topics set seq = seq + 1 where seq > v_seq;
  insert into topics(seq, week, module, title, format) values (v_seq + 1, after_week, coalesce(v_module,'Custom'), new_title, 'explainer');
  insert into mastery(topic_id) select id from topics where seq = v_seq + 1;
  insert into edit_log(source, target, after) values ('slack', 'topics', jsonb_build_object('added',new_title,'after_week',after_week));
  return 'Added "' || new_title || '" after week ' || after_week || '. The plan now has ' || (select count(*) from topics) || ' lessons.';
end $$;

-- Lock down the write functions: privileged bot role only, never the public/anon
-- key the dashboard uses. (Postgres grants EXECUTE to PUBLIC by default.)
do $$
declare fn text;
begin
  foreach fn in array array[
    'sensei_regenerate_today(text)',
    'sensei_mark_mastered(text)',
    'sensei_add_topic(text,int)'
  ] loop
    execute format('revoke execute on function %s from public, anon;', fn);
    execute format('grant execute on function %s to authenticated, service_role;', fn);
  end loop;
end $$;
