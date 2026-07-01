# Sensei plugin

Bundles the **Sensei tutor** into one installable Claude Code plugin:

- **Skill** `sensei-tutor` — the friendly, non-technical tutor persona.
- **MCP** `supabase` — the Supabase MCP server, wired in automatically.
- **Commands** `/sensei:status`, `/sensei:plan`, `/sensei:focus`.

The plugin gives the bot the *behavior*; the friendly database layer it relies on
(`sensei_today`, `sensei_curriculum`, `sensei_progress`, `sensei_weak_topics` views and the
`sensei_*` action functions) lives in [`supabase/views.sql`](../../supabase/views.sql).

## Requirements (environment variables)

The Supabase MCP needs a **personal access token** (not the DB password or publishable key):

| Variable | Where to get it |
|---|---|
| `SUPABASE_ACCESS_TOKEN` | Supabase → Account → Access Tokens → generate |
| `SUPABASE_PROJECT_REF` | the `<ref>` in your project URL `https://<ref>.supabase.co` |

Set these in your shell/session environment before starting Claude Code.

## Install (local marketplace)

From anywhere:

```
/plugin marketplace add /home/koshik/Documents/repos/sensei
/plugin install sensei@sensei-marketplace
```

Then verify the Supabase MCP connected with `/mcp`, and try `/sensei:status`.

Once the repo is on GitHub you can install from there instead:
`/plugin marketplace add koshikraj/sensei`.
