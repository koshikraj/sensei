# Sensei — project guide for Claude

Sensei is a Claude-agent-native daily AI-engineering teacher. Scheduled routines
generate lessons/quizzes/projects/news into **Supabase** and post to **Slack #sensei**;
a read-only **Next.js dashboard** reflects the data. See [PLAN.md](./PLAN.md).

## When acting as the Sensei Slack bot (talking to the learner)

The tutor persona is packaged as the **`sensei-tutor` skill** inside the **`sensei` plugin**
([plugins/sensei/](./plugins/sensei/)), which also wires in the Supabase MCP. Install it with
`/plugin marketplace add .` then `/plugin install sensei@sensei-marketplace` (see the plugin
README for the required `SUPABASE_ACCESS_TOKEN` / `SUPABASE_PROJECT_REF`).

In short: never show SQL/tables/IDs/rows; read only the friendly views (`sensei_today`,
`sensei_current_topic`, `sensei_current_lessons`, `sensei_current_resources`,
`sensei_curriculum`, `sensei_progress`, `sensei_weak_topics`) and change things only via the
`sensei_*` action functions (`sensei_complete_lesson`, `sensei_record_quiz_result`,
`sensei_mark_mastered`, `sensei_add_resource`, `sensei_add_lesson`, `sensei_populate_quiz`);
confirm changes in plain words; keep replies short and warm.

## Curriculum model (v2)

Completion-driven and self-paced: **modules → topics → lessons + resources**, one **quiz per
topic**, one **project per module**. A topic is `done` only when all its lessons and its quiz
are complete; progression is by completion, **not** by calendar (no hardcoded weeks/days). See
[supabase/schema.sql](./supabase/schema.sql), [supabase/views.sql](./supabase/views.sql), and
the routine state machines in [routines/](./routines/). Migrate an existing DB with
`node supabase/run-sql.mjs migrate-v2.sql schema.sql seed.sql views.sql`.

## When acting as a coding agent (editing this repo)

- Data model: [supabase/schema.sql](./supabase/schema.sql); friendly layer:
  [supabase/views.sql](./supabase/views.sql). Apply SQL with `npm run db:setup`
  (schema+seed) or `node supabase/run-sql.mjs views.sql` (one file).
- Dashboard is **read-only** — all learner-facing edits go through the Slack bot.
- Routine specs live in [routines/](./routines/).
