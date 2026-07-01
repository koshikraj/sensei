-- Sensei — human-friendly layer (v2) for the Slack bot and routines.
-- Bot reads ONLY these views and calls ONLY these functions (never raw tables).
-- Functions own the state transitions and return a friendly, ready-to-relay line.

-- ═════════════════════════════════════════════════════════════════════════════
-- READ VIEWS (no IDs, no JSONB)
-- ═════════════════════════════════════════════════════════════════════════════

create or replace function sensei_current_topic_id() returns bigint language sql stable as $$
  select id from topics where completed_at is null order by seq limit 1
$$;

-- The current topic (what "today" is about)
create or replace view sensei_current_topic as
select t.title, m.title as module, t.description, t.objectives,
       (select count(*) from lessons l where l.topic_id = t.id)                            as total_lessons,
       (select count(*) from lessons l where l.topic_id = t.id and l.completed_at is not null) as completed_lessons,
       coalesce((select q.status from quizzes q where q.topic_id = t.id), 'locked')        as quiz_status
from topics t
join modules m on m.id = t.module_id
where t.completed_at is null
order by t.seq
limit 1;

-- Lessons of the current topic, with completion state
create or replace view sensei_current_lessons as
select l.position, l.title, l.format,
       case when l.completed_at is not null then 'completed'
            when l.available_at  is not null then 'available'
            else 'planned' end as status
from lessons l
where l.topic_id = sensei_current_topic_id()
order by l.position;

-- Resources (docs/articles/videos/attachments) of the current topic
create or replace view sensei_current_resources as
select r.kind, r.title, r.url, r.description, r.source
from resources r
where r.topic_id = sensei_current_topic_id()
order by r.position, r.id;

-- Overall snapshot for "how am I doing / what's today"
create or replace view sensei_today as
select ct.current_topic, ct.module, ct.description,
       ct.completed_lessons, ct.total_lessons, ct.quiz_status,
       (select count(*) from topics where completed_at is not null) as topics_done,
       (select count(*) from topics)                                as topics_total,
       (select round(avg(score)) from mastery)                      as avg_mastery
from (select title as current_topic, module, description, completed_lessons, total_lessons, quiz_status
      from sensei_current_topic) ct;

-- The plan: module → topics, with progress
create or replace view sensei_curriculum as
select m.seq as module_no, m.title as module, t.seq as topic_no, t.title as topic,
       (select count(*) from lessons l where l.topic_id = t.id) as lessons,
       case when t.completed_at is not null then 'done'
            when t.started_at   is not null then 'in progress'
            else 'upcoming' end as status
from modules m
join topics t on t.module_id = m.id
order by m.seq, t.seq;

-- Mastery by topic
create or replace view sensei_progress as
select t.title, m.title as module, coalesce(mst.score, 0) as mastery,
       case when t.completed_at is not null then 'done'
            when t.started_at   is not null then 'in progress'
            else 'upcoming' end as status
from topics t
join modules m on m.id = t.module_id
left join mastery mst on mst.topic_id = t.id
order by t.seq;

create or replace view sensei_weak_topics as
select title, module, mastery from sensei_progress where mastery > 0 and mastery < 50 order by mastery asc;

-- ═════════════════════════════════════════════════════════════════════════════
-- ACTION / STATE FUNCTIONS
-- Signal prefixes (START_TOPIC, REMIND_LESSONS, GENERATE_QUIZ, ALERT_LESSONS,
-- QUIZ_READY, DONE_ALL) tell the routine/bot what to generate or post next.
-- ═════════════════════════════════════════════════════════════════════════════

