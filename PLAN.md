# 🥋 Sensei — AI Engineering Daily Teacher

A Claude-agent-native system that teaches AI Engineering in 30 min/day for 10 weeks.
Scheduled Claude routines generate lessons, quizzes, weekly projects, and news, post them
to a Slack channel, and record everything in Supabase. A read-only dashboard reflects the
data. Conversational edits (content, plan, and code) happen by chatting with Claude Code's
built-in Slack bot, which has the Supabase connector and the repo linked.

- **Learner level:** Beginner
- **Budget:** ~30 min/day (≈15 min lesson + ~10 min quiz + ~5 min news)
- **Delivery:** Slack channel `#sensei` (notifications) + read-only web dashboard
- **Timeline:** 10 weeks, 50 daily lessons, 10 weekly projects

---

## 1. Architecture

```
     SCHEDULED CLAUDE ROUTINES (fixed cron)          CONVERSATION (on demand)
   ┌────────────────────────────────────┐      ┌──────────────────────────────┐
   │  • sensei-lesson    (daily AM)      │      │  Claude Code Slack bot        │
   │  • sensei-quiz      (daily PM)      │      │  (already available)          │
   │  • sensei-project   (Mon/Fri)       │      │  • Supabase connector linked  │
   │  • sensei-news      (2–3×/wk)       │      │  • linked repo for code edits │
   │  read curriculum + mastery from     │      │  Chat in #sensei → edits      │
   │  Supabase (MCP), nothing hardcoded  │      │  content/plan in Supabase or  │
   └───────────────┬────────────────────┘      │  edits the repo & redeploys   │
                   │ write content               └───────────────┬──────────────┘
                   │ + post                                       │ read/write
                   ▼                                              ▼
          ┌───────────────────────────────────────────────────────────┐
          │                    SUPABASE (source of truth)              │
          │   topics · lessons · quizzes · quiz_attempts · mastery ·   │
          │   projects · news_items · edit_log                         │
          └───────────────┬───────────────────────────┬───────────────┘
                          │ posts                       │ reads
                          ▼                             ▼
                  ┌────────────────┐          ┌────────────────────┐
                  │  Slack #sensei │          │  Read-only Next.js │
                  │  (dedicated)   │          │  dashboard (Vercel)│
                  └────────────────┘          └────────────────────┘
```

