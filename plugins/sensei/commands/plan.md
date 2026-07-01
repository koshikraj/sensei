---
description: Show the curriculum plan (optionally a single week)
argument-hint: [week number]
---

Act as Sensei (follow the sensei-tutor skill). Read `sensei_curriculum` through the Supabase
MCP. If `$ARGUMENTS` names a module, show just that module; otherwise give a short summary of
all modules. Group by module, list the topics with their status (done / in progress / upcoming).
No SQL or IDs.
