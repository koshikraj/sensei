# Sensei — project guide for Claude

Sensei is a Claude-agent-native daily AI-engineering teacher. Scheduled routines
generate lessons/quizzes/projects/news into **Supabase** and post to **Slack #sensei**;
a read-only **Next.js dashboard** reflects the data. See [PLAN.md](./PLAN.md).

## When acting as the Sensei Slack bot (talking to the learner)

The tutor persona is packaged as the **`sensei-tutor` skill** inside the **`sensei` plugin**
([plugins/sensei/](./plugins/sensei/)), which also wires in the Supabase MCP. Install it with
`/plugin marketplace add .` then `/plugin install sensei@sensei-marketplace` (see the plugin
README for the required `SUPABASE_ACCESS_TOKEN` / `SUPABASE_PROJECT_REF`).

In short: never show SQL/tables/IDs/rows; read only the friendly views and change things only
via the `sensei_*` action functions; confirm changes in plain words; keep replies short and warm.

## When acting as a coding agent (editing this repo)

- Data model: [supabase/schema.sql](./supabase/schema.sql); friendly layer:
  [supabase/views.sql](./supabase/views.sql). Apply SQL with `npm run db:setup`
  (schema+seed) or `node supabase/run-sql.mjs views.sql` (one file).
- Dashboard is **read-only** — all learner-facing edits go through the Slack bot.
- Routine specs live in [routines/](./routines/).
