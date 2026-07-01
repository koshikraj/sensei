-- Sensei — Supabase schema (v2: modules → topics → lessons + resources)
-- Completion-driven, self-paced. No hardcoded weeks/days: topics have an order
-- and advance only when all their lessons AND their quiz are completed.
-- Run on a fresh project, or via supabase/migrate-v2.sql on an existing one.

create extension if not exists vector;

-- ─────────────────────────────────────────────────────────────────────────────
-- Curriculum: modules → topics → lessons, plus per-topic resources
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists modules (
  id          bigserial primary key,
  seq         int  not null unique,      -- module order
  slug        text not null unique,
  title       text not null,
  description text,
  created_at  timestamptz not null default now()
);

create table if not exists topics (
  id            bigserial primary key,
  seq           int    not null unique,  -- global topic order (drives progression)
  module_id     bigint not null references modules(id) on delete cascade,
  title         text   not null,
  description   text,                     -- the main topic description (markdown)
  objectives    text,
  prerequisites text,
  started_at    timestamptz,             -- set when the topic is delivered
  completed_at  timestamptz,             -- set when all lessons + quiz are done
  created_at    timestamptz not null default now()
);
-- status is DERIVED: done (completed_at) | current (first topic not done) | upcoming

create table if not exists lessons (
  id           bigserial primary key,
  topic_id     bigint not null references topics(id) on delete cascade,
  position     int    not null,           -- order within the topic (1..N)
  title        text   not null,
  format       text   not null,           -- explainer|code-along|explain-back|case-study|debug
  content      text,
  status       text   not null default 'planned', -- planned|available|completed|regenerate
  available_at timestamptz,               -- delivered
  completed_at timestamptz,               -- learner finished it
  note         text,
  created_at   timestamptz not null default now(),
  unique (topic_id, position)
);

create table if not exists resources (
  id           bigserial primary key,
  topic_id     bigint not null references topics(id) on delete cascade,
  lesson_id    bigint references lessons(id) on delete set null, -- optional: scope to a lesson
  kind         text not null,             -- article|video|doc|pdf|link|code|file
  title        text not null,
  url          text,                      -- external link OR Supabase Storage public URL
  storage_path text,                      -- set for uploaded attachments
  description  text,
  source       text,
  position     int not null default 0,
  created_at   timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Quizzes: ONE per topic, gated by lesson completion + a schedule slot
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists quizzes (
  id           bigserial primary key,
  topic_id     bigint not null unique references topics(id) on delete cascade,
  questions    jsonb,
  status       text not null default 'locked', -- locked|due|available|completed
  due_at       timestamptz,               -- when the quiz slot was first reached
  delivered_at timestamptz,
  completed_at timestamptz,
  created_at   timestamptz not null default now()
);

create table if not exists quiz_attempts (
  id                bigserial primary key,
  quiz_id           bigint references quizzes(id) on delete cascade,
  answers           jsonb   not null default '{}'::jsonb,
  score             numeric not null,     -- 0..1
  per_topic_results jsonb   not null default '{}'::jsonb,
  created_at        timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Progress / spaced repetition (per topic)
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists mastery (
  topic_id      bigint primary key references topics(id) on delete cascade,
  score         int         not null default 0,   -- 0..100
  ease          numeric     not null default 2.5,
  interval_days int         not null default 0,
  last_reviewed date,
  next_review   date,
  updated_at    timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Projects: ONE per module
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists projects (
  id         bigserial primary key,
  module_id  bigint not null unique references modules(id) on delete cascade,
  title      text not null,
  brief      text,
  starter    text,
  solution   text,
  criteria   text,
  status     text not null default 'planned', -- planned|briefed|reviewed
  created_at timestamptz not null default now()
);

create table if not exists news_items (
  id         bigserial primary key,
  news_date  date not null default current_date,
  module_id  bigint references modules(id) on delete set null,
  title      text not null,
  url        text not null unique,
  summary    text,
  source     text,
  created_at timestamptz not null default now()
);

create table if not exists edit_log (
  id         bigserial primary key,
  source     text not null,               -- slack|dashboard|routine
  actor      text,
  target     text not null,
  before     jsonb,
  after      jsonb,
  created_at timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- RLS: dashboard reads with the anon/publishable key; routines write with a
-- service token (bypasses RLS).
-- ─────────────────────────────────────────────────────────────────────────────
do $$
declare t text;
begin
  foreach t in array array['modules','topics','lessons','resources','quizzes','quiz_attempts','mastery','projects','news_items']
  loop
    execute format('alter table %I enable row level security;', t);
    execute format('drop policy if exists %I on %I;', 'read_'||t, t);
    execute format('create policy %I on %I for select using (true);', 'read_'||t, t);
  end loop;
end $$;
