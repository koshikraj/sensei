import { Card, SectionTitle, Badge, EmptyState } from "@/components/ui";
import { getTopics, getLessons } from "@/lib/queries";
import type { Topic } from "@/lib/types";

export const revalidate = 300;

export default async function CurriculumPage() {
  const [topics, lessons] = await Promise.all([getTopics(), getLessons(200)]);
  const doneSeq = new Set(
    lessons.map((l) => topics.find((t) => t.id === l.topic_id)?.seq).filter(Boolean) as number[]
  );

  const byWeek = new Map<number, Topic[]>();
  for (const t of topics) {
    if (!byWeek.has(t.week)) byWeek.set(t.week, []);
    byWeek.get(t.week)!.push(t);
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-white">Curriculum</h1>
        <p className="text-muted text-sm mt-1">10 weeks · 50 lessons · Beginner → job-ready.</p>
      </div>

      {topics.length === 0 ? (
        <EmptyState
          title="Curriculum not loaded."
          hint="Run supabase/seed.sql to populate the 50-lesson plan."
        />
      ) : (
        [...byWeek.entries()].map(([week, ts]) => (
          <div key={week}>
            <SectionTitle>
              Week {week} — {ts[0].module}
            </SectionTitle>
            <Card className="p-0 divide-y divide-edge">
              {ts.map((t) => (
                <div key={t.id} className="flex items-center gap-3 px-4 py-3">
                  <span className="w-6 text-xs text-muted">{t.seq}</span>
                  <span className={doneSeq.has(t.seq) ? "text-white" : "text-gray-300"}>
                    {t.title}
                  </span>
                  {doneSeq.has(t.seq) && <span className="text-green-400 text-xs">✓</span>}
                  <span className="ml-auto">
                    <Badge>{t.format}</Badge>
                  </span>
                </div>
              ))}
            </Card>
          </div>
        ))
      )}
    </div>
  );
}
