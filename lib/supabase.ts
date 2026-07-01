import { createClient, SupabaseClient } from "@supabase/supabase-js";

/**
 * Server-side Supabase client (anon key, read-only via RLS).
 * Returns null when env vars are absent so the dashboard still renders
 * (with empty states) before Supabase is provisioned.
 */
export function getSupabase(): SupabaseClient | null {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) return null;
  return createClient(url, key, { auth: { persistSession: false } });
}

export const isConfigured = () =>
  Boolean(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
