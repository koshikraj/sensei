-- Sensei — Supabase schema
-- Source of truth for curriculum, generated content, progress, and audit.
-- Run in the Supabase SQL editor (or via the Supabase MCP) on a fresh project.

create extension if not exists vector;      -- pgvector, used by Week 3–4 RAG projects

-- ─────────────────────────────────────────────────────────────────────────────
-- Curriculum (seeded once; reorderable by the Slack bot)
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists topics (
  id            bigserial primary key,
  seq           int         not null unique,        -- global order 1..50
  week          int         not null,
  module        text        not null,
  title         text        not null,
  format        text        not null,               -- explainer|code-along|explain-back|case-study|debug|flashcard
  prerequisites text,
  created_at    timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Generated daily content
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists lessons (
  id          bigserial primary key,
  topic_id    bigint      references topics(id),
  lesson_date date        not null,
  format      text        not null,
  title       text        not null,
  content     text        not null,                 -- markdown
  status      text        not null default 'sent',  -- draft|sent|regenerate|edited
  note        text,                                  -- e.g. "make it more hands-on" (for regenerate)
  created_at  timestamptz not null default now(),
  unique (lesson_date)
);

create table if not exists quizzes (
  id          bigserial primary key,
  quiz_date   date        not null,
  topic_ids   bigint[]    not null,
  questions   jsonb       not null,                 -- [{q, type, options, answer, explanation}]
  created_at  timestamptz not null default now(),
  unique (quiz_date)
);

create table if not exists quiz_attempts (
  id                 bigserial primary key,
  quiz_id            bigint      references quizzes(id),
  answers            jsonb       not null,
  score              numeric     not null,          -- 0..1
  per_topic_results  jsonb       not null,          -- {topic_id: correct_bool}
  created_at         timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Progress / spaced repetition (SM-2 style)
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists mastery (
  topic_id      bigint primary key references topics(id),
  score         int         not null default 0,     -- 0..100
  ease          numeric     not null default 2.5,
  interval_days int         not null default 0,
  last_reviewed date,
  next_review   date,
  updated_at    timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Weekly projects
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists projects (
  id         bigserial primary key,
  week       int         not null unique,
  title      text        not null,
  brief      text,                                   -- markdown, generated Monday
  starter    text,
  solution   text,                                   -- generated Friday
  criteria   text,
  status     text        not null default 'planned', -- planned|briefed|reviewed
  created_at timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Curated news
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists news_items (
  id         bigserial primary key,
  news_date  date        not null default current_date,
  module     text,
  title      text        not null,
  url        text        not null unique,
  summary    text,
  source     text,
  created_at timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Audit log of edits (Slack bot / dashboard / routines)
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists edit_log (
  id         bigserial primary key,
  source     text        not null,                  -- slack|dashboard|routine
  actor      text,
  target     text        not null,                  -- table/row touched
  before     jsonb,
  after      jsonb,
  created_at timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Row Level Security: dashboard reads with the anon key; routines write with a
-- service/access token (bypasses RLS).
-- ─────────────────────────────────────────────────────────────────────────────
alter table topics        enable row level security;
alter table lessons       enable row level security;
alter table quizzes       enable row level security;
alter table quiz_attempts enable row level security;
alter table mastery       enable row level security;
alter table projects      enable row level security;
alter table news_items    enable row level security;

do $$
declare t text;
begin
  foreach t in array array['topics','lessons','quizzes','quiz_attempts','mastery','projects','news_items']
  loop
    execute format(
      'create policy %I on %I for select using (true);',
      'read_'||t, t
    );
  end loop;
end $$;