Everything is a Claude agent. Schedule is **fixed** (baked into each routine's cron). No
schedule editor. No custom backend — the routines and the Slack bot are the backend.

---

## 2. Curriculum (10 weeks · 50 lessons)

5 lessons/week (weekdays). Daily **format rotation**: explainer / code-along /
explain-it-back / case-study / debug-or-flashcard. Full lesson list is seeded in
`supabase/seed.sql`.

| Week | Module | Weekly project |
|---|---|---|
| 1 | LLM Foundations | Streaming CLI chat with Claude |
| 2 | Prompt Engineering | Messy-text → structured-JSON prompt library |
| 3 | Embeddings & Vector Search | Semantic search over your notes (pgvector) |
| 4 | RAG | "Chat with your notes" RAG bot |
| 5 | Agents & Tools | Weather + calendar tool-calling agent |
| 6 | MCP + Evals | Eval suite grading the Week-4 RAG bot |
| 7 | Production: Observability, Cost, Safety | Add tracing + prompt caching to a project |
| 8 | Advanced Techniques | Multi-agent research assistant |
| 9 | Ship It | Deploy a small AI app end-to-end |
| 10 | Capstone | Full capstone app (RAG + tools + evals + UI) |

Spaced repetition (SM-2 style) resurfaces weak/aging topics in later quizzes; a bombed
topic triggers a remedial mini-lesson before advancing.

---

## 3. Scheduled routines (created via `/schedule`)

Each is a headless Claude routine on a fixed cron that reads curriculum + mastery from
Supabase, generates content, writes it back, and posts to `#sensei`. Prompt specs live in
`routines/`.

| Routine | Cron (fixed) | Job |
|---|---|---|
| `sensei-lesson` | daily, AM | Generate today's lesson in the day's format → `lessons` → post |
| `sensei-quiz` | daily, PM | Today's topic + spaced-repetition due → `quizzes` → post |
| `sensei-project` | Mon (brief) / Fri (review) | Weekly project → `projects` → post |
| `sensei-news` | 2–3×/wk | Web search → dedupe vs `news_items` → post |

Idempotency is a one-line guard: each routine checks whether today's item already exists
before posting.

**Headless auth caveat:** cloud routines need token-based MCP auth. Use a Supabase
service/access token; use a Slack bot-token/webhook connection (OAuth-only MCP servers may
be unavailable in headless runs). Confirm in Phase A.

---

## 4. Conversation-based updates (built-in Slack bot)

No custom routine. You chat with Claude Code's Slack bot in `#sensei`; it has the Supabase
connector and the linked repo, so it can do both data and code edits from one conversation:

- "Regenerate today's lesson, more hands-on" → update the `lessons` row / mark for regen
- "Add a topic on prompt caching after Week 7" → insert a `topics` row
- "Mark embeddings mastered, skip its review" → update `mastery`
- "Push RAG back a week" → shift curriculum order
- "The quiz view is cramped" → edit the linked repo and redeploy

Every data edit is appended to `edit_log`. Destructive ops require explicit confirmation.

---

## 5. Dashboard implementation plan

**Stack:** Next.js (App Router, TypeScript) · Tailwind CSS · `@supabase/supabase-js` ·
deploy on Vercel. **Read-only** — no write controls (all edits go through the Slack bot).
Server Components fetch directly from Supabase with the anon key + RLS read policies.

**Pages**

| Route | Purpose | Reads |
|---|---|---|
| `/` (Today) | Current **topic** → its lessons, resources, and quiz status | `topics`, `lessons`, `resources`, `quizzes`, `mastery` |
| `/curriculum` | Modules → topics map + status | `modules`, `topics`, `lessons` |
| `/progress` | Per-topic mastery heatmap + focus list | `topics`, `mastery` |
| `/archive` | Completed topics + module projects | `topics`, `mastery`, `projects` |
| `/news` | Recent curated items | `news_items` |

**Data layer**
- `lib/supabase.ts` — a server-side client factory using `NEXT_PUBLIC_SUPABASE_URL` +
  `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
- `lib/queries.ts` — typed read helpers (`getToday`, `getCurriculum`, `getMastery`, …)
  that **degrade gracefully**: if env vars are missing or the DB is empty, they return
  empty results so `npm run dev` works before Supabase is provisioned.

**Components**
- `Nav` (top bar), `Card`, `LessonCard`, `QuizCard`, `MasteryHeatmap`, `StreakBadge`,
  `EmptyState` (shown until routines populate data).

**Rendering & caching**
- Server Components with `export const revalidate = 300` (5-min ISR) — the dashboard is a
  live mirror, freshness within minutes is fine.

**Build order**
1. Scaffold app + Tailwind + Supabase client + graceful queries.
2. Layout + Nav + Today page (works empty).
3. Curriculum page (reads seeded `topics`).
4. Progress + heatmap.
5. Archive + News.
6. Deploy to Vercel; link repo so the Slack bot can maintain it.

---

## 6. Data model (Supabase) — v2, completion-driven

Defined in `supabase/schema.sql`. Structure is **modules → topics → lessons + resources**,
one **quiz per topic**, one **project per module**. No hardcoded weeks/days: topics have an
order and advance only when all their lessons AND their quiz are complete.

```
modules       -- seq, slug, title, description
topics        -- seq (order), module_id, title, description, objectives, started_at, completed_at
lessons       -- topic_id, position, title, format, content, status, available_at, completed_at
resources     -- topic_id, lesson_id?, kind (article|video|doc|pdf|link|code|file), title, url, storage_path
quizzes       -- topic_id (unique), questions, status (locked|due|available|completed), due_at, delivered_at
quiz_attempts -- quiz_id, answers, score, per_topic_results
mastery       -- topic_id, score, next_review (spaced repetition)
projects      -- module_id (unique), title, brief, solution, criteria, status
news_items    -- news_date, module_id, title, url, summary, source
edit_log      -- source, actor, target, before, after, ts
```

**Flow (state machine, in `routines/` + `supabase/views.sql`):** the current topic is the first
one not `done`. Lessons are delivered when the topic starts; the learner completes them at their
pace. The **per-topic quiz** is gated on two conditions — its scheduled slot AND all lessons done
— and is delivered whichever comes last (finish lessons late → quiz auto-populates). Finishing
the quiz completes the topic and advances to the next. Migrate an existing DB with
`node supabase/run-sql.mjs migrate-v2.sql schema.sql seed.sql views.sql`.

---

## 7. Build roadmap

- **Phase A — Foundation + dashboard** *(in progress)*: schema, curriculum seed, dashboard
  scaffold, routine prompt specs.
- **Phase B — Daily loop live**: create `sensei-lesson` + `sensei-quiz` routines against a
  real Supabase project; verify posts to `#sensei`.
- **Phase C — Dashboard deploy**: deploy to Vercel, link repo to the Slack bot.
- **Phase D — Projects + news**: `sensei-project` + `sensei-news` routines.

---

## 8. Cost
Supabase free tier · Vercel free tier · Slack free · routine LLM calls ≈ $3–8/month
(routines run on your Claude plan).

---

## 9. What's needed from you (to move past Phase A)
1. **Supabase** — create a project; provide the project URL, anon key, and a service/access
   token for the routines.
2. **Slack** — create the `#sensei` channel and add the Claude Code Slack bot; confirm a
   headless-capable auth path (bot token/webhook).
3. **Vercel** — account to deploy the dashboard (and later link the repo).
4. **Send times** — preferred lesson/quiz times + timezone (baked into the routine cron).