-- Lesson routine: start the current topic if new, else report lesson progress.
create or replace function sensei_start_current_topic() returns text language plpgsql security definer as $$
declare tid bigint; ttitle text; n_left int; n_total int;
begin
  tid := sensei_current_topic_id();
  if tid is null then return 'DONE_ALL: Every topic is finished. 🎉'; end if;
  select title into ttitle from topics where id = tid;
  if (select started_at from topics where id = tid) is null then
    update topics set started_at = now() where id = tid;
    update lessons set available_at = now(), status = 'available' where topic_id = tid and status = 'planned';
    insert into quizzes(topic_id, status) values (tid, 'locked') on conflict (topic_id) do nothing;
    return 'START_TOPIC: Deliver "' || ttitle || '" — post its description, generate & post each lesson, and list its resources.';
  end if;
  select count(*) filter (where completed_at is null), count(*) into n_left, n_total from lessons where topic_id = tid;
  if n_left > 0 then
    return 'REMIND_LESSONS: ' || n_left || ' of ' || n_total || ' lessons still to do in "' || ttitle || '". Send a warm reminder to finish them.';
  end if;
  return 'LESSONS_DONE: Lessons complete for "' || ttitle || '"; waiting on the quiz slot.';
end $$;

-- Learner: mark a lesson done. If it's the last one and the quiz is already due,
-- signal that the quiz should be generated now (auto-populate after a missed slot).
create or replace function sensei_complete_lesson(p_topic text, p_position int)
returns text language plpgsql security definer as $$
declare tid bigint; ltitle text; n_left int; qstatus text;
begin
  select id into tid from topics where title ilike '%'||p_topic||'%' order by seq limit 1;
  if tid is null then return 'I couldn''t find a topic matching "' || p_topic || '".'; end if;
  update lessons set completed_at = now(), status = 'completed'
   where topic_id = tid and position = p_position and completed_at is null
   returning title into ltitle;
  if ltitle is null then return 'That lesson is already done, or I couldn''t find it.'; end if;
  insert into edit_log(source, target, after) values ('slack', 'lessons', jsonb_build_object('completed', ltitle));
  select count(*) into n_left from lessons where topic_id = tid and completed_at is null;
  if n_left > 0 then
    return 'Nice — "' || ltitle || '" done. ' || n_left || ' lesson(s) left in this topic.';
  end if;
  insert into quizzes(topic_id, status) values (tid, 'locked') on conflict (topic_id) do nothing;
  select status into qstatus from quizzes where topic_id = tid;
  if qstatus = 'due' then
    update quizzes set status = 'available', delivered_at = now() where topic_id = tid;
    return 'QUIZ_READY: All lessons done and the quiz was already due — generate and post the topic quiz now.';
  end if;
  return 'All lessons complete! 🎉 Your quiz will arrive at the next quiz time.';
end $$;

-- Quiz routine (scheduled slot): deliver the quiz if lessons are done, else alert.
create or replace function sensei_quiz_slot() returns text language plpgsql security definer as $$
declare tid bigint; ttitle text; n_left int; qstatus text;
begin
  tid := sensei_current_topic_id();
  if tid is null then return 'DONE_ALL: No active topic.'; end if;
  select title into ttitle from topics where id = tid;
  insert into quizzes(topic_id, status) values (tid, 'locked') on conflict (topic_id) do nothing;
  select status into qstatus from quizzes where topic_id = tid;
  if qstatus = 'completed' then return 'Quiz already completed for "' || ttitle || '".'; end if;
  if qstatus = 'available' then return 'Quiz already delivered for "' || ttitle || '".'; end if;
  select count(*) into n_left from lessons where topic_id = tid and completed_at is null;
  if n_left > 0 then
    update quizzes set status = 'due', due_at = coalesce(due_at, now()) where topic_id = tid;
    return 'ALERT_LESSONS: Quiz slot reached but ' || n_left || ' lesson(s) unfinished in "' || ttitle || '". Send a complete-your-lessons alert — do NOT post the quiz.';
  end if;
  update quizzes set status = 'available', due_at = coalesce(due_at, now()), delivered_at = now() where topic_id = tid;
  return 'GENERATE_QUIZ: Lessons complete for "' || ttitle || '". Generate the per-topic quiz and post it.';
end $$;

-- Store a generated quiz (called by the routine/bot after generating questions).
create or replace function sensei_populate_quiz(p_topic text, p_questions jsonb)
returns text language plpgsql security definer as $$
declare tid bigint;
begin
  select id into tid from topics where title ilike '%'||p_topic||'%' order by seq limit 1;
  if tid is null then return 'Topic not found.'; end if;
  update quizzes set questions = p_questions, status = 'available', delivered_at = now() where topic_id = tid;
  return 'Quiz stored for "' || (select title from topics where id = tid) || '".';
