# 🥋 Sensei

Your daily AI Engineering teacher. Scheduled Claude routines generate lessons, quizzes,
weekly projects, and news, post them to Slack `#sensei`, and store everything in Supabase.
This repo is the **read-only dashboard** plus the schema, curriculum seed, and routine specs.

See [`PLAN.md`](./PLAN.md) for the full design.

## Layout

```
PLAN.md              full design + roadmap
supabase/
  schema.sql         tables, pgvector, RLS
  seed.sql           10-week / 50-lesson curriculum + projects
routines/            prompt specs for the scheduled Claude routines
app/ lib/ components/ Next.js read-only dashboard
```

## Run the dashboard locally

```bash
npm install
cp .env.example .env.local     # fill in Supabase URL + anon key
npm run dev                    # http://localhost:3000
```

The dashboard renders with empty states before Supabase is connected, so `npm run dev`
works immediately.

## Provision Supabase

1. Create a Supabase project.
2. In the SQL editor, run `supabase/schema.sql` then `supabase/seed.sql`.
3. Put the project URL + anon key in `.env.local` (dashboard) and keep the service key for
   the routines.

## Create the routines

Use the Claude Code `/schedule` skill to create one routine per file in `routines/`,
wiring the Supabase (service key) and Slack MCPs. Fixed cron times per the plan.
