import { getSupabase } from "./supabase";
import type { Topic, Lesson, Quiz, Mastery, Project, NewsItem } from "./types";

/** All read helpers degrade to empty results when Supabase is not configured. */

export async function getTopics(): Promise<Topic[]> {
  const db = getSupabase();
  if (!db) return [];
  const { data } = await db.from("topics").select("*").order("seq");
  return (data as Topic[]) ?? [];
}

export async function getLatestLesson(): Promise<Lesson | null> {
  const db = getSupabase();
  if (!db) return null;
  const { data } = await db
    .from("lessons")
    .select("*")
    .order("lesson_date", { ascending: false })
    .limit(1)
    .maybeSingle();
  return (data as Lesson) ?? null;
}

export async function getLessons(limit = 50): Promise<Lesson[]> {
  const db = getSupabase();
  if (!db) return [];
  const { data } = await db
    .from("lessons")
    .select("*")
    .order("lesson_date", { ascending: false })
    .limit(limit);
  return (data as Lesson[]) ?? [];
}

export async function getLatestQuiz(): Promise<Quiz | null> {
  const db = getSupabase();
  if (!db) return null;
  const { data } = await db
    .from("quizzes")
    .select("*")
    .order("quiz_date", { ascending: false })
    .limit(1)
    .maybeSingle();
  return (data as Quiz) ?? null;
}

export async function getMastery(): Promise<Mastery[]> {
  const db = getSupabase();
  if (!db) return [];
  const { data } = await db.from("mastery").select("*");
  return (data as Mastery[]) ?? [];
}

export async function getProjects(): Promise<Project[]> {
  const db = getSupabase();
  if (!db) return [];
  const { data } = await db.from("projects").select("*").order("week");
  return (data as Project[]) ?? [];
}

export async function getCurrentProject(): Promise<Project | null> {
  const db = getSupabase();
  if (!db) return null;
  const { data } = await db
    .from("projects")
    .select("*")
    .in("status", ["briefed", "reviewed"])
    .order("week", { ascending: false })
    .limit(1)
    .maybeSingle();
  return (data as Project) ?? null;
}

export async function getNews(limit = 20): Promise<NewsItem[]> {
  const db = getSupabase();
  if (!db) return [];
  const { data } = await db
    .from("news_items")
    .select("*")
    .order("news_date", { ascending: false })
    .limit(limit);
  return (data as NewsItem[]) ?? [];
}
