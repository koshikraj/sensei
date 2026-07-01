// Runs the schema + seed against a Supabase Postgres connection.
// Usage: SUPABASE_DB_URL="postgresql://..." node supabase/run-sql.mjs
// or add SUPABASE_DB_URL to .env and run: npm run db:setup
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import pg from "pg";

const here = dirname(fileURLToPath(import.meta.url));

// Minimal .env loader (only if SUPABASE_DB_URL isn't already set).
if (!process.env.SUPABASE_DB_URL) {
  try {
    for (const line of readFileSync(join(here, "..", ".env"), "utf8").split("\n")) {
      const m = line.match(/^\s*SUPABASE_DB_URL\s*=\s*(.*)\s*$/);
      if (m) process.env.SUPABASE_DB_URL = m[1].replace(/^["']|["']$/g, "");
    }
  } catch {
    /* no .env */
  }
}

const conn = process.env.SUPABASE_DB_URL;
if (!conn) {
  console.error(
    "Missing SUPABASE_DB_URL. Get it from Supabase → Project Settings → Database →\n" +
      "Connection string → URI (use the Session pooler), then add it to .env as\n" +
      'SUPABASE_DB_URL="postgresql://postgres.<ref>:<password>@...pooler.supabase.com:5432/postgres"'
  );
  process.exit(1);
}

const client = new pg.Client({ connectionString: conn, ssl: { rejectUnauthorized: false } });

async function runFile(name) {
  const sql = readFileSync(join(here, name), "utf8");
  console.log(`\n▶ Running ${name} ...`);
  await client.query(sql);
  console.log(`✓ ${name} applied`);
}

const args = process.argv.slice(2);
const files = args.length ? args : ["schema.sql", "seed.sql"];

try {
  await client.connect();
  for (const f of files) await runFile(f);
  if (!args.length) {
    const { rows } = await client.query(
      "select (select count(*) from topics) as topics, (select count(*) from projects) as projects, (select count(*) from mastery) as mastery"
    );
    console.log(`\n✅ Done. topics=${rows[0].topics}, projects=${rows[0].projects}, mastery=${rows[0].mastery}`);
  } else {
    console.log("\n✅ Done.");
  }
} catch (e) {
  console.error("\n✗ Failed:", e.message);
  process.exit(1);
} finally {
  await client.end();
}
