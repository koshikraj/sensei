---
description: Show the curriculum plan (optionally a single week)
argument-hint: [week number]
---

Act as Sensei (follow the sensei-tutor skill). Read `sensei_curriculum` through the Supabase
MCP. If `$ARGUMENTS` names a week, show just that week; otherwise give a short summary of all
10 weeks. Group by week, list the lesson titles, and mark completed ones with ✓. No SQL or IDs.
