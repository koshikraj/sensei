import { getSupabase } from "./supabase";
import type { Today, CurriculumModule, ProgressTopic, ProjectItem, NewsItem } from "./types";

// All read helpers degrade to empty results when Supabase isn't configured.

const EMPTY_TODAY: Today = {
  topic: null,
  lessons: [],
  resources: [],
  quizStatus: "locked",
  topicsDone: 0,
  topicsTotal: 0,
  avgMastery: 0,
};

export async function getToday(): Promise<Today> {
  const db = getSupabase();
  if (!db) return EMPTY_TODAY;

  const { data: topics } = await db
    .from("topics")
    .select("id,seq,title,description,objectives,completed_at,module_id")
    .order("seq");
  if (!topics || topics.length === 0) return EMPTY_TODAY;

  const topicsTotal = topics.length;
  const topicsDone = topics.filter((t) => t.completed_at).length;
  const current = topics.find((t) => !t.completed_at) ?? null;

  const { data: mastery } = await db.from("mastery").select("score");
  const avgMastery =
    mastery && mastery.length
      ? Math.round(mastery.reduce((s, m) => s + (m.score ?? 0), 0) / mastery.length)
      : 0;

  if (!current) return { ...EMPTY_TODAY, topicsDone, topicsTotal, avgMastery };

  const [{ data: mod }, { data: lessons }, { data: resources }, { data: quiz }] = await Promise.all([
    db.from("modules").select("title").eq("id", current.module_id).maybeSingle(),
    db.from("lessons").select("position,title,format,status,completed_at").eq("topic_id", current.id).order("position"),
    db.from("resources").select("kind,title,url,source,position").eq("topic_id", current.id).order("position"),
    db.from("quizzes").select("status").eq("topic_id", current.id).maybeSingle(),
  ]);

  return {
    topic: {
      title: current.title,
      module: mod?.title ?? "",
      description: current.description,
      objectives: current.objectives,
    },
    lessons: (lessons ?? []).map((l) => ({
      position: l.position,
      title: l.title,
      format: l.format,
      status: l.completed_at ? "completed" : l.status,
    })),
    resources: (resources ?? []).map((r) => ({ kind: r.kind, title: r.title, url: r.url, source: r.source })),
    quizStatus: quiz?.status ?? "locked",
    topicsDone,
    topicsTotal,
    avgMastery,
  };
}

export async function getCurriculum(): Promise<CurriculumModule[]> {
  const db = getSupabase();
  if (!db) return [];
  const [{ data: modules }, { data: topics }, { data: lessons }] = await Promise.all([
    db.from("modules").select("id,seq,title").order("seq"),
    db.from("topics").select("id,seq,title,module_id,started_at,completed_at").order("seq"),
    db.from("lessons").select("topic_id"),
  ]);
  if (!modules) return [];
  const lessonCount = new Map<number, number>();
  (lessons ?? []).forEach((l) => lessonCount.set(l.topic_id, (lessonCount.get(l.topic_id) ?? 0) + 1));
  return modules.map((m) => ({
    seq: m.seq,
    title: m.title,
    topics: (topics ?? [])
      .filter((t) => t.module_id === m.id)
      .map((t) => ({
        seq: t.seq,
        title: t.title,
        lessons: lessonCount.get(t.id) ?? 0,
        status: t.completed_at ? "done" : t.started_at ? "in progress" : "upcoming",
      })),
  }));
}

export async function getProgress(): Promise<ProgressTopic[]> {
  const db = getSupabase();
  if (!db) return [];
  const [{ data: topics }, { data: modules }, { data: mastery }] = await Promise.all([
    db.from("topics").select("id,seq,title,module_id,started_at,completed_at").order("seq"),
    db.from("modules").select("id,title"),
    db.from("mastery").select("topic_id,score"),
  ]);
  if (!topics) return [];
  const modTitle = new Map((modules ?? []).map((m) => [m.id, m.title]));
  const score = new Map((mastery ?? []).map((m) => [m.topic_id, m.score]));
  return topics.map((t) => ({
    title: t.title,
    module: modTitle.get(t.module_id) ?? "",
    mastery: score.get(t.id) ?? 0,
    status: t.completed_at ? "done" : t.started_at ? "in progress" : "upcoming",
  }));
}

export async function getProjects(): Promise<ProjectItem[]> {
  const db = getSupabase();
  if (!db) return [];
  const [{ data: projects }, { data: modules }] = await Promise.all([
    db.from("projects").select("module_id,title,status"),
    db.from("modules").select("id,seq,title"),
  ]);
  if (!projects) return [];
  const mod = new Map((modules ?? []).map((m) => [m.id, m]));
  return projects
    .map((p) => ({
      moduleSeq: mod.get(p.module_id)?.seq ?? 0,
      module: mod.get(p.module_id)?.title ?? "",
      title: p.title,
      status: p.status,
    }))
    .sort((a, b) => a.moduleSeq - b.moduleSeq);
}

export async function getNews(limit = 30): Promise<NewsItem[]> {
  const db = getSupabase();
  if (!db) return [];
  const { data } = await db
    .from("news_items")
    .select("id,news_date,title,url,summary,source")
    .order("news_date", { ascending: false })
    .limit(limit);
  return (data as NewsItem[]) ?? [];
}