end $$;

-- Learner submits the quiz: record it, update mastery, and complete the topic.
create or replace function sensei_record_quiz_result(p_topic text, p_score int)
returns text language plpgsql security definer as $$
declare tid bigint; qid bigint; ttitle text; nxt text; n_left int;
begin
  select id, title into tid, ttitle from topics where title ilike '%'||p_topic||'%' order by seq limit 1;
  if tid is null then return 'Topic not found.'; end if;
  select id into qid from quizzes where topic_id = tid;
  insert into quiz_attempts(quiz_id, score, per_topic_results)
    values (qid, p_score / 100.0, jsonb_build_object(ttitle, p_score));
  update quizzes set status = 'completed', completed_at = now() where topic_id = tid;
  update mastery set score = p_score, last_reviewed = current_date,
         next_review = current_date + (case when p_score >= 80 then 7 when p_score >= 50 then 3 else 1 end),
         updated_at = now()
   where topic_id = tid;
  select count(*) into n_left from lessons where topic_id = tid and completed_at is null;
  if n_left = 0 then
    update topics set completed_at = now() where id = tid and completed_at is null;
  end if;
  select title into nxt from topics where completed_at is null order by seq limit 1;
  return 'Quiz done for "' || ttitle || '" (' || p_score || '%). '
      || case when n_left = 0 then 'Topic complete! ' else '' end
      || coalesce('Next up: ' || nxt || '.', 'That was the last topic — course complete! 🎉');
end $$;

create or replace function sensei_mark_mastered(topic_title text)
returns text language plpgsql security definer as $$
declare v_id bigint; v_name text;
begin
  select id, title into v_id, v_name from topics where title ilike '%'||topic_title||'%' order by seq limit 1;
  if v_id is null then return 'I couldn''t find a topic matching "' || topic_title || '".'; end if;
  update mastery set score = 100, next_review = null where topic_id = v_id;
  return 'Marked "' || v_name || '" as mastered — I''ll stop resurfacing it in quizzes.';
end $$;

create or replace function sensei_add_resource(p_topic text, p_kind text, p_title text, p_url text)
returns text language plpgsql security definer as $$
declare tid bigint;
begin
  select id into tid from topics where title ilike '%'||p_topic||'%' order by seq limit 1;
  if tid is null then return 'Topic not found.'; end if;
  insert into resources(topic_id, kind, title, url) values (tid, p_kind, p_title, p_url);
  return 'Added ' || p_kind || ' "' || p_title || '" to "' || (select title from topics where id = tid) || '".';
end $$;

create or replace function sensei_add_lesson(p_topic text, p_title text, p_format text default 'explainer')
returns text language plpgsql security definer as $$
declare tid bigint; nextpos int;
begin
  select id into tid from topics where title ilike '%'||p_topic||'%' order by seq limit 1;
  if tid is null then return 'Topic not found.'; end if;
  select coalesce(max(position),0) + 1 into nextpos from lessons where topic_id = tid;
  insert into lessons(topic_id, position, title, format, status) values (tid, nextpos, p_title, p_format, 'planned');
  return 'Added lesson "' || p_title || '" to "' || (select title from topics where id = tid) || '".';
end $$;

-- Lock write/state functions to privileged roles only (never the public/anon key).
do $$
declare fn text;
begin
  foreach fn in array array[
    'sensei_start_current_topic()',
    'sensei_complete_lesson(text,int)',
    'sensei_quiz_slot()',
    'sensei_populate_quiz(text,jsonb)',
    'sensei_record_quiz_result(text,int)',
    'sensei_mark_mastered(text)',
    'sensei_add_resource(text,text,text,text)',
    'sensei_add_lesson(text,text,text)'
  ] loop
    execute format('revoke execute on function %s from public, anon;', fn);
    execute format('grant execute on function %s to authenticated, service_role;', fn);
  end loop;
end $$;
