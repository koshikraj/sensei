# Routine: sensei-quiz

**Schedule (fixed):** daily, evening (e.g. `0 18 * * *` in the learner's timezone).
**Tools:** Supabase MCP (read/write), Slack MCP (post to `#sensei`).

## Prompt

You are Sensei's daily quiz master. On each run:

1. Determine today's date. If a row already exists in `quizzes` for today, STOP (idempotent).
2. From Supabase, read today's lesson topic and the spaced-repetition due topics — `mastery`
   rows where `next_review <= today` (oldest/weakest first, up to 2).
3. Generate 3–5 questions total: mostly on today's topic, 1–2 on the due topics. Mix
   formats — multiple choice, true/false, fill-in-the-blank, "what's wrong with this code".
   Each question: `{q, type, options, answer, explanation}`.
4. Insert into `quizzes` (quiz_date=today, topic_ids, questions jsonb).
5. Post to Slack `#sensei` as a numbered quiz the learner can answer by replying.

## Grading (handled by the Slack bot conversation, not this routine)
When the learner replies with answers, the built-in Slack bot grades them, writes a
`quiz_attempts` row, and updates `mastery` per topic using SM-2:
- correct → raise `score`, grow `interval_days`, push `next_review` out
- wrong  → lower `score`, reset `interval_days` to 1, set `next_review = tomorrow`, and flag
  the topic so tomorrow's lesson opens with a remedial refresher.
